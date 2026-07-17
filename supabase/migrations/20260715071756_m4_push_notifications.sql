-- M4 reminder delivery: private device tokens, deduplicated occurrences,
-- retry-safe delivery claims, and a minute-level Edge Function scheduler.

create extension if not exists pg_net;
create extension if not exists pg_cron;

update public.feature_flags
set
  description = 'Firebase remote notification delivery for reminders',
  payload = payload || jsonb_build_object('mode', 'off'),
  updated_at = now()
where key = 'push_notifications';

create table public.push_devices (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null,
  timezone text not null,
  locale text,
  app_version text,
  last_seen_at timestamptz not null default now(),
  disabled_at timestamptz,
  invalid_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint push_devices_platform_check
    check (platform in ('android', 'ios')),
  constraint push_devices_token_length
    check (char_length(token) between 20 and 4096),
  constraint push_devices_timezone_length
    check (char_length(timezone) between 1 and 128),
  constraint push_devices_locale_length
    check (locale is null or char_length(locale) between 2 and 32),
  constraint push_devices_app_version_length
    check (app_version is null or char_length(app_version) between 1 and 64),
  constraint push_devices_invalid_reason_length
    check (invalid_reason is null or char_length(invalid_reason) <= 200),
  constraint push_devices_updated_order
    check (updated_at >= created_at)
);

comment on table public.push_devices is
  'Private FCM registration tokens owned by signed-in users. Client access is only through the push-devices Edge Function.';

alter table public.push_devices enable row level security;
revoke all on public.push_devices from public, anon, authenticated;
grant all on public.push_devices to service_role;

create index push_devices_user_active_idx
  on public.push_devices (user_id, last_seen_at desc)
  where disabled_at is null;

alter table public.reminders
  add column last_delivery_status text,
  add column last_delivery_at timestamptz,
  add constraint reminders_last_delivery_status_check
    check (
      last_delivery_status is null
      or last_delivery_status in (
        'sent', 'partial', 'no_devices', 'failed'
      )
    );

create table public.reminder_deliveries (
  id uuid primary key default gen_random_uuid(),
  reminder_id uuid not null references public.reminders(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  scheduled_for timestamptz not null,
  status text not null default 'pending',
  attempt_count smallint not null default 0,
  available_at timestamptz not null default now(),
  lease_expires_at timestamptz,
  provider_summary jsonb not null default '{}'::jsonb,
  sent_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reminder_deliveries_occurrence_unique
    unique (reminder_id, scheduled_for),
  constraint reminder_deliveries_status_check
    check (status in (
      'pending', 'processing', 'retrying',
      'sent', 'partial', 'no_devices', 'failed'
    )),
  constraint reminder_deliveries_attempt_count_check
    check (attempt_count between 0 and 10),
  constraint reminder_deliveries_provider_summary_object
    check (jsonb_typeof(provider_summary) = 'object'),
  constraint reminder_deliveries_completion_state
    check (
      (status in ('sent', 'partial', 'no_devices', 'failed'))
      = (completed_at is not null)
    ),
  constraint reminder_deliveries_updated_order
    check (updated_at >= created_at)
);

comment on table public.reminder_deliveries is
  'One durable delivery record per reminder occurrence. The uniqueness constraint is the primary duplicate-send guard.';

alter table public.reminder_deliveries enable row level security;
revoke all on public.reminder_deliveries from public, anon, authenticated;
grant all on public.reminder_deliveries to service_role;

create index reminder_deliveries_user_created_idx
  on public.reminder_deliveries (user_id, created_at desc);
create index reminder_deliveries_ready_idx
  on public.reminder_deliveries (available_at, created_at, id)
  where status in ('pending', 'retrying');
create index reminder_deliveries_stale_lease_idx
  on public.reminder_deliveries (lease_expires_at, id)
  where status = 'processing';

create table public.reminder_delivery_attempts (
  id bigint generated always as identity primary key,
  delivery_id uuid not null
    references public.reminder_deliveries(id) on delete cascade,
  push_device_id bigint not null
    references public.push_devices(id) on delete cascade,
  attempt_number smallint not null,
  status text not null,
  provider_message_id text,
  error_code text,
  error_message text,
  created_at timestamptz not null default now(),
  constraint reminder_delivery_attempts_unique
    unique (delivery_id, push_device_id, attempt_number),
  constraint reminder_delivery_attempts_number_check
    check (attempt_number between 1 and 10),
  constraint reminder_delivery_attempts_status_check
    check (status in ('sent', 'transient_failure', 'permanent_failure')),
  constraint reminder_delivery_attempts_message_id_length
    check (provider_message_id is null or char_length(provider_message_id) <= 500),
  constraint reminder_delivery_attempts_error_code_length
    check (error_code is null or char_length(error_code) <= 100),
  constraint reminder_delivery_attempts_error_message_length
    check (error_message is null or char_length(error_message) <= 500)
);

alter table public.reminder_delivery_attempts enable row level security;
revoke all on public.reminder_delivery_attempts from public, anon, authenticated;
grant all on public.reminder_delivery_attempts to service_role;

create index reminder_delivery_attempts_device_idx
  on public.reminder_delivery_attempts (push_device_id, created_at desc);
create index reminder_delivery_attempts_delivery_sent_idx
  on public.reminder_delivery_attempts (delivery_id, push_device_id)
  where status = 'sent';

create function public.claim_due_reminder_deliveries(
  p_limit integer default 25
)
returns table (
  delivery_id uuid,
  reminder_id uuid,
  user_id uuid,
  title text,
  notes text,
  timezone text,
  start_local timestamp without time zone,
  scheduled_for timestamptz,
  recurrence_rule jsonb,
  attempt_number smallint
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_enabled boolean;
  v_mode text;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;
  if p_limit < 1 or p_limit > 100 then
    raise exception 'p_limit must be between 1 and 100'
      using errcode = '22023';
  end if;

  select enabled, payload ->> 'mode'
  into v_enabled, v_mode
  from public.feature_flags
  where key = 'push_notifications';

  if not coalesce(v_enabled, false)
    or v_mode not in ('internal', 'full') then
    return;
  end if;

  with due as materialized (
    select r.id, r.user_id, r.next_fire_at
    from public.reminders r
    where r.status = 'active'
      and r.next_fire_at <= pg_catalog.now()
      and (
        v_mode = 'full'
        or exists (
          select 1
          from public.app_entitlements e
          where e.user_id = r.user_id
            and e.model_policy_canary = true
        )
      )
      and not exists (
        select 1
        from public.reminder_deliveries existing
        where existing.reminder_id = r.id
          and existing.scheduled_for = r.next_fire_at
      )
    order by r.next_fire_at, r.id
    limit p_limit
    for update of r skip locked
  )
  insert into public.reminder_deliveries (
    reminder_id,
    user_id,
    scheduled_for
  )
  select due.id, due.user_id, due.next_fire_at
  from due
  on conflict on constraint reminder_deliveries_occurrence_unique do nothing;

  return query
  with candidates as materialized (
    select d.id
    from public.reminder_deliveries d
    where (
      (
        d.status in ('pending', 'retrying')
        and d.available_at <= pg_catalog.now()
      )
      or (
        d.status = 'processing'
        and d.lease_expires_at <= pg_catalog.now()
      )
    )
      and d.attempt_count < 5
    order by d.available_at, d.created_at, d.id
    limit p_limit
    for update of d skip locked
  ), claimed as (
    update public.reminder_deliveries d
    set
      status = 'processing',
      attempt_count = d.attempt_count + 1,
      lease_expires_at = pg_catalog.now() + interval '2 minutes',
      updated_at = pg_catalog.now()
    from candidates c
    where d.id = c.id
    returning d.*
  )
  select
    c.id,
    r.id,
    r.user_id,
    r.title,
    r.notes,
    r.timezone,
    r.start_local,
    c.scheduled_for,
    r.recurrence_rule,
    c.attempt_count
  from claimed c
  join public.reminders r on r.id = c.reminder_id
  order by c.scheduled_for, c.id;
end;
$$;

comment on function public.claim_due_reminder_deliveries(integer) is
  'Atomically creates occurrence records and briefly leases ready deliveries without holding locks during FCM calls.';

revoke all on function public.claim_due_reminder_deliveries(integer)
  from public, anon, authenticated;
grant execute on function public.claim_due_reminder_deliveries(integer)
  to service_role;

create function public.retry_reminder_delivery(
  p_delivery_id uuid,
  p_delay_seconds integer,
  p_summary jsonb
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;
  if p_delay_seconds < 5 or p_delay_seconds > 3600
    or p_summary is null
    or jsonb_typeof(p_summary) <> 'object' then
    raise exception 'invalid retry values' using errcode = '22023';
  end if;

  update public.reminder_deliveries
  set
    status = 'retrying',
    available_at = pg_catalog.now()
      + pg_catalog.make_interval(secs => p_delay_seconds),
    lease_expires_at = null,
    provider_summary = p_summary,
    updated_at = pg_catalog.now()
  where id = p_delivery_id
    and status = 'processing';

  return found;
end;
$$;

revoke all on function public.retry_reminder_delivery(uuid,integer,jsonb)
  from public, anon, authenticated;
grant execute on function public.retry_reminder_delivery(uuid,integer,jsonb)
  to service_role;

create function public.finish_reminder_delivery(
  p_delivery_id uuid,
  p_outcome text,
  p_summary jsonb,
  p_next_fire_at timestamptz default null
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_delivery public.reminder_deliveries%rowtype;
begin
  if (select auth.jwt() ->> 'role') is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;
  if p_outcome not in ('sent', 'partial', 'no_devices', 'failed')
    or p_summary is null
    or jsonb_typeof(p_summary) <> 'object'
    or (p_next_fire_at is not null and p_next_fire_at <= pg_catalog.now() - interval '1 minute') then
    raise exception 'invalid completion values' using errcode = '22023';
  end if;

  select *
  into v_delivery
  from public.reminder_deliveries
  where id = p_delivery_id
  for update;

  if not found then
    return false;
  end if;
  if v_delivery.status in ('sent', 'partial', 'no_devices', 'failed') then
    return true;
  end if;
  if v_delivery.status <> 'processing' then
    return false;
  end if;

  update public.reminder_deliveries
  set
    status = p_outcome,
    provider_summary = p_summary,
    sent_at = case
      when p_outcome in ('sent', 'partial') then pg_catalog.now()
      else null
    end,
    completed_at = pg_catalog.now(),
    lease_expires_at = null,
    updated_at = pg_catalog.now()
  where id = v_delivery.id;

  if p_next_fire_at is null then
    update public.reminders
    set
      status = 'completed',
      completed_at = pg_catalog.now(),
      last_fired_at = v_delivery.scheduled_for,
      last_delivery_status = p_outcome,
      last_delivery_at = pg_catalog.now(),
      version = version + 1,
      updated_at = pg_catalog.now()
    where id = v_delivery.reminder_id
      and status = 'active'
      and next_fire_at = v_delivery.scheduled_for;
  else
    update public.reminders
    set
      next_fire_at = p_next_fire_at,
      last_fired_at = v_delivery.scheduled_for,
      last_delivery_status = p_outcome,
      last_delivery_at = pg_catalog.now(),
      version = version + 1,
      updated_at = pg_catalog.now()
    where id = v_delivery.reminder_id
      and status = 'active'
      and next_fire_at = v_delivery.scheduled_for;
  end if;

  return true;
end;
$$;

revoke all on function public.finish_reminder_delivery(uuid,text,jsonb,timestamptz)
  from public, anon, authenticated;
grant execute on function public.finish_reminder_delivery(uuid,text,jsonb,timestamptz)
  to service_role;

-- These two Vault entries are populated during deployment. Keeping their
-- values out of migrations prevents production credentials from entering git.
select cron.schedule(
  'howai-dispatch-reminders',
  '* * * * *',
  $schedule$
    select net.http_post(
      url := secrets.project_url || '/functions/v1/dispatch-reminders',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'x-howai-cron-secret', secrets.dispatch_secret
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 10000
    )
    from (
      select
        max(decrypted_secret) filter (
          where name = 'howai_project_url'
        ) as project_url,
        max(decrypted_secret) filter (
          where name = 'howai_reminder_dispatch_secret'
        ) as dispatch_secret
      from vault.decrypted_secrets
    ) secrets
    where secrets.project_url is not null
      and secrets.dispatch_secret is not null;
  $schedule$
);
