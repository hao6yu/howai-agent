begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(22);

select is(
  (select count(*) from public.feature_flags),
  5::bigint,
  'all five HowAI 2.0 feature flags exist'
);

select is(
  (select count(*) from public.feature_flags where enabled),
  0::bigint,
  'all new capabilities default to disabled'
);

select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.feature_flags'::regclass),
  'feature flags have RLS enabled'
);

select ok(
  (select relrowsecurity from pg_catalog.pg_class where oid = 'public.app_entitlements'::regclass),
  'verified entitlements have RLS enabled'
);

select is(
  has_table_privilege('authenticated', 'public.app_entitlements', 'select'),
  false,
  'authenticated clients cannot read verified entitlements'
);

select is(
  has_table_privilege('authenticated', 'public.ai_usage_ledger', 'insert'),
  false,
  'authenticated clients cannot write the usage ledger'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.reserve_ai_usage(uuid,uuid,text,text,text,text,text,text,bigint,bigint,bigint,integer)',
    'execute'
  ),
  false,
  'authenticated clients cannot reserve AI budget'
);

select is(
  has_function_privilege(
    'service_role',
    'public.reserve_ai_usage(uuid,uuid,text,text,text,text,text,text,bigint,bigint,bigint,integer)',
    'execute'
  ),
  true,
  'the service role can reserve AI budget'
);

select is(
  (
    select count(*)
    from pg_catalog.pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'public read generated images'
  ),
  0::bigint,
  'the public generated-image listing policy is removed'
);

insert into auth.users (id, aud, role, email)
values
  ('10000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'phase0-user1@example.test'),
  ('10000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'phase0-user2@example.test');

select is(
  (select count(*) from public.profiles where id = '10000000-0000-0000-0000-000000000001'),
  1::bigint,
  'the auth trigger still creates user one profile after execute revocation'
);

select is(
  (select count(*) from public.profiles where id = '10000000-0000-0000-0000-000000000002'),
  1::bigint,
  'the auth trigger still creates user two profile after execute revocation'
);

insert into public.conversations (id, user_id, title)
values (
  '20000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000002',
  'User two private conversation'
);

select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set local role service_role;

select is(
  (
    select accepted
    from public.reserve_ai_usage(
      '10000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000001',
      'free', 'primary_chat', 'howai-chat', 'luna', 'gpt-5.6-luna', 'low',
      8000, 30000, 300000, 3
    )
  ),
  true,
  'the first Luna answer reserves budget'
);

select is(
  (
    select accepted
    from public.reserve_ai_usage(
      '10000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000002',
      'free', 'primary_chat', 'howai-chat', 'luna', 'gpt-5.6-luna', 'low',
      8000, 30000, 300000, 3
    )
  ),
  true,
  'the second Luna answer reserves budget'
);

select is(
  (
    select accepted
    from public.reserve_ai_usage(
      '10000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000003',
      'free', 'primary_chat', 'howai-chat', 'luna', 'gpt-5.6-luna', 'low',
      8000, 30000, 300000, 3
    )
  ),
  true,
  'the third Luna answer reserves budget'
);

select is(
  (
    select accepted
    from public.reserve_ai_usage(
      '10000000-0000-0000-0000-000000000001',
      '30000000-0000-0000-0000-000000000004',
      'free', 'primary_chat', 'howai-chat', 'luna', 'gpt-5.6-luna', 'low',
      8000, 30000, 300000, 3
    )
  ),
  false,
  'a fourth Luna answer is rejected atomically'
);

select lives_ok(
  $$select public.reconcile_ai_usage(
    '30000000-0000-0000-0000-000000000001',
    true, 100, 20, 50, 500, null
  )$$,
  'usage reconciliation succeeds for the service role'
);

select is(
  (
    select status
    from public.ai_usage_ledger
    where request_id = '30000000-0000-0000-0000-000000000001'
  ),
  'succeeded',
  'usage reconciliation commits the final status'
);

reset role;
select set_config(
  'request.jwt.claims',
  '{"role":"authenticated","sub":"10000000-0000-0000-0000-000000000001"}',
  true
);
set local role authenticated;

select lives_ok(
  $$insert into public.conversations (id, user_id, title)
    values (
      '20000000-0000-0000-0000-000000000001',
      '10000000-0000-0000-0000-000000000001',
      'User one conversation'
    )$$,
  'an authenticated user can create their own conversation'
);

select lives_ok(
  $$insert into public.messages (id, conversation_id, content, is_ai)
    values (
      '40000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001',
      'Hello',
      false
    )$$,
  'an authenticated user can create a message in their conversation'
);

select is(
  (
    select count(*)
    from public.user_profiles
    where user_id = '10000000-0000-0000-0000-000000000001'
  ),
  1::bigint,
  'the message trigger still initializes the user profile'
);

select lives_ok(
  $$update public.conversations
    set title = 'Updated safely'
    where id = '20000000-0000-0000-0000-000000000001'$$,
  'the hardened update policy still permits owner updates'
);

select results_eq(
  'select count(*) from public.conversations',
  array[1::bigint],
  'RLS hides another user conversation'
);

select * from finish();
rollback;
