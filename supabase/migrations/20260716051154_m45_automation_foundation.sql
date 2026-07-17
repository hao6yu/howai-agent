-- M4.5 Automations foundation: additive user-owned templates and durable run
-- history. Nothing in this migration schedules or executes work; all rollout
-- flags default off and mutations remain service-owned.

insert into public.feature_flags (key, enabled, description, payload)
values
  (
    'automations',
    false,
    'Generated news and market briefing Automations',
    '{"mode":"off"}'::jsonb
  ),
  (
    'automation_web_retrieval',
    false,
    'Web retrieval for generated Automation runs',
    '{"mode":"off"}'::jsonb
  ),
  (
    'automation_validation',
    false,
    'Claim and source validation for generated Automation runs',
    '{"mode":"off"}'::jsonb
  ),
  (
    'automation_market_data',
    false,
    'Structured market data for market briefing Automations',
    '{"mode":"off"}'::jsonb
  ),
  (
    'automation_notifications',
    false,
    'Firebase delivery for completed Automation runs',
    '{"mode":"off"}'::jsonb
  )
on conflict (key) do nothing;

alter table public.agent_action_runs
  drop constraint agent_action_runs_action_type_check;

alter table public.agent_action_runs
  add constraint agent_action_runs_action_type_check
  check (action_type in (
    'reminders_create',
    'reminders_update',
    'reminders_complete',
    'reminders_snooze',
    'reminders_pause',
    'reminders_resume',
    'reminders_skip_next',
    'reminders_delete',
    'automations_create',
    'automations_update',
    'automations_pause',
    'automations_resume',
    'automations_run_now',
    'automations_delete'
  ));

create table public.automations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  action_run_id uuid unique
    references public.agent_action_runs(id) on delete set null,
  kind text not null,
  title text not null,
  status text not null default 'active',
  version integer not null default 1,
  timezone text not null,
  schedule_rule jsonb not null,
  next_run_at timestamptz not null,
  config jsonb not null,
  source_policy jsonb not null default '{}'::jsonb,
  delivery_preferences jsonb not null default '{"push":true}'::jsonb,
  required_tier text not null default 'paid',
  last_run_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint automations_id_user_unique unique (id, user_id),
  constraint automations_kind_check
    check (kind in ('news_briefing', 'market_briefing')),
  constraint automations_title_length
    check (char_length(btrim(title)) between 1 and 200),
  constraint automations_status_check
    check (status in ('active', 'paused')),
  constraint automations_version_positive
    check (version > 0),
  constraint automations_timezone_length
    check (char_length(timezone) between 1 and 128),
  constraint automations_timezone_shape
    check (
      timezone = 'UTC'
      or timezone ~ '^[A-Za-z0-9._+-]+(/[A-Za-z0-9._+-]+)+$'
    ),
  constraint automations_schedule_object
    check (jsonb_typeof(schedule_rule) = 'object'),
  constraint automations_schedule_frequency
    check (
      schedule_rule ->> 'frequency' in ('daily', 'weekly', 'market_days')
    ),
  constraint automations_config_object
    check (jsonb_typeof(config) = 'object'),
  constraint automations_source_policy_object
    check (jsonb_typeof(source_policy) = 'object'),
  constraint automations_delivery_preferences_object
    check (jsonb_typeof(delivery_preferences) = 'object'),
  constraint automations_required_tier_check
    check (required_tier = 'paid'),
  constraint automations_updated_order
    check (updated_at >= created_at)
);

comment on table public.automations is
  'Approved generated briefing templates. Existing reminders remain in public.reminders.';
comment on column public.automations.config is
  'Strict kind-specific configuration normalized by the service before approval.';
comment on column public.automations.source_policy is
  'User-visible source preferences that may narrow but never bypass server trust policy.';

alter table public.automations enable row level security;
revoke all on public.automations from public, anon, authenticated;
grant select on public.automations to authenticated;
grant all on public.automations to service_role;

create policy "Users can read their own automations"
  on public.automations
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create index automations_user_status_next_run_idx
  on public.automations (user_id, status, next_run_at);
create index automations_due_idx
  on public.automations (next_run_at, id)
  where status = 'active';
create index automations_conversation_idx
  on public.automations (conversation_id, created_at desc)
  where conversation_id is not null;

create trigger set_automation_updated_at
before update on public.automations
for each row execute function public.update_updated_at_column();

create table public.automation_runs (
  id uuid primary key default gen_random_uuid(),
  automation_id uuid not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  automation_version integer not null,
  scheduled_for timestamptz not null,
  trigger_type text not null default 'scheduled',
  status text not null default 'queued',
  template_snapshot jsonb not null,
  attempt_count smallint not null default 0,
  available_at timestamptz not null default now(),
  lease_expires_at timestamptz,
  generation_response_id text,
  verification_response_id text,
  generation_usage_ledger_id uuid
    references public.ai_usage_ledger(id) on delete set null,
  verification_usage_ledger_id uuid
    references public.ai_usage_ledger(id) on delete set null,
  report jsonb not null default '{}'::jsonb,
  preview text,
  claims jsonb not null default '[]'::jsonb,
  sources jsonb not null default '[]'::jsonb,
  verification jsonb not null default '{}'::jsonb,
  error_code text,
  error_message text,
  started_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint automation_runs_automation_owner_fk
    foreign key (automation_id, user_id)
    references public.automations(id, user_id) on delete cascade,
  constraint automation_runs_occurrence_unique
    unique (automation_id, scheduled_for),
  constraint automation_runs_version_positive
    check (automation_version > 0),
  constraint automation_runs_trigger_type_check
    check (trigger_type in ('scheduled', 'manual')),
  constraint automation_runs_status_check
    check (status in (
      'queued', 'running', 'verifying',
      'succeeded', 'withheld', 'failed', 'cancelled'
    )),
  constraint automation_runs_template_snapshot_object
    check (jsonb_typeof(template_snapshot) = 'object'),
  constraint automation_runs_attempt_count_check
    check (attempt_count between 0 and 10),
  constraint automation_runs_report_object
    check (jsonb_typeof(report) = 'object'),
  constraint automation_runs_claims_array
    check (jsonb_typeof(claims) = 'array'),
  constraint automation_runs_sources_array
    check (jsonb_typeof(sources) = 'array'),
  constraint automation_runs_verification_object
    check (jsonb_typeof(verification) = 'object'),
  constraint automation_runs_preview_length
    check (preview is null or char_length(preview) <= 500),
  constraint automation_runs_error_code_length
    check (error_code is null or char_length(error_code) <= 100),
  constraint automation_runs_error_message_length
    check (error_message is null or char_length(error_message) <= 500),
  constraint automation_runs_completion_state
    check (
      (status in ('succeeded', 'withheld', 'failed', 'cancelled'))
      = (completed_at is not null)
    ),
  constraint automation_runs_updated_order
    check (updated_at >= created_at)
);

comment on table public.automation_runs is
  'Durable scheduled or manual Automation occurrences, reports, sources, verification, and bounded failure state.';
comment on column public.automation_runs.sources is
  'Minimum durable source metadata used for attribution, verification, and reopening a report.';
comment on column public.automation_runs.claims is
  'Structured claims referencing source IDs; unverified claims are never delivered.';

alter table public.automation_runs enable row level security;
revoke all on public.automation_runs from public, anon, authenticated;
grant select on public.automation_runs to authenticated;
grant all on public.automation_runs to service_role;

create policy "Users can read their own automation runs"
  on public.automation_runs
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create index automation_runs_user_created_idx
  on public.automation_runs (user_id, created_at desc);
create index automation_runs_automation_created_idx
  on public.automation_runs (automation_id, created_at desc);
create index automation_runs_ready_idx
  on public.automation_runs (available_at, created_at, id)
  where status = 'queued';
create index automation_runs_stale_lease_idx
  on public.automation_runs (lease_expires_at, id)
  where status in ('running', 'verifying');

create trigger set_automation_run_updated_at
before update on public.automation_runs
for each row execute function public.update_updated_at_column();
