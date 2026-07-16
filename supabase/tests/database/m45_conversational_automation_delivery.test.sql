begin;

create extension if not exists pgtap with schema extensions;

select plan(24);

select has_table(
  'public',
  'automation_run_deliveries',
  'Automation push deliveries are durable'
);
select has_table(
  'public',
  'automation_delivery_attempts',
  'per-device Automation attempts are durable'
);
select has_column(
  'public',
  'automation_runs',
  'conversation_message_id',
  'runs retain the generated conversation message'
);

insert into auth.users (id, aud, role, email)
values (
  '15000000-0000-4000-8000-000000000001',
  'authenticated',
  'authenticated',
  'automation-delivery@example.test'
);

set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);

insert into public.app_entitlements (
  user_id, tier, source, verified_at, model_policy_canary
) values (
  '15000000-0000-4000-8000-000000000001',
  'paid',
  'admin',
  now(),
  true
);

insert into public.conversations (
  id, user_id, title, created_at, updated_at, is_pinned, archived_at
) values (
  '25000000-0000-4000-8000-000000000001',
  '15000000-0000-4000-8000-000000000001',
  'Morning briefings',
  now(),
  now(),
  false,
  now()
);

update public.feature_flags
set enabled = true,
    payload = '{"mode":"internal"}'::jsonb,
    updated_at = now()
where key in (
  'automations',
  'automation_web_retrieval',
  'automation_validation',
  'automation_notifications'
);

insert into public.automations (
  id, user_id, conversation_id, kind, title, timezone, start_local,
  schedule_rule, next_run_at, config, source_policy, delivery_preferences
) values
  (
    '35000000-0000-4000-8000-000000000001',
    '15000000-0000-4000-8000-000000000001',
    '25000000-0000-4000-8000-000000000001',
    'news_briefing',
    'Morning AI briefing',
    'America/Chicago',
    '2026-07-16 07:00:00',
    '{"frequency":"daily","interval":1,"weekdays":[],"ends_at":null}'::jsonb,
    now() - interval '1 minute',
    '{"topics":["AI"],"item_count":3,"language":"auto","summary_style":"concise"}'::jsonb,
    '{"preferred_domains":[],"excluded_domains":[],"freshness_hours":24,"require_primary_sources":true}'::jsonb,
    '{"push":true}'::jsonb
  ),
  (
    '35000000-0000-4000-8000-000000000002',
    '15000000-0000-4000-8000-000000000001',
    '25000000-0000-4000-8000-000000000001',
    'market_briefing',
    'Market close briefing',
    'America/New_York',
    '2026-07-16 15:30:00',
    '{"frequency":"market_days","interval":1,"weekdays":[1,2,3,4,5],"ends_at":null}'::jsonb,
    now() - interval '1 minute',
    '{"session":"close","scope":"us_market","symbols":[]}'::jsonb,
    '{}'::jsonb,
    '{"push":true}'::jsonb
  );

create temporary table claimed_run as
select * from public.claim_due_automation_runs(4);

select is(
  (select count(*) from claimed_run),
  1::bigint,
  'the internal worker claims one eligible due run'
);
select is(
  (select automation_id from claimed_run),
  '35000000-0000-4000-8000-000000000001'::uuid,
  'market runs stay gated until structured market data is enabled'
);
select is(
  (select attempt_number from claimed_run),
  1::smallint,
  'claiming increments the bounded attempt number'
);
select is(
  (
    select status
    from public.automation_runs
    where id = (select run_id from claimed_run)
  ),
  'running',
  'a claimed occurrence receives a short running lease'
);
select is(
  (
    select count(*)
    from public.automation_runs
    where automation_id = '35000000-0000-4000-8000-000000000002'
  ),
  0::bigint,
  'disabled market data does not create a queued market occurrence'
);

create temporary table finished_run as
select * from public.finish_automation_run(
  (select run_id from claimed_run),
  'succeeded',
  E'Your verified briefing is ready.\n\n### Sources\n\n- [Primary](https://example.test/source)',
  '{"kind":"news_briefing","title":"Morning AI briefing"}'::jsonb,
  'Your verified briefing is ready.',
  '[{"text":"Verified claim","supported":true,"source_urls":["https://example.test/source"]}]'::jsonb,
  '[{"id":"source_1","title":"Primary","url":"https://example.test/source","domain":"example.test"}]'::jsonb,
  '{"status":"pass","issues":[]}'::jsonb,
  'resp-generation',
  'resp-verification',
  null,
  null,
  now() + interval '1 day',
  true,
  null,
  null
);

select is(
  (select count(*) from public.messages where is_ai = true),
  1::bigint,
  'finishing atomically appends one assistant message'
);
select is(
  (select conversation_id from finished_run),
  '25000000-0000-4000-8000-000000000001'::uuid,
  'the result stays in the Automation conversation'
);
select is(
  (
    select conversation_message_id
    from public.automation_runs
    where id = (select run_id from claimed_run)
  ),
  (select message_id from finished_run),
  'the run links to its generated message'
);
select is(
  (
    select archived_at
    from public.conversations
    where id = '25000000-0000-4000-8000-000000000001'
  ),
  null::timestamptz,
  'a new Automation message restores its conversation'
);
select is(
  (select count(*) from public.automation_run_deliveries),
  1::bigint,
  'successful push-enabled runs create one delivery record'
);
select is(
  (
    select status
    from public.automation_runs
    where id = (select run_id from claimed_run)
  ),
  'succeeded',
  'the verified run reaches a terminal state'
);
select is(
  (
    select last_run_at is not null
    from public.automations
    where id = '35000000-0000-4000-8000-000000000001'
  ),
  true,
  'the Automation advances only after durable completion'
);

select lives_ok(
  format(
    $$select * from public.finish_automation_run(
      %L, 'succeeded', 'duplicate', '{}'::jsonb, 'duplicate',
      '[]'::jsonb, '[]'::jsonb, '{}'::jsonb,
      null, null, null, null, now() + interval '1 day', true, null, null
    )$$,
    (select run_id from claimed_run)
  ),
  'repeating a terminal completion is idempotent'
);
select is(
  (select count(*) from public.messages where is_ai = true),
  1::bigint,
  'idempotent completion does not duplicate the assistant message'
);
select is(
  (select count(*) from public.automation_run_deliveries),
  1::bigint,
  'idempotent completion does not duplicate the push delivery'
);

create temporary table claimed_delivery as
select * from public.claim_due_automation_deliveries(10);

select is(
  (select count(*) from claimed_delivery),
  1::bigint,
  'the notification worker claims the ready delivery'
);
select is(
  (select attempt_number from claimed_delivery),
  1::smallint,
  'notification claims also increment a bounded attempt number'
);
select is(
  public.finish_automation_delivery(
    (select delivery_id from claimed_delivery),
    'sent',
    '{"sent":1}'::jsonb
  ),
  true,
  'the notification can finish independently of report generation'
);
select is(
  (select status from public.automation_run_deliveries),
  'sent',
  'the terminal push outcome is durable'
);

reset role;
select set_config(
  'request.jwt.claims',
  '{"sub":"15000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
set local role authenticated;

select is(
  has_table_privilege(
    'authenticated',
    'public.automation_run_deliveries',
    'select'
  ),
  false,
  'clients cannot read private delivery bookkeeping'
);
select throws_ok(
  $$select * from public.claim_due_automation_runs(1)$$,
  '42501',
  null,
  'clients cannot invoke the worker claim RPC'
);

select * from finish();
rollback;
