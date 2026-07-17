-- A crashed or abandoned client cannot explicitly finalize its reservation.
-- Starting a new voice call is therefore an explicit takeover: atomically
-- retire the previous active reservation before reserving the replacement.

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

  update public.realtime_voice_sessions
  set status = 'expired',
      ended_at = pg_catalog.now(),
      end_reason = 'superseded_by_new_session',
      updated_at = pg_catalog.now()
  where user_id = p_user_id
    and status = 'active';

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
