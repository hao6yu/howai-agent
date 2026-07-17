-- Track the opaque OpenAI call id so a replacement session can terminate a
-- provider transport that survived on another client after the app lost its
-- local session state.

alter table public.realtime_voice_sessions
  add column provider_call_id text;

alter table public.realtime_voice_sessions
  add constraint realtime_voice_sessions_provider_call_id_check
  check (
    provider_call_id is null
    or provider_call_id ~ '^rtc_[A-Za-z0-9_-]{1,180}$'
  );

create unique index realtime_voice_sessions_provider_call_id_idx
  on public.realtime_voice_sessions (provider_call_id)
  where provider_call_id is not null;

comment on column public.realtime_voice_sessions.provider_call_id is
  'Opaque OpenAI Realtime call id used only for server-side hangup and operational correlation.';

create or replace function public.reserve_realtime_voice_session_v2(
  p_user_id uuid,
  p_cohort text,
  p_model text,
  p_voice text,
  p_max_duration_seconds integer,
  p_daily_session_limit integer
)
returns table (
  accepted boolean,
  session_id uuid,
  reason text,
  superseded_provider_call_id text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_recent_starts integer;
  v_session_id uuid;
  v_superseded_provider_call_id text;
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

  select provider_call_id
  into v_superseded_provider_call_id
  from public.realtime_voice_sessions
  where user_id = p_user_id
    and status = 'active'
  order by started_at desc
  limit 1
  for update;

  select count(*)
  into v_recent_starts
  from public.realtime_voice_sessions
  where user_id = p_user_id
    and started_at >= pg_catalog.now() - interval '24 hours'
    and status in ('active', 'completed', 'expired');

  if v_recent_starts >= p_daily_session_limit then
    return query
      select false, null::uuid, 'daily_session_limit', null::text;
    return;
  end if;

  update public.realtime_voice_sessions
  set status = 'expired',
      ended_at = pg_catalog.now(),
      end_reason = 'superseded_by_new_session',
      updated_at = pg_catalog.now()
  where user_id = p_user_id
    and status = 'active';

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

  return query
    select true, v_session_id, null::text, v_superseded_provider_call_id;
end
$$;

revoke all on function public.reserve_realtime_voice_session_v2(
  uuid, text, text, text, integer, integer
) from public, anon, authenticated;
grant execute on function public.reserve_realtime_voice_session_v2(
  uuid, text, text, text, integer, integer
) to service_role;
