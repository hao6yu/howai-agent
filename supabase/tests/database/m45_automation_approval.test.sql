begin;

create extension if not exists pgtap with schema extensions;
select plan(14);

select has_column('public', 'automations', 'start_local', 'Automation start-local state is durable');
select is(
  has_function_privilege(
    'authenticated',
    'public.execute_automation_action(uuid,uuid,jsonb)',
    'execute'
  ),
  false,
  'authenticated clients cannot execute approved Automation mutations'
);
select is(
  has_function_privilege(
    'service_role',
    'public.execute_automation_action(uuid,uuid,jsonb)',
    'execute'
  ),
  true,
  'the service role can execute an approved Automation mutation'
);

insert into auth.users (id, aud, role, email)
values
  ('15000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'm45-paid@example.test'),
  ('15000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'm45-free@example.test');

insert into public.app_entitlements (user_id, tier, source, verified_at)
values
  ('15000000-0000-4000-8000-000000000001', 'paid', 'admin', now()),
  ('15000000-0000-4000-8000-000000000002', 'free', 'admin', now());

insert into public.agent_action_runs (
  id, user_id, origin, action_type, arguments, human_summary, idempotency_key
) values
  (
    '35000000-0000-4000-8000-000000000001',
    '15000000-0000-4000-8000-000000000001',
    'text', 'automations_create',
    '{
      "kind":"news_briefing",
      "title":"Morning AI briefing",
      "timezone":"America/Chicago",
      "start_local":"2026-07-17T07:00:00",
      "schedule_rule":{"frequency":"daily","interval":1,"weekdays":[],"ends_at":null},
      "next_run_at":"2026-07-17T12:00:00Z",
      "config":{"topics":["AI"],"item_count":5,"region":"US","language":"auto","summary_style":"concise"},
      "source_policy":{"preferred_domains":[],"excluded_domains":[],"freshness_hours":24,"require_primary_sources":true},
      "delivery_preferences":{"push":true}
    }'::jsonb,
    'News briefing: Morning AI briefing', 'm45-approval-paid'
  ),
  (
    '35000000-0000-4000-8000-000000000002',
    '15000000-0000-4000-8000-000000000002',
    'text', 'automations_create',
    '{
      "kind":"news_briefing",
      "title":"Free briefing",
      "timezone":"UTC",
      "start_local":"2026-07-17T07:00:00",
      "schedule_rule":{"frequency":"daily","interval":1,"weekdays":[],"ends_at":null},
      "next_run_at":"2026-07-17T07:00:00Z",
      "config":{"topics":["AI"],"item_count":3,"region":null,"language":"auto","summary_style":"concise"},
      "source_policy":{"preferred_domains":[],"excluded_domains":[],"freshness_hours":24,"require_primary_sources":true},
      "delivery_preferences":{"push":true}
    }'::jsonb,
    'News briefing: Free briefing', 'm45-approval-free'
  );

set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);

select lives_ok(
  $$select * from public.execute_automation_action(
    '35000000-0000-4000-8000-000000000001',
    '15000000-0000-4000-8000-000000000001',
    (select arguments from public.agent_action_runs where id = '35000000-0000-4000-8000-000000000001')
  )$$,
  'an approved paid-user proposal creates an Automation atomically'
);
select is((select count(*) from public.automations), 1::bigint, 'one Automation is created');
select is((select status from public.agent_action_runs where id = '35000000-0000-4000-8000-000000000001'), 'succeeded', 'the proposal audit succeeds');
select is((select resource_type from public.agent_action_runs where id = '35000000-0000-4000-8000-000000000001'), 'automation', 'the audit links the Automation resource');
select is((select start_local::text from public.automations), '2026-07-17 07:00:00', 'the local schedule anchor is retained');

select lives_ok(
  $$select * from public.execute_automation_action(
    '35000000-0000-4000-8000-000000000001',
    '15000000-0000-4000-8000-000000000001',
    (select arguments from public.agent_action_runs where id = '35000000-0000-4000-8000-000000000001')
  )$$,
  'approval execution is idempotent'
);
select is((select count(*) from public.automations), 1::bigint, 'idempotent approval does not duplicate the Automation');

select throws_ok(
  $$select * from public.execute_automation_action(
    '35000000-0000-4000-8000-000000000002',
    '15000000-0000-4000-8000-000000000002',
    (select arguments from public.agent_action_runs where id = '35000000-0000-4000-8000-000000000002')
  )$$,
  '42501', null,
  'a free account cannot approve a generated Automation'
);
select is((select count(*) from public.automations), 1::bigint, 'the rejected entitlement creates no row');

reset role;
select set_config('request.jwt.claims', '{"sub":"15000000-0000-4000-8000-000000000001","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*) from public.automations), 1::bigint, 'the owner can read the approved Automation through RLS');
select is((select count(*) from public.automations where user_id = '15000000-0000-4000-8000-000000000002'), 0::bigint, 'another user Automation remains hidden');

select * from finish();
rollback;
