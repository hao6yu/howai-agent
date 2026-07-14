-- Phase 0 release-gate hardening: answer accounting and function defaults.

alter table public.ai_usage_ledger
  add column counts_as_answer boolean not null default true;

-- Function EXECUTE is granted to PUBLIC by PostgreSQL's global defaults.
-- Global revocation is therefore required; a schema-local revocation cannot
-- override it. Project migrations create application functions as postgres.
alter default privileges for role postgres
  revoke execute on functions from public;
alter default privileges for role postgres in schema public
  revoke execute on functions from anon, authenticated;

create or replace function public.reserve_ai_usage(
  p_user_id uuid,
  p_request_id uuid,
  p_cohort text,
  p_intent text,
  p_requested_alias text,
  p_model_role text,
  p_resolved_model text,
  p_reasoning_effort text,
  p_reservation_microusd bigint,
  p_daily_budget_microusd bigint,
  p_monthly_budget_microusd bigint,
  p_daily_answer_limit integer default null
)
returns table (accepted boolean, ledger_id uuid, reason text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_daily_cost bigint;
  v_monthly_cost bigint;
  v_daily_answers integer;
  v_ledger_id uuid;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_reservation_microusd < 0
    or p_daily_budget_microusd < 0
    or p_monthly_budget_microusd < 0 then
    raise exception 'budget values must be nonnegative' using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_user_id::text || ':' || p_model_role, 0)
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
  into v_daily_cost, v_monthly_cost, v_daily_answers
  from public.ai_usage_ledger
  where user_id = p_user_id
    and model_role = p_model_role
    and (
      status in ('reserved', 'succeeded')
      or coalesce(actual_cost_microusd, 0) > 0
    );

  if p_daily_answer_limit is not null and v_daily_answers >= p_daily_answer_limit then
    return query select false, null::uuid, 'daily_answer_limit';
    return;
  end if;

  if v_daily_cost + p_reservation_microusd > p_daily_budget_microusd then
    return query select false, null::uuid, 'daily_cost_limit';
    return;
  end if;

  if v_monthly_cost + p_reservation_microusd > p_monthly_budget_microusd then
    return query select false, null::uuid, 'monthly_cost_limit';
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

drop function public.reconcile_ai_usage(
  uuid, boolean, integer, integer, integer, bigint, text
);

create function public.reconcile_ai_usage(
  p_request_id uuid,
  p_succeeded boolean,
  p_counts_as_answer boolean default false,
  p_input_tokens integer default null,
  p_cached_input_tokens integer default null,
  p_output_tokens integer default null,
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

  update public.ai_usage_ledger
  set
    status = case when p_succeeded then 'succeeded' else 'failed' end,
    counts_as_answer = p_succeeded and p_counts_as_answer,
    input_tokens = p_input_tokens,
    cached_input_tokens = p_cached_input_tokens,
    output_tokens = p_output_tokens,
    actual_cost_microusd = greatest(coalesce(p_actual_cost_microusd, 0), 0),
    failure_code = case when p_succeeded then null else p_failure_code end,
    completed_at = pg_catalog.now()
  where request_id = p_request_id
    and status = 'reserved';
end;
$$;

revoke all on function public.reserve_ai_usage(
  uuid, uuid, text, text, text, text, text, text,
  bigint, bigint, bigint, integer
) from public, anon, authenticated;
revoke all on function public.reconcile_ai_usage(
  uuid, boolean, boolean, integer, integer, integer, bigint, text
) from public, anon, authenticated;

grant execute on function public.reserve_ai_usage(
  uuid, uuid, text, text, text, text, text, text,
  bigint, bigint, bigint, integer
) to service_role;
grant execute on function public.reconcile_ai_usage(
  uuid, boolean, boolean, integer, integer, integer, bigint, text
) to service_role;
