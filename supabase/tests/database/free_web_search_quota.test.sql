begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(23);

select is(
  (select enabled from public.feature_flags where key = 'free_web_search'),
  false,
  'Free web search defaults to disabled'
);

select is(
  (select payload ->> 'mode' from public.feature_flags where key = 'free_web_search'),
  'off',
  'Free web search defaults to off mode'
);

select is(
  has_schema_privilege('authenticated', 'private', 'usage'),
  false,
  'authenticated clients cannot use the private schema'
);

select is(
  has_table_privilege('authenticated', 'private.free_web_search_usage', 'select'),
  false,
  'authenticated clients cannot read Free-search reservations'
);

select is(
  has_table_privilege('service_role', 'private.free_web_search_usage', 'select'),
  true,
  'the service role can inspect Free-search reservations'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.reserve_free_web_search(uuid,uuid,bigint,integer,integer,bigint,bigint)',
    'execute'
  ),
  false,
  'authenticated clients cannot reserve Free web search'
);

select is(
  has_function_privilege(
    'service_role',
    'public.reserve_free_web_search(uuid,uuid,bigint,integer,integer,bigint,bigint)',
    'execute'
  ),
  true,
  'the service role can reserve Free web search'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.reconcile_free_web_search(uuid,boolean,integer,bigint)',
    'execute'
  ),
  false,
  'authenticated clients cannot reconcile Free web search'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.reconcile_ai_usage_v2(uuid,boolean,boolean,integer,integer,integer,jsonb,bigint,text)',
    'execute'
  ),
  false,
  'authenticated clients cannot write AI tool-call accounting'
);

select is(
  has_function_privilege(
    'service_role',
    'public.reconcile_ai_usage_v2(uuid,boolean,boolean,integer,integer,integer,jsonb,bigint,text)',
    'execute'
  ),
  true,
  'the service role can write AI tool-call accounting'
);

insert into auth.users (id, aud, role, email)
values (
  '11000000-0000-0000-0000-000000000001',
  'authenticated',
  'authenticated',
  'free-search-quota@example.test'
);

insert into public.ai_usage_ledger (
  request_id,
  user_id,
  cohort,
  intent,
  requested_alias,
  model_role,
  resolved_model,
  reasoning_effort,
  reservation_microusd
)
select
  request_id,
  '11000000-0000-0000-0000-000000000001'::uuid,
  'free',
  'primary_chat',
  'howai-chat',
  'luna',
  'gpt-5.6-luna',
  'low',
  1000
from (
  values
    ('41000000-0000-0000-0000-000000000001'::uuid),
    ('41000000-0000-0000-0000-000000000002'::uuid),
    ('41000000-0000-0000-0000-000000000003'::uuid),
    ('41000000-0000-0000-0000-000000000004'::uuid),
    ('41000000-0000-0000-0000-000000000005'::uuid)
) as requests(request_id);

select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set local role service_role;

select is(
  (
    select accepted
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000001',
      15000, 2, 20, 1000000, 10000000
    )
  ),
  true,
  'the first search reservation is accepted'
);

select is(
  (
    select accepted
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000001',
      15000, 2, 20, 1000000, 10000000
    )
  ),
  true,
  'retrying the same request is idempotent while reserved'
);

select is(
  (select count(*) from private.free_web_search_usage),
  1::bigint,
  'an idempotent retry does not create a second reservation'
);

select is(
  (
    select accepted
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000002',
      15000, 2, 20, 1000000, 10000000
    )
  ),
  true,
  'a second simultaneous reservation is accepted'
);

select is(
  (
    select reason
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000003',
      15000, 2, 20, 1000000, 10000000
    )
  ),
  'user_daily_answer_limit',
  'reserved requests consume the daily allowance atomically'
);

select lives_ok(
  $$select public.reconcile_free_web_search(
    '41000000-0000-0000-0000-000000000001', false, 0, 0
  )$$,
  'a request that did not call search releases its reservation'
);

select is(
  (
    select accepted
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000003',
      15000, 2, 20, 1000000, 10000000
    )
  ),
  true,
  'a released no-search reservation restores the allowance'
);

select lives_ok(
  $$select public.reconcile_free_web_search(
    '41000000-0000-0000-0000-000000000002', true, 1, 15000
  )$$,
  'a successful searched answer reconciles its search usage'
);

select lives_ok(
  $$select public.reconcile_free_web_search(
    '41000000-0000-0000-0000-000000000003', true, 1, 15000
  )$$,
  'a second successful searched answer reconciles its search usage'
);

select is(
  (
    select reason
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000004',
      15000, 2, 20, 1000000, 10000000
    )
  ),
  'user_daily_answer_limit',
  'two completed searched answers exhaust the daily allowance'
);

select lives_ok(
  $$select public.reconcile_ai_usage_v2(
    '41000000-0000-0000-0000-000000000002',
    true,
    true,
    120,
    20,
    30,
    '{"web_search":1}'::jsonb,
    17000,
    null
  )$$,
  'tool-call accounting reconciles through the service-only RPC'
);

select is(
  (
    select (tool_calls ->> 'web_search')::integer
    from public.ai_usage_ledger
    where request_id = '41000000-0000-0000-0000-000000000002'
  ),
  1,
  'the AI ledger stores the actual web-search call count'
);

select is(
  (
    select reason
    from public.reserve_free_web_search(
      '11000000-0000-0000-0000-000000000001',
      '41000000-0000-0000-0000-000000000005',
      30000, 100, 100, 50000, 50000
    )
  ),
  'global_daily_cost_limit',
  'the global search-cost circuit breaker includes reconciled search spend'
);

select * from finish();
rollback;
