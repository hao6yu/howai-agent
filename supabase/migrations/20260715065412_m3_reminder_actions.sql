-- M3 Actions beta: server-owned reminder proposals and reminder state.
--
-- Authenticated clients may read their own rows, but every mutation goes
-- through the JWT-protected reminder-actions Edge Function and the atomic,
-- service-only execute_reminder_action RPC below.

update public.feature_flags
set
  description = 'Reminder and recurring-reminder agent actions',
  payload = payload || jsonb_build_object('mode', 'off'),
  updated_at = now()
where key = 'reminders';

create table public.agent_action_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  origin text not null,
  action_type text not null,
  arguments jsonb not null,
  human_summary text not null,
  warnings jsonb not null default '[]'::jsonb,
  status text not null default 'proposed',
  idempotency_key text not null,
  resource_type text,
  resource_id uuid,
  result jsonb not null default '{}'::jsonb,
  error_code text,
  error_message text,
  proposed_at timestamptz not null default now(),
  approved_at timestamptz,
  completed_at timestamptz,
  constraint agent_action_runs_origin_check
    check (origin in ('text', 'voice', 'notification', 'system')),
  constraint agent_action_runs_action_type_check
    check (action_type in (
      'reminders_create',
      'reminders_update',
      'reminders_complete',
      'reminders_snooze',
      'reminders_pause',
      'reminders_resume',
      'reminders_skip_next',
      'reminders_delete'
    )),
  constraint agent_action_runs_arguments_object
    check (jsonb_typeof(arguments) = 'object'),
  constraint agent_action_runs_warnings_array
    check (jsonb_typeof(warnings) = 'array'),
  constraint agent_action_runs_result_object
    check (jsonb_typeof(result) = 'object'),
  constraint agent_action_runs_summary_length
    check (char_length(btrim(human_summary)) between 1 and 500),
  constraint agent_action_runs_idempotency_length
    check (char_length(idempotency_key) between 8 and 200),
  constraint agent_action_runs_status_check
    check (status in (
      'proposed', 'approved', 'rejected', 'executing', 'succeeded', 'failed'
    )),
  constraint agent_action_runs_completion_order
    check (completed_at is null or completed_at >= proposed_at)
);

comment on table public.agent_action_runs is
  'Durable human-approval and execution audit for HowAI agent actions.';
comment on column public.agent_action_runs.arguments is
  'Server-validated normalized arguments; model output is never executed directly.';

alter table public.agent_action_runs enable row level security;
revoke all on public.agent_action_runs from public, anon, authenticated;
grant select on public.agent_action_runs to authenticated;
grant all on public.agent_action_runs to service_role;

create policy "Users can read their own action runs"
  on public.agent_action_runs
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create unique index agent_action_runs_user_idempotency_idx
  on public.agent_action_runs (user_id, idempotency_key);
create index agent_action_runs_user_status_proposed_idx
  on public.agent_action_runs (user_id, proposed_at desc)
  where status = 'proposed';
create index agent_action_runs_conversation_idx
  on public.agent_action_runs (conversation_id, proposed_at desc)
  where conversation_id is not null;

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete set null,
  action_run_id uuid unique references public.agent_action_runs(id) on delete set null,
  title text not null,
  notes text,
  timezone text not null,
  start_local timestamp without time zone not null,
  next_fire_at timestamptz not null,
  recurrence_rule jsonb,
  status text not null default 'active',
  version integer not null default 1,
  last_fired_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reminders_title_length
    check (char_length(btrim(title)) between 1 and 200),
  constraint reminders_notes_length
    check (notes is null or char_length(notes) <= 4000),
  constraint reminders_timezone_length
    check (char_length(timezone) between 1 and 128),
  constraint reminders_timezone_shape
    check (timezone = 'UTC' or timezone ~ '^[A-Za-z0-9._+-]+(/[A-Za-z0-9._+-]+)+$'),
  constraint reminders_recurrence_object
    check (recurrence_rule is null or jsonb_typeof(recurrence_rule) = 'object'),
  constraint reminders_recurrence_frequency
    check (
      recurrence_rule is null
      or recurrence_rule ->> 'frequency' in ('daily', 'weekly', 'monthly')
    ),
  constraint reminders_status_check
    check (status in ('active', 'paused', 'completed')),
  constraint reminders_version_positive
    check (version > 0),
  constraint reminders_completion_state
    check ((status = 'completed') = (completed_at is not null)),
  constraint reminders_updated_order
    check (updated_at >= created_at)
);

comment on table public.reminders is
  'Server-owned reminders. Local wall-clock intent is stored with an IANA timezone and an independently computed UTC fire instant.';
comment on column public.reminders.start_local is
  'Wall-clock time intentionally stored without an offset; timezone supplies the IANA location.';
comment on column public.reminders.recurrence_rule is
  'Validated structured recurrence, never an arbitrary cron expression.';

alter table public.reminders enable row level security;
revoke all on public.reminders from public, anon, authenticated;
grant select on public.reminders to authenticated;
grant all on public.reminders to service_role;

create policy "Users can read their own reminders"
  on public.reminders
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create index reminders_user_status_next_fire_idx
  on public.reminders (user_id, status, next_fire_at);
create index reminders_conversation_idx
  on public.reminders (conversation_id)
  where conversation_id is not null;
create index reminders_due_idx
  on public.reminders (next_fire_at, id)
  where status = 'active';

create function public.execute_reminder_action(
  p_action_run_id uuid,
  p_user_id uuid,
  p_execution jsonb
)
returns table (
  action_run_id uuid,
  action_status text,
  resource_type text,
  resource_id uuid,
  resource_version integer
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_run public.agent_action_runs%rowtype;
  v_reminder_id uuid;
  v_reminder_version integer;
  v_expected_version integer;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_action_run_id is null
    or p_user_id is null
    or p_execution is null
    or jsonb_typeof(p_execution) <> 'object' then
    raise exception 'valid action execution values are required'
      using errcode = '22023';
  end if;

  select *
  into v_run
  from public.agent_action_runs
  where id = p_action_run_id
    and user_id = p_user_id
  for update;

  if not found then
    raise exception 'action proposal not found' using errcode = 'P0002';
  end if;

  if v_run.status = 'succeeded' then
    return query select
      v_run.id,
      v_run.status,
      v_run.resource_type,
      v_run.resource_id,
      case
        when v_run.result ->> 'resource_version' ~ '^[0-9]+$'
          then (v_run.result ->> 'resource_version')::integer
        else null::integer
      end;
    return;
  end if;

  if v_run.status <> 'proposed' then
    raise exception 'action proposal is not awaiting approval'
      using errcode = '55000';
  end if;

  update public.agent_action_runs
  set status = 'executing', approved_at = pg_catalog.now()
  where id = v_run.id;

  if v_run.action_type = 'reminders_create' then
    insert into public.reminders (
      user_id,
      conversation_id,
      action_run_id,
      title,
      notes,
      timezone,
      start_local,
      next_fire_at,
      recurrence_rule
    ) values (
      p_user_id,
      v_run.conversation_id,
      v_run.id,
      p_execution ->> 'title',
      nullif(p_execution ->> 'notes', ''),
      p_execution ->> 'timezone',
      (p_execution ->> 'start_local')::timestamp,
      (p_execution ->> 'next_fire_at')::timestamptz,
      case
        when p_execution -> 'recurrence' = 'null'::jsonb then null
        else p_execution -> 'recurrence'
      end
    )
    returning id, version into v_reminder_id, v_reminder_version;
  else
    v_reminder_id := (p_execution ->> 'reminder_id')::uuid;
    v_expected_version := (p_execution ->> 'expected_version')::integer;

    if v_run.action_type = 'reminders_update' then
      update public.reminders
      set
        title = p_execution ->> 'title',
        notes = nullif(p_execution ->> 'notes', ''),
        timezone = p_execution ->> 'timezone',
        start_local = (p_execution ->> 'start_local')::timestamp,
        next_fire_at = (p_execution ->> 'next_fire_at')::timestamptz,
        recurrence_rule = case
          when p_execution -> 'recurrence' = 'null'::jsonb then null
          else p_execution -> 'recurrence'
        end,
        status = 'active',
        completed_at = null,
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
      returning version into v_reminder_version;
    elsif v_run.action_type = 'reminders_complete' then
      update public.reminders
      set
        status = 'completed',
        completed_at = pg_catalog.now(),
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
        and status <> 'completed'
      returning version into v_reminder_version;
    elsif v_run.action_type = 'reminders_snooze' then
      update public.reminders
      set
        next_fire_at = (p_execution ->> 'next_fire_at')::timestamptz,
        status = 'active',
        completed_at = null,
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
      returning version into v_reminder_version;
    elsif v_run.action_type = 'reminders_pause' then
      update public.reminders
      set
        status = 'paused',
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
        and status = 'active'
      returning version into v_reminder_version;
    elsif v_run.action_type = 'reminders_resume' then
      update public.reminders
      set
        status = 'active',
        next_fire_at = (p_execution ->> 'next_fire_at')::timestamptz,
        completed_at = null,
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
        and status = 'paused'
      returning version into v_reminder_version;
    elsif v_run.action_type = 'reminders_skip_next' then
      update public.reminders
      set
        next_fire_at = (p_execution ->> 'next_fire_at')::timestamptz,
        version = version + 1,
        updated_at = pg_catalog.now()
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
        and status = 'active'
        and recurrence_rule is not null
      returning version into v_reminder_version;
    elsif v_run.action_type = 'reminders_delete' then
      delete from public.reminders
      where id = v_reminder_id
        and user_id = p_user_id
        and version = v_expected_version
      returning version into v_reminder_version;
    else
      raise exception 'unsupported reminder action' using errcode = '22023';
    end if;

    if not found then
      raise exception 'reminder changed or is no longer available'
        using errcode = '40001';
    end if;
  end if;

  update public.agent_action_runs
  set
    status = 'succeeded',
    resource_type = 'reminder',
    resource_id = v_reminder_id,
    result = jsonb_build_object('resource_version', v_reminder_version),
    completed_at = pg_catalog.now(),
    error_code = null,
    error_message = null
  where id = v_run.id
  returning * into v_run;

  return query select
    v_run.id,
    v_run.status,
    v_run.resource_type,
    v_run.resource_id,
    v_reminder_version;
end;
$$;

revoke all on function public.execute_reminder_action(uuid, uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.execute_reminder_action(uuid, uuid, jsonb)
  to service_role;
