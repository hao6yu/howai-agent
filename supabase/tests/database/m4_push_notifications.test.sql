begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(45);

select is(
  (select payload ->> 'mode' from public.feature_flags where key = 'push_notifications'),
  'off',
  'push delivery defaults to an off rollout mode'
);
select has_table('public', 'push_devices', 'push device table exists');
select has_table('public', 'reminder_deliveries', 'reminder delivery table exists');
select has_table('public', 'reminder_delivery_attempts', 'per-device attempt table exists');
select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.push_devices'::regclass),
  'push devices have RLS enabled'
);
select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.reminder_deliveries'::regclass),
  'reminder deliveries have RLS enabled'
);
select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.reminder_delivery_attempts'::regclass),
  'delivery attempts have RLS enabled'
);
select is(
  has_table_privilege('authenticated', 'public.push_devices', 'select'),
  false,
  'authenticated clients cannot read FCM tokens'
);
select is(
  has_table_privilege('authenticated', 'public.push_devices', 'insert'),
  false,
  'authenticated clients cannot write FCM tokens directly'
);
select is(
  has_table_privilege('authenticated', 'public.reminder_deliveries', 'select'),
  false,
  'authenticated clients cannot read delivery internals'
);
select is(
  has_table_privilege('authenticated', 'public.reminder_delivery_attempts', 'select'),
  false,
  'authenticated clients cannot read provider attempts'
);
select is(
  has_table_privilege('service_role', 'public.push_devices', 'insert'),
  true,
  'service role can register devices'
);
select is(
  has_table_privilege('service_role', 'public.reminder_deliveries', 'insert'),
  true,
  'service role can create delivery occurrences'
);
select is(
  has_function_privilege('authenticated', 'public.claim_due_reminder_deliveries(integer)', 'execute'),
  false,
  'authenticated clients cannot claim deliveries'
);
select is(
  has_function_privilege('service_role', 'public.claim_due_reminder_deliveries(integer)', 'execute'),
  true,
  'service role can claim deliveries'
);
select is(
  has_function_privilege('authenticated', 'public.retry_reminder_delivery(uuid,integer,jsonb)', 'execute'),
  false,
  'authenticated clients cannot release retries'
);
select is(
  has_function_privilege('authenticated', 'public.finish_reminder_delivery(uuid,text,jsonb,timestamptz)', 'execute'),
  false,
  'authenticated clients cannot finalize deliveries'
);
select ok(
  to_regclass('public.push_devices_user_active_idx') is not null,
  'active device lookups are indexed'
);
select ok(
  to_regclass('public.reminder_deliveries_ready_idx') is not null,
  'ready delivery claims are indexed'
);
select ok(
  to_regclass('public.reminder_delivery_attempts_device_idx') is not null,
  'device attempt foreign keys are indexed'
);

select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set local role service_role;

select is(
  (select count(*) from public.claim_due_reminder_deliveries(25)),
  0::bigint,
  'the worker claims nothing while the rollout is off'
);

reset role;

insert into auth.users (id, aud, role, email)
values
  ('12000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'm4-canary@example.test'),
  ('12000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'm4-control@example.test');

insert into public.app_entitlements (
  user_id, tier, source, verified_at, model_policy_canary
) values
  ('12000000-0000-4000-8000-000000000001', 'free', 'admin', now(), true),
  ('12000000-0000-4000-8000-000000000002', 'free', 'admin', now(), false);

update public.feature_flags
set enabled = true, payload = jsonb_build_object('mode', 'internal')
where key = 'push_notifications';

insert into public.reminders (
  id, user_id, title, timezone, start_local, next_fire_at, recurrence_rule
) values
  (
    '22000000-0000-4000-8000-000000000001',
    '12000000-0000-4000-8000-000000000001',
    'Canary recurring reminder',
    'UTC',
    '2026-07-15 08:00:00',
    now() - interval '1 minute',
    '{"frequency":"daily","interval":1,"weekdays":[],"day_of_month":null,"ends_at":null}'::jsonb
  ),
  (
    '22000000-0000-4000-8000-000000000002',
    '12000000-0000-4000-8000-000000000002',
    'Control reminder',
    'UTC',
    '2026-07-15 08:00:00',
    now() - interval '1 minute',
    null
  );

set local role service_role;

create temporary table first_claim as
select * from public.claim_due_reminder_deliveries(25);

select is((select count(*) from first_claim), 1::bigint, 'internal rollout claims one canary reminder');
select is(
  (select user_id from first_claim),
  '12000000-0000-4000-8000-000000000001'::uuid,
  'the control account is excluded from internal delivery'
);
select is(
  (select count(*) from public.reminder_deliveries),
  1::bigint,
  'one occurrence record is created'
);
select is(
  (select status from public.reminder_deliveries),
  'processing',
  'claimed occurrence receives a processing lease'
);
select is((select attempt_number from first_claim), 1::smallint, 'first claim is attempt one');
select is(
  (select count(*) from public.claim_due_reminder_deliveries(25)),
  0::bigint,
  'an active lease cannot be claimed twice'
);
select is(
  (select count(*) from public.reminder_deliveries),
  1::bigint,
  'repeated scans do not duplicate an occurrence'
);
select ok(
  public.retry_reminder_delivery(
    (select delivery_id from first_claim),
    30,
    '{"reason":"temporary"}'::jsonb
  ),
  'a worker can release an occurrence for retry'
);
select is(
  (select status from public.reminder_deliveries),
  'retrying',
  'released occurrence enters retrying state'
);

update public.reminder_deliveries set available_at = now() - interval '1 second';
create temporary table second_claim as
select * from public.claim_due_reminder_deliveries(25);
select is((select attempt_number from second_claim), 2::smallint, 'retry claim increments the attempt number');

select lives_ok(
  $$insert into public.push_devices (
    user_id, token, platform, timezone
  ) values (
    '12000000-0000-4000-8000-000000000001',
    'test-fcm-token-with-enough-characters',
    'ios',
    'America/Chicago'
  )$$,
  'service role can register an FCM device'
);
select lives_ok(
  $$insert into public.reminder_delivery_attempts (
    delivery_id, push_device_id, attempt_number, status, provider_message_id
  ) values (
    (select delivery_id from second_claim),
    (select id from public.push_devices limit 1),
    2,
    'sent',
    'projects/howai/messages/test'
  )$$,
  'a per-device provider success is recorded'
);

select ok(
  public.finish_reminder_delivery(
    (select delivery_id from second_claim),
    'sent',
    '{"sent":1,"failed":0}'::jsonb,
    now() + interval '1 day'
  ),
  'a recurring delivery can be finalized'
);
select is(
  (select status from public.reminder_deliveries),
  'sent',
  'the occurrence is marked sent'
);
select ok(
  (select next_fire_at > now() from public.reminders where id = '22000000-0000-4000-8000-000000000001'),
  'the recurring reminder advances to a future occurrence'
);
select is(
  (select version from public.reminders where id = '22000000-0000-4000-8000-000000000001'),
  2,
  'delivery advancement increments the optimistic version'
);
select is(
  (select last_delivery_status from public.reminders where id = '22000000-0000-4000-8000-000000000001'),
  'sent',
  'the reminder exposes its last delivery outcome'
);
select ok(
  public.finish_reminder_delivery(
    (select delivery_id from second_claim),
    'sent',
    '{}'::jsonb,
    now() + interval '1 day'
  ),
  'finalization is idempotent'
);

insert into public.reminders (
  id, user_id, title, timezone, start_local, next_fire_at
) values (
  '22000000-0000-4000-8000-000000000003',
  '12000000-0000-4000-8000-000000000001',
  'Canary one-time reminder',
  'UTC',
  '2026-07-15 09:00:00',
  now() - interval '30 seconds'
);
create temporary table one_time_claim as
select * from public.claim_due_reminder_deliveries(25);
select is((select count(*) from one_time_claim), 1::bigint, 'a due one-time reminder is claimed');
select ok(
  public.finish_reminder_delivery(
    (select delivery_id from one_time_claim),
    'no_devices',
    '{"reason":"no_active_registered_devices"}'::jsonb,
    null
  ),
  'a one-time occurrence can finalize without a next date'
);
select is(
  (select status from public.reminders where id = '22000000-0000-4000-8000-000000000003'),
  'completed',
  'a one-time reminder completes after its occurrence'
);
select ok(
  (select completed_at is not null from public.reminders where id = '22000000-0000-4000-8000-000000000003'),
  'one-time completion records a timestamp'
);

select throws_ok(
  $$select * from public.claim_due_reminder_deliveries(101)$$,
  '22023',
  'p_limit must be between 1 and 100',
  'claim batches are bounded'
);
select set_config('request.jwt.claims', '{"role":"authenticated"}', true);
select throws_ok(
  $$select * from public.claim_due_reminder_deliveries(25)$$,
  '42501',
  'service role required',
  'the RPC checks the JWT role in addition to SQL grants'
);

select * from finish();
rollback;
