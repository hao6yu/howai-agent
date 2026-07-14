-- GPT-5.6 release-gate hardening: actual-model/error telemetry and atomic
-- route, user, and project-wide cost reservations.

alter table public.openai_proxy_requests
  add column if not exists actual_model text,
  add column if not exists error_code text,
  add column if not exists error_param text;

comment on column public.openai_proxy_requests.actual_model is
  'Physical model identifier returned by the upstream Responses API.';
comment on column public.openai_proxy_requests.error_code is
  'Bounded upstream error code or type; never an upstream message.';
comment on column public.openai_proxy_requests.error_param is
  'Bounded upstream parameter path; never request or response content.';

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conname = 'openai_proxy_requests_actual_model_length'
      and conrelid = 'public.openai_proxy_requests'::regclass
  ) then
    alter table public.openai_proxy_requests
      add constraint openai_proxy_requests_actual_model_length
      check (actual_model is null or pg_catalog.length(actual_model) <= 160);
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conname = 'openai_proxy_requests_error_code_length'
      and conrelid = 'public.openai_proxy_requests'::regclass
  ) then
    alter table public.openai_proxy_requests
      add constraint openai_proxy_requests_error_code_length
      check (error_code is null or pg_catalog.length(error_code) <= 80);
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conname = 'openai_proxy_requests_error_param_length'
      and conrelid = 'public.openai_proxy_requests'::regclass
  ) then
    alter table public.openai_proxy_requests
      add constraint openai_proxy_requests_error_param_length
      check (error_param is null or pg_catalog.length(error_param) <= 160);
  end if;
end
$$;

create index if not exists ai_usage_ledger_global_cost_idx
  on public.ai_usage_ledger (created_at desc)
  include (reservation_microusd, actual_cost_microusd)
  where status in ('reserved', 'succeeded')
    or actual_cost_microusd > 0;

create or replace function public.reserve_ai_usage_v2(
  p_user_id uuid,
  p_request_id uuid,
  p_cohort text,
  p_intent text,
  p_requested_alias text,
  p_model_role text,
  p_resolved_model text,
  p_reasoning_effort text,
  p_reservation_microusd bigint,
  p_route_daily_budget_microusd bigint,
  p_route_monthly_budget_microusd bigint,
  p_user_daily_budget_microusd bigint,
  p_user_monthly_budget_microusd bigint,
  p_global_daily_budget_microusd bigint,
  p_global_monthly_budget_microusd bigint,
  p_daily_answer_limit integer default null
)
returns table (accepted boolean, ledger_id uuid, reason text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_route_daily_cost bigint;
  v_route_monthly_cost bigint;
  v_user_daily_cost bigint;
  v_user_monthly_cost bigint;
  v_global_daily_cost bigint;
  v_global_monthly_cost bigint;
  v_daily_answers integer;
  v_ledger_id uuid;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_user_id is null
    or p_request_id is null
    or p_reservation_microusd is null
    or p_route_daily_budget_microusd is null
    or p_route_monthly_budget_microusd is null
    or p_user_daily_budget_microusd is null
    or p_user_monthly_budget_microusd is null
    or p_global_daily_budget_microusd is null
    or p_global_monthly_budget_microusd is null
    or p_reservation_microusd < 0
    or p_route_daily_budget_microusd < 0
    or p_route_monthly_budget_microusd < 0
    or p_user_daily_budget_microusd < 0
    or p_user_monthly_budget_microusd < 0
    or p_global_daily_budget_microusd < 0
    or p_global_monthly_budget_microusd < 0
    or coalesce(p_daily_answer_limit, 0) < 0 then
    raise exception 'reservation and budget values must be present and nonnegative'
      using errcode = '22023';
  end if;

  -- Every caller acquires these locks in this order. The transaction contains
  -- only local aggregates and one insert, so no external call holds the lock.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('howai:ai_usage:global', 0)
  );
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('howai:ai_usage:user:' || p_user_id::text, 0)
  );

  select
    coalesce(sum(
      case
        when created_at >= pg_catalog.now() - interval '24 hours'
          then coalesce(actual_cost_microusd, reservation_microusd)
        else 0
      end
    ), 0),
    coalesce(sum(
      case
        when created_at >= pg_catalog.date_trunc('month', pg_catalog.now())
          then coalesce(actual_cost_microusd, reservation_microusd)
        else 0
      end
    ), 0),
    count(*) filter (
      where created_at >= pg_catalog.now() - interval '24 hours'
        and (
          status = 'reserved'
          or (status = 'succeeded' and counts_as_answer)
        )
    )
  into v_route_daily_cost, v_route_monthly_cost, v_daily_answers
  from public.ai_usage_ledger
  where user_id = p_user_id
    and model_role = p_model_role
    and created_at >= case
      when pg_catalog.now() - interval '24 hours'
        < pg_catalog.date_trunc('month', pg_catalog.now())
        then pg_catalog.now() - interval '24 hours'
      else pg_catalog.date_trunc('month', pg_catalog.now())
    end
    and (
      status in ('reserved', 'succeeded')
      or actual_cost_microusd > 0
    );

  select
    coalesce(sum(
      case
        when created_at >= pg_catalog.now() - interval '24 hours'
          then coalesce(actual_cost_microusd, reservation_microusd)
        else 0
      end
    ), 0),
    coalesce(sum(
      case
        when created_at >= pg_catalog.date_trunc('month', pg_catalog.now())
          then coalesce(actual_cost_microusd, reservation_microusd)
        else 0
      end
    ), 0)
  into v_user_daily_cost, v_user_monthly_cost
  from public.ai_usage_ledger
  where user_id = p_user_id
    and created_at >= case
      when pg_catalog.now() - interval '24 hours'
        < pg_catalog.date_trunc('month', pg_catalog.now())
        then pg_catalog.now() - interval '24 hours'
      else pg_catalog.date_trunc('month', pg_catalog.now())
    end
    and (
      status in ('reserved', 'succeeded')
      or actual_cost_microusd > 0
    );

  select
    coalesce(sum(
      case
        when created_at >= pg_catalog.now() - interval '24 hours'
          then coalesce(actual_cost_microusd, reservation_microusd)
        else 0
      end
    ), 0),
    coalesce(sum(
      case
        when created_at >= pg_catalog.date_trunc('month', pg_catalog.now())
          then coalesce(actual_cost_microusd, reservation_microusd)
        else 0
      end
    ), 0)
  into v_global_daily_cost, v_global_monthly_cost
  from public.ai_usage_ledger
  where created_at >= case
      when pg_catalog.now() - interval '24 hours'
        < pg_catalog.date_trunc('month', pg_catalog.now())
        then pg_catalog.now() - interval '24 hours'
      else pg_catalog.date_trunc('month', pg_catalog.now())
    end
    and (
      status in ('reserved', 'succeeded')
      or actual_cost_microusd > 0
    );

  if p_daily_answer_limit is not null and v_daily_answers >= p_daily_answer_limit then
    return query select false, null::uuid, 'daily_answer_limit';
    return;
  end if;

  if v_route_daily_cost + p_reservation_microusd > p_route_daily_budget_microusd then
    return query select false, null::uuid, 'route_daily_cost_limit';
    return;
  end if;

  if v_route_monthly_cost + p_reservation_microusd > p_route_monthly_budget_microusd then
    return query select false, null::uuid, 'route_monthly_cost_limit';
    return;
  end if;

  if v_user_daily_cost + p_reservation_microusd > p_user_daily_budget_microusd then
    return query select false, null::uuid, 'user_daily_cost_limit';
    return;
  end if;

  if v_user_monthly_cost + p_reservation_microusd > p_user_monthly_budget_microusd then
    return query select false, null::uuid, 'user_monthly_cost_limit';
    return;
  end if;

  if v_global_daily_cost + p_reservation_microusd > p_global_daily_budget_microusd then
    return query select false, null::uuid, 'global_daily_cost_limit';
    return;
  end if;

  if v_global_monthly_cost + p_reservation_microusd > p_global_monthly_budget_microusd then
    return query select false, null::uuid, 'global_monthly_cost_limit';
    return;
  end if;

  insert into public.ai_usage_ledger (
    request_id,
    user_id,
    cohort,
    intent,
    requested_alias,
    model_role,
    resolved_model,
    reasoning_effort,
    reservation_microusd
  )
  values (
    p_request_id,
    p_user_id,
    p_cohort,
    p_intent,
    p_requested_alias,
    p_model_role,
    p_resolved_model,
    p_reasoning_effort,
    p_reservation_microusd
  )
  returning id into v_ledger_id;

  return query select true, v_ledger_id, null::text;
end;
$$;

revoke all on function public.reserve_ai_usage_v2(
  uuid, uuid, text, text, text, text, text, text,
  bigint, bigint, bigint, bigint, bigint, bigint, bigint, integer
) from public, anon, authenticated;

grant execute on function public.reserve_ai_usage_v2(
  uuid, uuid, text, text, text, text, text, text,
  bigint, bigint, bigint, bigint, bigint, bigint, bigint, integer
) to service_role;
