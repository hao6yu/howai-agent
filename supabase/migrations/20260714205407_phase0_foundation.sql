create table public.feature_flags (
  key text primary key,
  enabled boolean not null default false,
  description text not null default '',
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint feature_flags_key_format
    check (key ~ '^[a-z][a-z0-9_]{1,63}$'),
  constraint feature_flags_payload_object
    check (jsonb_typeof(payload) = 'object')
);

alter table public.feature_flags enable row level security;
revoke all on public.feature_flags from public, anon, authenticated;
grant select on public.feature_flags to authenticated;
grant all on public.feature_flags to service_role;

create policy "Authenticated users can read feature flags"
  on public.feature_flags
  for select
  to authenticated
  using (true);

insert into public.feature_flags (key, description)
values
  ('model_policy_v2', 'Server-owned GPT-5.6 tier routing and cost guardrails'),
  ('reminders', 'Reminder and recurring-reminder agent actions'),
  ('push_notifications', 'Firebase remote notification delivery'),
  ('realtime_voice', 'OpenAI Realtime voice sessions'),
  ('research_workspace', 'Persistent background Research workspace')
on conflict (key) do nothing;

create table public.app_entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  tier text not null default 'free',
  source text not null,
  source_reference text,
  verified_at timestamptz not null,
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint app_entitlements_tier_check check (tier in ('free', 'paid')),
  constraint app_entitlements_source_check
    check (source in ('app_store', 'play_store', 'admin', 'migration')),
  constraint app_entitlements_metadata_object
    check (jsonb_typeof(metadata) = 'object')
);

comment on table public.app_entitlements is
  'Server-verified entitlements. The OpenAI proxy must never infer paid access from subscription_status.';

alter table public.app_entitlements enable row level security;
revoke all on public.app_entitlements from public, anon, authenticated;
grant all on public.app_entitlements to service_role;

create index app_entitlements_active_idx
  on public.app_entitlements (tier, expires_at)
  where tier = 'paid';

create table public.ai_usage_ledger (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null unique,
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'reserved',
  cohort text not null,
  intent text not null,
  requested_alias text,
  model_role text not null,
  resolved_model text not null,
  reasoning_effort text,
  reservation_microusd bigint not null default 0,
  actual_cost_microusd bigint,
  input_tokens integer,
  cached_input_tokens integer,
  output_tokens integer,
  tool_calls jsonb not null default '{}'::jsonb,
  failure_code text,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint ai_usage_ledger_status_check
    check (status in ('reserved', 'succeeded', 'failed')),
  constraint ai_usage_ledger_cohort_check
    check (cohort in ('anonymous', 'free', 'paid')),
  constraint ai_usage_ledger_intent_check
    check (intent in ('primary_chat', 'lightweight', 'title', 'research')),
  constraint ai_usage_ledger_model_role_check
    check (model_role in ('nano', 'luna', 'sol', 'research', 'realtime')),
  constraint ai_usage_ledger_nonnegative_reservation
    check (reservation_microusd >= 0),
  constraint ai_usage_ledger_nonnegative_actual
    check (actual_cost_microusd is null or actual_cost_microusd >= 0),
  constraint ai_usage_ledger_tool_calls_object
    check (jsonb_typeof(tool_calls) = 'object')
);

alter table public.ai_usage_ledger enable row level security;
revoke all on public.ai_usage_ledger from public, anon, authenticated;
grant all on public.ai_usage_ledger to service_role;

create index ai_usage_ledger_user_created_idx
  on public.ai_usage_ledger (user_id, created_at desc);
create index ai_usage_ledger_budget_idx
  on public.ai_usage_ledger (user_id, model_role, status, created_at desc);

alter table public.openai_proxy_requests
  add column if not exists intent text,
  add column if not exists model_role text,
  add column if not exists reasoning_effort text,
  add column if not exists latency_ms integer,
  add column if not exists time_to_first_token_ms integer,
  add column if not exists cached_input_tokens integer,
  add column if not exists estimated_cost_microusd bigint,
  add column if not exists actual_cost_microusd bigint,
  add column if not exists usage_ledger_id uuid
    references public.ai_usage_ledger(id) on delete set null;

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
  if (select auth.role()) is distinct from 'service_role' then
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
        and status in ('reserved', 'succeeded')
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

create or replace function public.reconcile_ai_usage(
  p_request_id uuid,
  p_succeeded boolean,
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
  if (select auth.role()) is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  update public.ai_usage_ledger
  set
    status = case when p_succeeded then 'succeeded' else 'failed' end,
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
  uuid, boolean, integer, integer, integer, bigint, text
) from public, anon, authenticated;

grant execute on function public.reserve_ai_usage(
  uuid, uuid, text, text, text, text, text, text,
  bigint, bigint, bigint, integer
) to service_role;
grant execute on function public.reconcile_ai_usage(
  uuid, boolean, integer, integer, integer, bigint, text
) to service_role;
