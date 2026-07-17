begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(24);

select has_table(
  'public',
  'realtime_voice_sessions',
  'Realtime voice session ledger exists'
);
select is(
  (select payload ->> 'mode' from public.feature_flags where key = 'realtime_voice'),
  'internal',
  'Realtime voice begins with the internal rollout'
);
select is(
  (select payload ->> 'model' from public.feature_flags where key = 'realtime_voice'),
  'gpt-realtime-2.1',
  'the Realtime model is server-configured'
);
select ok(
  (
    select relrowsecurity
    from pg_catalog.pg_class
    where oid = 'public.realtime_voice_sessions'::regclass
  ),
  'Realtime voice sessions have RLS enabled'
);
select is(
  has_table_privilege('authenticated', 'public.realtime_voice_sessions', 'select'),
  true,
  'authenticated users can read their own safe session metadata'
);
select is(
  has_table_privilege('authenticated', 'public.realtime_voice_sessions', 'insert'),
  false,
  'authenticated users cannot create session reservations directly'
);
select is(
  has_table_privilege('authenticated', 'public.realtime_voice_sessions', 'update'),
  false,
  'authenticated users cannot finalize reservations directly'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.reserve_realtime_voice_session(uuid,text,text,text,integer,integer)',
    'execute'
  ),
  false,
  'authenticated clients cannot bypass the broker reservation policy'
);
select is(
  has_function_privilege(
    'service_role',
    'public.reserve_realtime_voice_session(uuid,text,text,text,integer,integer)',
    'execute'
  ),
  true,
  'the Edge Function service role can reserve sessions'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.reserve_realtime_voice_session_v2(uuid,text,text,text,integer,integer)',
    'execute'
  ),
  false,
  'authenticated clients cannot call the provider-aware reservation directly'
);
select is(
  has_function_privilege(
    'service_role',
    'public.reserve_realtime_voice_session_v2(uuid,text,text,text,integer,integer)',
    'execute'
  ),
  true,
  'the Edge Function can reserve a provider-aware replacement session'
);
select ok(
  to_regclass('public.realtime_voice_sessions_user_started_idx') is not null,
  'daily session-start lookups are indexed'
);
select ok(
  to_regclass('public.realtime_voice_sessions_one_active_per_user_idx') is not null,
  'one-active-session enforcement is indexed and unique'
);

insert into auth.users (id, aud, role, email)
values
  (
    '15000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'm5-user@example.test'
  );

set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);

create temporary table first_reservation as
select *
from public.reserve_realtime_voice_session_v2(
  '15000000-0000-4000-8000-000000000001',
  'free',
  'gpt-realtime-2.1',
  'marin',
  240,
  1
);

select is(
  (select accepted from first_reservation),
  true,
  'the first policy-approved session is reserved'
);
select isnt(
  (select session_id from first_reservation),
  null::uuid,
  'the reservation returns a server-generated session id'
);
select is(
  (
    select max_duration_seconds
    from public.realtime_voice_sessions
    where id = (select session_id from first_reservation)
  ),
  240,
  'the server-owned maximum duration is persisted'
);

update public.realtime_voice_sessions
set provider_call_id = 'rtc_test_first',
    updated_at = now()
where id = (select session_id from first_reservation);

create temporary table replacement_reservation as
select *
from public.reserve_realtime_voice_session_v2(
  '15000000-0000-4000-8000-000000000001',
  'free',
  'gpt-realtime-2.1',
  'cedar',
  240,
  10
);

select is(
  (select accepted from replacement_reservation),
  true,
  'a new call takes over an abandoned active reservation'
);
select isnt(
  (select session_id from replacement_reservation),
  (select session_id from first_reservation),
  'the takeover receives a distinct reservation id'
);
select is(
  (select superseded_provider_call_id from replacement_reservation),
  'rtc_test_first',
  'the takeover returns the prior provider call id for server-side hangup'
);
select is(
  (
    select status || ':' || end_reason
    from public.realtime_voice_sessions
    where id = (select session_id from first_reservation)
  ),
  'expired:superseded_by_new_session',
  'the previous active reservation is retired with an auditable reason'
);

update public.realtime_voice_sessions
set status = 'completed',
    duration_seconds = 30,
    ended_at = now(),
    updated_at = now()
where id = (select session_id from replacement_reservation);

select is(
  (
    select reason
    from public.reserve_realtime_voice_session_v2(
      '15000000-0000-4000-8000-000000000001',
      'free',
      'gpt-realtime-2.1',
      'marin',
      240,
      1
    )
  ),
  'daily_session_limit',
  'the rolling daily session-start quota is enforced'
);
select throws_ok(
  $$select * from public.reserve_realtime_voice_session_v2(
      '15000000-0000-4000-8000-000000000001',
      'free',
      'gpt-realtime-2.1',
      'marin',
      10,
      1
    )$$,
  '22023',
  'invalid Realtime reservation policy',
  'unsafe duration policy cannot be reserved'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'realtime_voice_sessions'
      and column_name ilike '%secret%'
  ),
  1::bigint,
  'only the client-secret expiry timestamp is stored, never the secret value'
);
select is(
  (
    select data_type
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'realtime_voice_sessions'
      and column_name = 'client_secret_expires_at'
  ),
  'timestamp with time zone',
  'the harmless client-secret expiry uses a timezone-safe timestamp'
);

select * from finish();
rollback;
