-- M5 Realtime voice beta. Long-lived provider credentials stay in Supabase;
-- Flutter receives only an expiring client secret after this server-owned
-- rollout, entitlement, concurrency, and daily-start reservation succeeds.

update public.feature_flags
set enabled = true,
    payload = jsonb_build_object(
      'mode', 'internal',
      'model', 'gpt-realtime-2.1',
      'default_voice', 'marin',
      'allowed_voices', jsonb_build_array('marin', 'cedar'),
      'anonymous_daily_sessions', 2,
      'free_daily_sessions', 3,
      'paid_daily_sessions', 20,
      'anonymous_max_session_seconds', 120,
      'free_max_session_seconds', 240,
      'paid_max_session_seconds', 600
    ),
    updated_at = now()
where key = 'realtime_voice';

create table public.realtime_voice_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  cohort text not null,
  provider text not null default 'openai',
  model text not null,
  voice text not null,
  status text not null default 'active',
  max_duration_seconds integer not null,
  duration_seconds integer,
  client_secret_expires_at timestamptz,
  started_at timestamptz not null default now(),
  expires_at timestamptz not null,
  ended_at timestamptz,
  end_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint realtime_voice_sessions_cohort_check
    check (cohort in ('anonymous', 'free', 'paid')),
  constraint realtime_voice_sessions_provider_check
    check (provider = 'openai'),
  constraint realtime_voice_sessions_status_check
    check (status in ('active', 'completed', 'failed', 'expired')),
  constraint realtime_voice_sessions_model_length
    check (char_length(model) between 1 and 100),
  constraint realtime_voice_sessions_voice_length
    check (char_length(voice) between 1 and 50),
  constraint realtime_voice_sessions_max_duration_check
    check (max_duration_seconds between 30 and 3600),
  constraint realtime_voice_sessions_duration_check
    check (
      duration_seconds is null
      or duration_seconds between 0 and max_duration_seconds
    ),
  constraint realtime_voice_sessions_expiry_order
    check (expires_at > started_at),
  constraint realtime_voice_sessions_end_order
    check (ended_at is null or ended_at >= started_at)
);

comment on table public.realtime_voice_sessions is
  'Server-owned Realtime voice reservations and safe operational metadata. Client secrets and transcripts are never stored.';

alter table public.realtime_voice_sessions enable row level security;
revoke all on public.realtime_voice_sessions from public, anon, authenticated;
grant select on public.realtime_voice_sessions to authenticated;
grant all on public.realtime_voice_sessions to service_role;

create policy "Users can read their own Realtime voice sessions"
  on public.realtime_voice_sessions
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create index realtime_voice_sessions_user_started_idx
  on public.realtime_voice_sessions (user_id, started_at desc);

create unique index realtime_voice_sessions_one_active_per_user_idx
  on public.realtime_voice_sessions (user_id)
  where status = 'active';

create or replace function public.reserve_realtime_voice_session(
  p_user_id uuid,
  p_cohort text,
  p_model text,
  p_voice text,
  p_max_duration_seconds integer,
  p_daily_session_limit integer
)
returns table (accepted boolean, session_id uuid, reason text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_recent_starts integer;
  v_session_id uuid;
begin
  if (select auth.role()) is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;

  if p_cohort not in ('anonymous', 'free', 'paid')
    or p_max_duration_seconds not between 30 and 3600
    or p_daily_session_limit not between 1 and 100 then
    raise exception 'invalid Realtime reservation policy'
      using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('realtime:' || p_user_id::text, 0)
  );

  update public.realtime_voice_sessions
  set status = 'expired',
      ended_at = coalesce(ended_at, pg_catalog.now()),
      end_reason = coalesce(end_reason, 'reservation_expired'),
      updated_at = pg_catalog.now()
  where user_id = p_user_id
    and status = 'active'
    and expires_at <= pg_catalog.now();

  if exists (
    select 1
    from public.realtime_voice_sessions
    where user_id = p_user_id
      and status = 'active'
  ) then
    return query select false, null::uuid, 'active_session';
    return;
  end if;

  select count(*)
  into v_recent_starts
  from public.realtime_voice_sessions
  where user_id = p_user_id
    and started_at >= pg_catalog.now() - interval '24 hours'
    and status in ('active', 'completed', 'expired');

  if v_recent_starts >= p_daily_session_limit then
    return query select false, null::uuid, 'daily_session_limit';
    return;
  end if;

  insert into public.realtime_voice_sessions (
    user_id,
    cohort,
    model,
    voice,
    max_duration_seconds,
    expires_at
  )
  values (
    p_user_id,
    p_cohort,
    p_model,
    p_voice,
    p_max_duration_seconds,
    pg_catalog.now() + pg_catalog.make_interval(secs => p_max_duration_seconds)
  )
  returning id into v_session_id;

  return query select true, v_session_id, null::text;
end
$$;

revoke all on function public.reserve_realtime_voice_session(
  uuid, text, text, text, integer, integer
) from public, anon, authenticated;
grant execute on function public.reserve_realtime_voice_session(
  uuid, text, text, text, integer, integer
) to service_role;
