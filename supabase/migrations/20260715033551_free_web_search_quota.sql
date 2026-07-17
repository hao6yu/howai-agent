-- Limited automatic web search for signed-in Free users.
--
-- Reservation state stays outside the Data API. Public RPC wrappers exist only
-- because Edge Functions call Postgres through PostgREST; each wrapper rejects
-- every JWT role except service_role and has explicit EXECUTE revocations.

insert into public.feature_flags (key, description, enabled, payload)
values (
  'free_web_search',
  'Limited automatic web search for signed-in Free Luna requests',
  false,
  '{"mode":"off"}'::jsonb
)
on conflict (key) do nothing;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;

alter default privileges for role postgres in schema private
  revoke all on tables from public, anon, authenticated;
alter default privileges for role postgres in schema private
  revoke execute on functions from public, anon, authenticated;

create table private.free_web_search_usage (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null unique
    references public.ai_usage_ledger(request_id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'reserved',
  reservation_microusd bigint not null,
  accounted_cost_microusd bigint not null default 0,
  web_search_calls smallint not null default 0,
  counts_as_answer boolean not null default false,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint free_web_search_usage_status_check
    check (status in ('reserved', 'succeeded', 'released', 'failed')),
  constraint free_web_search_usage_reservation_nonnegative
    check (reservation_microusd >= 0),
  constraint free_web_search_usage_cost_nonnegative
    check (accounted_cost_microusd >= 0),
  constraint free_web_search_usage_call_count
    check (web_search_calls between 0 and 1)
);

comment on table private.free_web_search_usage is
  'Service-owned reservation state for limited Free web search. Not exposed through the Data API.';
comment on column private.free_web_search_usage.accounted_cost_microusd is
  'Conservative search-attributed cost used by the Free-search circuit breaker; total provider cost remains in ai_usage_ledger.';

alter table private.free_web_search_usage enable row level security;
revoke all on private.free_web_search_usage from public, anon, authenticated;
grant all on private.free_web_search_usage to service_role;

create index free_web_search_usage_user_created_idx
  on private.free_web_search_usage (user_id, created_at desc);
create index free_web_search_usage_global_cost_idx
  on private.free_web_search_usage (created_at desc)
  include (status, reservation_microusd, accounted_cost_microusd);

alter table public.openai_proxy_requests
  add column if not exists web_search_offered boolean not null default false,
  add column if not exists web_search_calls smallint,
  add column if not exists web_search_quota_denied boolean not null default false,
  add column if not exists web_search_citations_present boolean;

alter table public.openai_proxy_requests
  add constraint openai_proxy_requests_web_search_calls_check
  check (web_search_calls is null or web_search_calls >= 0);

comment on column public.openai_proxy_requests.web_search_offered is
  'Whether the sanitized upstream request exposed web_search.';
comment on column public.openai_proxy_requests.web_search_calls is
  'Completed web_search_call items observed in the terminal Responses payload.';
comment on column public.openai_proxy_requests.web_search_quota_denied is
  'Whether an otherwise eligible Free request had search removed by a quota or circuit breaker.';
comment on column public.openai_proxy_requests.web_search_citations_present is
  'Whether a searched terminal answer included at least one url_citation annotation.';

create function public.reserve_free_web_search(
  p_user_id uuid,
  p_request_id uuid,
  p_reservation_microusd bigint,
  p_user_daily_answer_limit integer,
  p_user_monthly_answer_limit integer,
  p_global_daily_budget_microusd bigint,
  p_global_monthly_budget_microusd bigint
)
returns table (
  accepted boolean,
  usage_id uuid,
  reason text,
  reset_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_existing_id uuid;
  v_existing_status text;
  v_user_daily_answers integer;
  v_user_monthly_answers integer;
  v_global_daily_cost bigint;
  v_global_monthly_cost bigint;
  v_usage_id uuid;
  v_reset_at timestamptz;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_user_id is null
    or p_request_id is null
    or p_reservation_microusd is null
    or p_user_daily_answer_limit is null
    or p_user_monthly_answer_limit is null
    or p_global_daily_budget_microusd is null
    or p_global_monthly_budget_microusd is null
    or p_reservation_microusd < 0
    or p_user_daily_answer_limit < 0
    or p_user_monthly_answer_limit < 0
    or p_global_daily_budget_microusd < 0
    or p_global_monthly_budget_microusd < 0 then
    raise exception 'search reservation and limit values must be present and nonnegative'
      using errcode = '22023';
  end if;

  if not exists (
    select 1
    from public.ai_usage_ledger
    where request_id = p_request_id
      and user_id = p_user_id
      and cohort = 'free'
      and model_role = 'luna'
      and status = 'reserved'
  ) then
    raise exception 'matching reserved Free Luna request required'
      using errcode = '23503';
  end if;

  -- All search reservations acquire the global lock before the user lock.
  -- No external request occurs while these transaction-scoped locks are held.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('howai:web_search:global', 0)
  );
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('howai:web_search:user:' || p_user_id::text, 0)
  );

  select id, status
  into v_existing_id, v_existing_status
  from private.free_web_search_usage
  where request_id = p_request_id;

  if v_existing_id is not null then
    return query select
      v_existing_status = 'reserved',
      v_existing_id,
      case when v_existing_status = 'reserved' then null::text else 'already_reconciled' end,
      null::timestamptz;
    return;
  end if;

  select
    count(*) filter (
      where created_at >= pg_catalog.now() - interval '24 hours'
        and (status = 'reserved' or (status = 'succeeded' and counts_as_answer))
    ),
    count(*) filter (
      where created_at >= pg_catalog.now() - interval '30 days'
        and (status = 'reserved' or (status = 'succeeded' and counts_as_answer))
    )
  into v_user_daily_answers, v_user_monthly_answers
  from private.free_web_search_usage
  where user_id = p_user_id
    and created_at >= pg_catalog.now() - interval '30 days';

  select
    coalesce(sum(
      case
        when created_at < pg_catalog.now() - interval '24 hours' then 0
        when status = 'reserved' then reservation_microusd
        else accounted_cost_microusd
      end
    ), 0),
    coalesce(sum(
      case
        when status = 'reserved' then reservation_microusd
        else accounted_cost_microusd
      end
    ), 0)
  into v_global_daily_cost, v_global_monthly_cost
  from private.free_web_search_usage
  where created_at >= pg_catalog.now() - interval '30 days';

  if v_user_daily_answers >= p_user_daily_answer_limit then
    select min(created_at + interval '24 hours')
    into v_reset_at
    from private.free_web_search_usage
    where user_id = p_user_id
      and created_at >= pg_catalog.now() - interval '24 hours'
      and (status = 'reserved' or (status = 'succeeded' and counts_as_answer));
    return query select false, null::uuid, 'user_daily_answer_limit', v_reset_at;
    return;
  end if;

  if v_user_monthly_answers >= p_user_monthly_answer_limit then
    select min(created_at + interval '30 days')
    into v_reset_at
    from private.free_web_search_usage
    where user_id = p_user_id
      and created_at >= pg_catalog.now() - interval '30 days'
      and (status = 'reserved' or (status = 'succeeded' and counts_as_answer));
    return query select false, null::uuid, 'user_monthly_answer_limit', v_reset_at;
    return;
  end if;

  if v_global_daily_cost + p_reservation_microusd > p_global_daily_budget_microusd then
    return query select
      false,
      null::uuid,
      'global_daily_cost_limit',
      pg_catalog.now() + interval '24 hours';
    return;
  end if;

  if v_global_monthly_cost + p_reservation_microusd > p_global_monthly_budget_microusd then
    return query select
      false,
      null::uuid,
      'global_monthly_cost_limit',
      pg_catalog.now() + interval '30 days';
    return;
  end if;

  insert into private.free_web_search_usage (
    request_id,
    user_id,
    reservation_microusd
  )
  values (
    p_request_id,
    p_user_id,
    p_reservation_microusd
  )
  returning id into v_usage_id;

  return query select true, v_usage_id, null::text, null::timestamptz;
end;
$$;

create function public.reconcile_free_web_search(
  p_request_id uuid,
  p_succeeded boolean,
  p_web_search_calls integer,
  p_accounted_cost_microusd bigint
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_request_id is null
    or p_succeeded is null
    or p_web_search_calls is null
    or p_accounted_cost_microusd is null
    or p_web_search_calls < 0
    or p_web_search_calls > 1
    or p_accounted_cost_microusd < 0 then
    raise exception 'search reconciliation values are invalid'
      using errcode = '22023';
  end if;

  update private.free_web_search_usage
  set
    status = case
      when p_web_search_calls = 0 then 'released'
      when p_succeeded then 'succeeded'
      else 'failed'
    end,
    web_search_calls = p_web_search_calls,
    counts_as_answer = p_succeeded and p_web_search_calls > 0,
    accounted_cost_microusd = case
      when p_web_search_calls > 0 then p_accounted_cost_microusd
      else 0
    end,
    completed_at = pg_catalog.now()
  where request_id = p_request_id
    and status = 'reserved';
end;
$$;

create function public.reconcile_ai_usage_v2(
  p_request_id uuid,
  p_succeeded boolean,
  p_counts_as_answer boolean default false,
  p_input_tokens integer default null,
  p_cached_input_tokens integer default null,
  p_output_tokens integer default null,
  p_tool_calls jsonb default '{}'::jsonb,
  p_actual_cost_microusd bigint default null,
  p_failure_code text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_tool_calls is null or pg_catalog.jsonb_typeof(p_tool_calls) <> 'object' then
    raise exception 'tool calls must be a JSON object' using errcode = '22023';
  end if;

  update public.ai_usage_ledger
  set
    status = case when p_succeeded then 'succeeded' else 'failed' end,
    counts_as_answer = p_succeeded and p_counts_as_answer,
    input_tokens = p_input_tokens,
    cached_input_tokens = p_cached_input_tokens,
    output_tokens = p_output_tokens,
    tool_calls = p_tool_calls,
    actual_cost_microusd = greatest(coalesce(p_actual_cost_microusd, 0), 0),
    failure_code = case when p_succeeded then null else p_failure_code end,
    completed_at = pg_catalog.now()
  where request_id = p_request_id
    and status = 'reserved';
end;
$$;

revoke all on function public.reserve_free_web_search(
  uuid, uuid, bigint, integer, integer, bigint, bigint
) from public, anon, authenticated;
revoke all on function public.reconcile_free_web_search(
  uuid, boolean, integer, bigint
) from public, anon, authenticated;
revoke all on function public.reconcile_ai_usage_v2(
  uuid, boolean, boolean, integer, integer, integer, jsonb, bigint, text
) from public, anon, authenticated;

grant execute on function public.reserve_free_web_search(
  uuid, uuid, bigint, integer, integer, bigint, bigint
) to service_role;
grant execute on function public.reconcile_free_web_search(
  uuid, boolean, integer, bigint
) to service_role;
grant execute on function public.reconcile_ai_usage_v2(
  uuid, boolean, boolean, integer, integer, integer, jsonb, bigint, text
) to service_role;
