begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(33);

select is(
  (select payload ->> 'mode' from public.feature_flags where key = 'reminders'),
  'off',
  'reminders default to an off rollout mode'
);

select has_table('public', 'agent_action_runs', 'action audit table exists');
select has_table('public', 'reminders', 'reminders table exists');

select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.agent_action_runs'::regclass),
  'action audit has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.reminders'::regclass),
  'reminders have RLS enabled'
);

select is(
  has_table_privilege('authenticated', 'public.agent_action_runs', 'select'),
  true,
  'authenticated users may read action audits through RLS'
);
select is(
  has_table_privilege('authenticated', 'public.agent_action_runs', 'insert'),
  false,
  'authenticated users cannot insert action audits directly'
);
select is(
  has_table_privilege('authenticated', 'public.agent_action_runs', 'update'),
  false,
  'authenticated users cannot update action audits directly'
);
select is(
  has_table_privilege('authenticated', 'public.reminders', 'select'),
  true,
  'authenticated users may read reminders through RLS'
);
select is(
  has_table_privilege('authenticated', 'public.reminders', 'insert'),
  false,
  'authenticated users cannot insert reminders directly'
);
select is(
  has_table_privilege('authenticated', 'public.reminders', 'update'),
  false,
  'authenticated users cannot update reminders directly'
);
select is(
  has_table_privilege('service_role', 'public.agent_action_runs', 'insert'),
  true,
  'service role can create action audits'
);
select is(
  has_table_privilege('service_role', 'public.reminders', 'insert'),
  true,
  'service role can create reminders'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.execute_reminder_action(uuid,uuid,jsonb)',
    'execute'
  ),
  false,
  'authenticated clients cannot execute reminder actions'
);
select is(
  has_function_privilege(
    'service_role',
    'public.execute_reminder_action(uuid,uuid,jsonb)',
    'execute'
  ),
  true,
  'service role can execute approved reminder actions'
);
select ok(
  to_regclass('public.agent_action_runs_user_idempotency_idx') is not null,
  'action proposals have a per-user idempotency index'
);
select ok(
  to_regclass('public.reminders_user_status_next_fire_idx') is not null,
  'reminder list reads have a composite owner/status/time index'
);

insert into auth.users (id, aud, role, email)
values
  ('11000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'm3-user1@example.test'),
  ('11000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'm3-user2@example.test');

insert into public.conversations (id, user_id, title)
values
  (
    '21000000-0000-4000-8000-000000000001',
    '11000000-0000-4000-8000-000000000001',
    'M3 user one conversation'
  ),
  (
    '21000000-0000-4000-8000-000000000002',
    '11000000-0000-4000-8000-000000000002',
    'M3 user two conversation'
  );

insert into public.agent_action_runs (
  id, user_id, conversation_id, origin, action_type, arguments,
  human_summary, idempotency_key
) values (
  '31000000-0000-4000-8000-000000000001',
  '11000000-0000-4000-8000-000000000001',
  '21000000-0000-4000-8000-000000000001',
  'text',
  'reminders_create',
  jsonb_build_object(
    'title', 'Call Mom',
    'notes', null,
    'timezone', 'America/Chicago',
    'start_local', '2026-07-20T09:30:00',
    'next_fire_at', '2026-07-20T14:30:00.000Z',
    'recurrence', null
  ),
  'Remind me to call Mom',
  'm3-create-user1'
);

select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set local role service_role;

select lives_ok(
  $$select * from public.execute_reminder_action(
    '31000000-0000-4000-8000-000000000001',
    '11000000-0000-4000-8000-000000000001',
    '{
      "title":"Call Mom",
      "notes":null,
      "timezone":"America/Chicago",
      "start_local":"2026-07-20T09:30:00",
      "next_fire_at":"2026-07-20T14:30:00.000Z",
      "recurrence":null
    }'::jsonb
  )$$,
  'an approved create proposal executes atomically'
);
select is(
  (select count(*) from public.reminders where user_id = '11000000-0000-4000-8000-000000000001'),
  1::bigint,
  'create action inserts one reminder'
);
select is(
  (select status from public.agent_action_runs where id = '31000000-0000-4000-8000-000000000001'),
  'succeeded',
  'create action audit is marked succeeded'
);
select is(
  (select recurrence_rule from public.reminders where action_run_id = '31000000-0000-4000-8000-000000000001'),
  null::jsonb,
  'a JSON null recurrence is persisted as SQL null'
);
select lives_ok(
  $$select * from public.execute_reminder_action(
    '31000000-0000-4000-8000-000000000001',
    '11000000-0000-4000-8000-000000000001',
    '{}'::jsonb
  )$$,
  'retrying a succeeded action is idempotent'
);
select is(
  (select count(*) from public.reminders where action_run_id = '31000000-0000-4000-8000-000000000001'),
  1::bigint,
  'idempotent retry does not duplicate the reminder'
);

insert into public.agent_action_runs (
  id, user_id, conversation_id, origin, action_type, arguments,
  human_summary, idempotency_key
) values (
  '31000000-0000-4000-8000-000000000002',
  '11000000-0000-4000-8000-000000000002',
  '21000000-0000-4000-8000-000000000002',
  'text',
  'reminders_create',
  '{}'::jsonb,
  'Other user action',
  'm3-create-user2'
);

select throws_ok(
  $$select * from public.execute_reminder_action(
    '31000000-0000-4000-8000-000000000002',
    '11000000-0000-4000-8000-000000000001',
    '{}'::jsonb
  )$$,
  'P0002',
  'action proposal not found',
  'a user cannot execute another user action proposal'
);

insert into public.agent_action_runs (
  id, user_id, conversation_id, origin, action_type, arguments,
  human_summary, idempotency_key
)
select
  '31000000-0000-4000-8000-000000000003',
  user_id,
  conversation_id,
  'text',
  'reminders_update',
  jsonb_build_object(
    'reminder_id', id,
    'expected_version', version,
    'title', 'Call Mom tonight',
    'notes', 'Ask about the trip',
    'timezone', timezone,
    'start_local', '2026-07-20T19:30:00',
    'next_fire_at', '2026-07-21T00:30:00.000Z',
    'recurrence', null
  ),
  'Update call reminder',
  'm3-update-user1'
from public.reminders
where action_run_id = '31000000-0000-4000-8000-000000000001';

select lives_ok(
  $$select * from public.execute_reminder_action(
    '31000000-0000-4000-8000-000000000003',
    '11000000-0000-4000-8000-000000000001',
    (select arguments from public.agent_action_runs where id = '31000000-0000-4000-8000-000000000003')
  )$$,
  'an approved update proposal executes atomically'
);
select is(
  (select title from public.reminders where user_id = '11000000-0000-4000-8000-000000000001'),
  'Call Mom tonight',
  'update action changes the reminder title'
);
select is(
  (select version from public.reminders where user_id = '11000000-0000-4000-8000-000000000001'),
  2,
  'update action advances the optimistic version'
);

insert into public.agent_action_runs (
  id, user_id, conversation_id, origin, action_type, arguments,
  human_summary, idempotency_key
)
select
  '31000000-0000-4000-8000-000000000004',
  user_id,
  conversation_id,
  'text',
  'reminders_pause',
  jsonb_build_object('reminder_id', id, 'expected_version', 1),
  'Pause stale reminder',
  'm3-stale-user1'
from public.reminders
where user_id = '11000000-0000-4000-8000-000000000001';

select throws_ok(
  $$select * from public.execute_reminder_action(
    '31000000-0000-4000-8000-000000000004',
    '11000000-0000-4000-8000-000000000001',
    (select arguments from public.agent_action_runs where id = '31000000-0000-4000-8000-000000000004')
  )$$,
  '40001',
  'reminder changed or is no longer available',
  'a stale optimistic version is rejected'
);
select is(
  (select status from public.agent_action_runs where id = '31000000-0000-4000-8000-000000000004'),
  'proposed',
  'a failed transaction leaves the proposal pending for server conflict handling'
);

reset role;
select set_config(
  'request.jwt.claims',
  '{"role":"authenticated","sub":"11000000-0000-4000-8000-000000000001"}',
  true
);
set local role authenticated;

select is(
  (select count(*) from public.agent_action_runs),
  3::bigint,
  'action audit RLS exposes only the current user rows'
);
select is(
  (select count(*) from public.reminders),
  1::bigint,
  'reminder RLS exposes the current user reminder'
);
select is(
  (select title from public.reminders),
  'Call Mom tonight',
  'the owner can read the updated reminder'
);

reset role;
select set_config(
  'request.jwt.claims',
  '{"role":"authenticated","sub":"11000000-0000-4000-8000-000000000001","is_anonymous":true}',
  true
);
set local role authenticated;

select is(
  (select count(*) from public.reminders),
  0::bigint,
  'an anonymous authenticated-role session cannot read reminder rows'
);

select * from finish();
rollback;
