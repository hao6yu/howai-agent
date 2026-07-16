begin;

create extension if not exists pgtap with schema extensions;

select plan(27);

select has_table('public', 'automations', 'automations table exists');
select has_table('public', 'automation_runs', 'automation runs table exists');

select is(
  (select payload ->> 'mode' from public.feature_flags where key = 'automations'),
  'off',
  'generated Automations default to rollout off'
);
select is(
  (select count(*) from public.feature_flags where key like 'automation%'),
  5::bigint,
  'all independent Automation kill switches exist'
);

select is(
  has_table_privilege('authenticated', 'public.automations', 'select'),
  true,
  'authenticated users can read exposed Automation rows through RLS'
);
select is(
  has_table_privilege('authenticated', 'public.automations', 'insert'),
  false,
  'authenticated users cannot create Automations directly'
);
select is(
  has_table_privilege('authenticated', 'public.automation_runs', 'select'),
  true,
  'authenticated users can read exposed run rows through RLS'
);
select is(
  has_table_privilege('authenticated', 'public.automation_runs', 'update'),
  false,
  'authenticated users cannot mutate Automation runs directly'
);

insert into auth.users (id, aud, role, email)
values
  ('14000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'm45-user1@example.test'),
  ('14000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'm45-user2@example.test');

set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);

insert into public.automations (
  id, user_id, kind, title, timezone, start_local, schedule_rule, next_run_at, config
) values
  (
    '24000000-0000-4000-8000-000000000001',
    '14000000-0000-4000-8000-000000000001',
    'news_briefing',
    'Morning AI briefing',
    'America/Chicago',
    '2026-07-17 07:00:00',
    '{"frequency":"daily","time_local":"07:00:00"}'::jsonb,
    now() + interval '1 day',
    '{"topics":["AI"],"item_count":5,"language":"auto"}'::jsonb
  ),
  (
    '24000000-0000-4000-8000-000000000002',
    '14000000-0000-4000-8000-000000000002',
    'market_briefing',
    'Market close briefing',
    'America/New_York',
    '2026-07-17 15:30:00',
    '{"frequency":"market_days","time_local":"15:30:00"}'::jsonb,
    now() + interval '1 day',
    '{"session":"close","scope":"us_market"}'::jsonb
  );

select is(
  (select count(*) from public.automations),
  2::bigint,
  'the service role can create strict Automation templates'
);

select throws_ok(
  $$insert into public.automations (
      user_id, kind, title, timezone, start_local, schedule_rule, next_run_at, config
    ) values (
      '14000000-0000-4000-8000-000000000001',
      'arbitrary_prompt', 'Unsafe', 'UTC',
      '2026-07-17 07:00:00',
      '{"frequency":"daily"}'::jsonb, now(), '{}'::jsonb
    )$$,
  '23514',
  null,
  'arbitrary scheduled prompt kinds are rejected'
);

select throws_ok(
  $$insert into public.automations (
      user_id, kind, title, timezone, start_local, schedule_rule, next_run_at, config
    ) values (
      '14000000-0000-4000-8000-000000000001',
      'news_briefing', 'Bad schedule', 'UTC',
      '2026-07-17 07:00:00',
      '{"frequency":"hourly"}'::jsonb, now(), '{}'::jsonb
    )$$,
  '23514',
  null,
  'unsupported schedule frequencies are rejected'
);

select throws_ok(
  $$insert into public.automations (
      user_id, kind, title, timezone, start_local, schedule_rule, next_run_at, config,
      required_tier
    ) values (
      '14000000-0000-4000-8000-000000000001',
      'news_briefing', 'Free generated job', 'UTC',
      '2026-07-17 07:00:00',
      '{"frequency":"daily"}'::jsonb, now(), '{}'::jsonb, 'free'
    )$$,
  '23514',
  null,
  'generated Automations remain paid-tier templates'
);

insert into public.automation_runs (
  id, automation_id, user_id, automation_version, scheduled_for,
  template_snapshot
) values (
  '34000000-0000-4000-8000-000000000001',
  '24000000-0000-4000-8000-000000000001',
  '14000000-0000-4000-8000-000000000001',
  1,
  now() + interval '1 day',
  '{"kind":"news_briefing","title":"Morning AI briefing"}'::jsonb
);

select is(
  (select status from public.automation_runs where id = '34000000-0000-4000-8000-000000000001'),
  'queued',
  'new run occurrences begin queued'
);
select is(
  (select jsonb_typeof(sources) from public.automation_runs where id = '34000000-0000-4000-8000-000000000001'),
  'array',
  'run sources use a durable structured array'
);
select is(
  (select jsonb_typeof(claims) from public.automation_runs where id = '34000000-0000-4000-8000-000000000001'),
  'array',
  'run claims use a durable structured array'
);

select throws_ok(
  $$insert into public.automation_runs (
      automation_id, user_id, automation_version, scheduled_for,
      template_snapshot
    ) values (
      '24000000-0000-4000-8000-000000000001',
      '14000000-0000-4000-8000-000000000002',
      1, now() + interval '2 days', '{}'::jsonb
    )$$,
  '23503',
  null,
  'a run cannot claim a different Automation owner'
);

select throws_ok(
  $$insert into public.automation_runs (
      automation_id, user_id, automation_version, scheduled_for,
      template_snapshot
    ) select
      automation_id, user_id, automation_version, scheduled_for,
      template_snapshot
    from public.automation_runs
    where id = '34000000-0000-4000-8000-000000000001'$$,
  '23505',
  null,
  'an Automation occurrence cannot be queued twice'
);

select throws_ok(
  $$update public.automation_runs
    set status = 'succeeded'
    where id = '34000000-0000-4000-8000-000000000001'$$,
  '23514',
  null,
  'terminal run status requires a completion timestamp'
);

update public.automation_runs
set
  status = 'succeeded',
  report = '{"summary":"Verified briefing"}'::jsonb,
  preview = 'Your verified briefing is ready.',
  claims = '[{"id":"claim-1","source_ids":["source-1"]}]'::jsonb,
  sources = '[{"id":"source-1","url":"https://example.test/source"}]'::jsonb,
  verification = '{"policy_version":"m45-v1","passed":true}'::jsonb,
  completed_at = now()
where id = '34000000-0000-4000-8000-000000000001';

select is(
  (select status from public.automation_runs where id = '34000000-0000-4000-8000-000000000001'),
  'succeeded',
  'a verified run can enter succeeded state'
);
select is(
  (select verification ->> 'policy_version' from public.automation_runs where id = '34000000-0000-4000-8000-000000000001'),
  'm45-v1',
  'the verification policy version is retained'
);

reset role;

select set_config(
  'request.jwt.claims',
  '{"sub":"14000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
set local role authenticated;

select is(
  (select count(*) from public.automations),
  1::bigint,
  'RLS exposes only the signed-in user Automation'
);
select is(
  (select count(*) from public.automation_runs),
  1::bigint,
  'RLS exposes only the signed-in user run history'
);
select throws_ok(
  $$insert into public.automations (
      user_id, kind, title, timezone, start_local, schedule_rule, next_run_at, config
    ) values (
      '14000000-0000-4000-8000-000000000001',
      'news_briefing', 'Direct insert', 'UTC',
      '2026-07-17 07:00:00',
      '{"frequency":"daily"}'::jsonb, now(), '{}'::jsonb
    )$$,
  '42501',
  null,
  'authenticated clients cannot bypass the approval service'
);
select throws_ok(
  $$update public.automations set status = 'paused'$$,
  '42501',
  null,
  'authenticated clients cannot mutate Automation state directly'
);
select throws_ok(
  $$update public.automation_runs set preview = 'tampered'$$,
  '42501',
  null,
  'authenticated clients cannot tamper with generated reports'
);

reset role;

select is(
  (
    select count(*)
    from information_schema.table_constraints
    where table_schema = 'public'
      and table_name = 'agent_action_runs'
      and constraint_name = 'agent_action_runs_action_type_check'
  ),
  1::bigint,
  'the shared action audit accepts the expanded allowlist constraint'
);
select lives_ok(
  $$insert into public.agent_action_runs (
      user_id, origin, action_type, arguments, human_summary,
      idempotency_key
    ) values (
      '14000000-0000-4000-8000-000000000001',
      'system', 'automations_run_now', '{}', 'Run briefing now',
      'm45-run-now-test'
    )$$,
  'the shared approval audit accepts an allowlisted Automation action'
);

select * from finish();
rollback;
