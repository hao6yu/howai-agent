-- Production trial image generation for anonymous and signed-in Free users.
--
-- The client can offer the image tool, but only this service-role-only
-- reservation path decides whether the tool reaches OpenAI.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;

alter default privileges for role postgres in schema private
  revoke all on tables from public, anon, authenticated;
alter default privileges for role postgres in schema private
  revoke execute on functions from public, anon, authenticated;

create table private.trial_image_generation_usage (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null unique
    references public.ai_usage_ledger(request_id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  cohort text not null,
  status text not null default 'reserved',
  reservation_microusd bigint not null,
  accounted_cost_microusd bigint not null default 0,
  image_generation_calls smallint not null default 0,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint trial_image_generation_usage_cohort_check
    check (cohort in ('anonymous', 'free')),
  constraint trial_image_generation_usage_status_check
    check (status in ('reserved', 'succeeded', 'released', 'failed')),
  constraint trial_image_generation_usage_reservation_nonnegative
    check (reservation_microusd >= 0),
  constraint trial_image_generation_usage_cost_nonnegative
    check (accounted_cost_microusd >= 0),
  constraint trial_image_generation_usage_call_count
    check (image_generation_calls between 0 and 1)
);

comment on table private.trial_image_generation_usage is
  'Service-owned reservation state for anonymous and Free image-generation trials.';
comment on column private.trial_image_generation_usage.accounted_cost_microusd is
  'Conservative image-attributed cost used by the trial-image circuit breaker.';

alter table private.trial_image_generation_usage enable row level security;
revoke all on private.trial_image_generation_usage
  from public, anon, authenticated;
grant all on private.trial_image_generation_usage to service_role;

create index trial_image_generation_usage_user_created_idx
  on private.trial_image_generation_usage (user_id, cohort, created_at desc);
create index trial_image_generation_usage_global_cost_idx
  on private.trial_image_generation_usage (created_at desc)
  include (status, reservation_microusd, accounted_cost_microusd);

alter table public.openai_proxy_requests
  add column if not exists image_generation_offered boolean not null default false,
  add column if not exists image_generation_calls smallint,
  add column if not exists image_generation_quota_denied boolean not null default false;

alter table public.openai_proxy_requests
  add constraint openai_proxy_requests_image_generation_calls_check
  check (
    image_generation_calls is null
    or image_generation_calls between 0 and 1
  );

comment on column public.openai_proxy_requests.image_generation_offered is
  'Whether the sanitized upstream request exposed image_generation.';
comment on column public.openai_proxy_requests.image_generation_calls is
  'Completed image_generation_call results observed in the terminal Responses payload.';
comment on column public.openai_proxy_requests.image_generation_quota_denied is
  'Whether an otherwise eligible trial request had image generation removed by quota.';

create function public.reserve_trial_image_generation(
  p_user_id uuid,
  p_request_id uuid,
  p_cohort text,
  p_reservation_microusd bigint,
  p_user_window_limit integer,
  p_user_window_seconds integer,
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
  v_user_generations integer;
  v_global_daily_cost bigint;
  v_global_monthly_cost bigint;
  v_usage_id uuid;
  v_reset_at timestamptz;
  v_window interval;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_user_id is null
    or p_request_id is null
    or p_cohort is null
    or p_cohort not in ('anonymous', 'free')
    or p_reservation_microusd is null
    or p_user_window_limit is null
    or p_user_window_seconds is null
    or p_global_daily_budget_microusd is null
    or p_global_monthly_budget_microusd is null
    or p_reservation_microusd < 0
    or p_user_window_limit < 0
    or p_user_window_seconds <= 0
    or p_global_daily_budget_microusd < 0
    or p_global_monthly_budget_microusd < 0 then
    raise exception 'image reservation and limit values are invalid'
      using errcode = '22023';
  end if;

  if not exists (
    select 1
    from public.ai_usage_ledger
    where request_id = p_request_id
      and user_id = p_user_id
      and cohort = p_cohort
      and status = 'reserved'
  ) then
    raise exception 'matching reserved trial request required'
      using errcode = '23503';
  end if;

  v_window := pg_catalog.make_interval(secs => p_user_window_seconds);

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('howai:image_generation:global', 0)
  );
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'howai:image_generation:user:' || p_user_id::text,
      0
    )
  );

  select id, status
  into v_existing_id, v_existing_status
  from private.trial_image_generation_usage
  where request_id = p_request_id;

  if v_existing_id is not null then
    return query select
      v_existing_status = 'reserved',
      v_existing_id,
      case
        when v_existing_status = 'reserved' then null::text
        else 'already_reconciled'
      end,
      null::timestamptz;
    return;
  end if;

  select count(*)
  into v_user_generations
  from private.trial_image_generation_usage
  where user_id = p_user_id
    and cohort = p_cohort
    and created_at >= pg_catalog.now() - v_window
    and (
      status = 'reserved'
      or (status = 'succeeded' and image_generation_calls > 0)
    );

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
  from private.trial_image_generation_usage
  where created_at >= pg_catalog.now() - interval '30 days';

  if v_user_generations >= p_user_window_limit then
    select min(created_at + v_window)
    into v_reset_at
    from private.trial_image_generation_usage
    where user_id = p_user_id
      and cohort = p_cohort
      and created_at >= pg_catalog.now() - v_window
      and (
        status = 'reserved'
        or (status = 'succeeded' and image_generation_calls > 0)
      );
    return query select
      false,
      null::uuid,
      'user_generation_limit',
      v_reset_at;
    return;
  end if;

  if (
    v_global_daily_cost + p_reservation_microusd
    > p_global_daily_budget_microusd
  ) then
    return query select
      false,
      null::uuid,
      'global_daily_cost_limit',
      pg_catalog.now() + interval '24 hours';
    return;
  end if;

  if (
    v_global_monthly_cost + p_reservation_microusd
    > p_global_monthly_budget_microusd
  ) then
    return query select
      false,
      null::uuid,
      'global_monthly_cost_limit',
      pg_catalog.now() + interval '30 days';
    return;
  end if;

  insert into private.trial_image_generation_usage (
    request_id,
    user_id,
    cohort,
    reservation_microusd
  )
  values (
    p_request_id,
    p_user_id,
    p_cohort,
    p_reservation_microusd
  )
  returning id into v_usage_id;

  return query select true, v_usage_id, null::text, null::timestamptz;
end;
$$;

create function public.reconcile_trial_image_generation(
  p_request_id uuid,
  p_succeeded boolean,
  p_image_generation_calls integer,
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
    or p_image_generation_calls is null
    or p_accounted_cost_microusd is null
    or p_image_generation_calls < 0
    or p_image_generation_calls > 1
    or p_accounted_cost_microusd < 0 then
    raise exception 'image reconciliation values are invalid'
      using errcode = '22023';
  end if;

  update private.trial_image_generation_usage
  set
    status = case
      when p_image_generation_calls = 0 then 'released'
      when p_succeeded then 'succeeded'
      else 'failed'
    end,
    image_generation_calls = p_image_generation_calls,
    accounted_cost_microusd = case
      when p_image_generation_calls > 0 then p_accounted_cost_microusd
      else 0
    end,
    completed_at = pg_catalog.now()
  where request_id = p_request_id
    and status = 'reserved';
end;
$$;

revoke all on function public.reserve_trial_image_generation(
  uuid, uuid, text, bigint, integer, integer, bigint, bigint
) from public, anon, authenticated;
revoke all on function public.reconcile_trial_image_generation(
  uuid, boolean, integer, bigint
) from public, anon, authenticated;

grant execute on function public.reserve_trial_image_generation(
  uuid, uuid, text, bigint, integer, integer, bigint, bigint
) to service_role;
grant execute on function public.reconcile_trial_image_generation(
  uuid, boolean, integer, bigint
) to service_role;
