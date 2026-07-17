begin;

create extension if not exists pgtap with schema extensions;
set local role postgres;
grant usage on schema extensions to authenticated;
set local search_path = extensions, public, pg_catalog;
select plan(22);

select has_table('public', 'user_memories', 'structured user memories exist');
select has_table(
  'public',
  'memory_session_summaries',
  'memory extraction summaries exist'
);
select has_table(
  'public',
  'memory_preferences',
  'memory privacy controls exist'
);

select has_column(
  'public',
  'user_memories',
  'memory_key',
  'memories use a stable semantic key'
);
select has_column(
  'public',
  'user_memories',
  'status',
  'memories have review status'
);
select has_column(
  'public',
  'user_memories',
  'source_type',
  'memories record their source channel'
);
select has_column(
  'public',
  'user_memories',
  'sensitivity',
  'memories carry a sensitivity classification'
);

select ok(
  (select relrowsecurity from pg_catalog.pg_class
   where oid = 'public.user_memories'::regclass),
  'user memories have RLS'
);
select ok(
  (select relrowsecurity from pg_catalog.pg_class
   where oid = 'public.memory_session_summaries'::regclass),
  'memory summaries have RLS'
);
select ok(
  (select relrowsecurity from pg_catalog.pg_class
   where oid = 'public.memory_preferences'::regclass),
  'memory preferences have RLS'
);

select is(
  has_table_privilege('anon', 'public.user_memories', 'select'),
  false,
  'anonymous users cannot read memories'
);
select is(
  has_table_privilege('anon', 'public.memory_session_summaries', 'select'),
  false,
  'anonymous users cannot read memory summaries'
);
select is(
  has_table_privilege('anon', 'public.memory_preferences', 'select'),
  false,
  'anonymous users cannot read memory preferences'
);

select is(
  has_table_privilege('authenticated', 'public.user_memories', 'select'),
  true,
  'authenticated users can read owner-scoped memories'
);
select is(
  has_table_privilege(
    'authenticated',
    'public.memory_session_summaries',
    'select'
  ),
  true,
  'authenticated users can read owner-scoped summaries'
);
select is(
  has_table_privilege('authenticated', 'public.memory_preferences', 'select'),
  true,
  'authenticated users can read owner-scoped preferences'
);
select is(
  has_table_privilege('authenticated', 'public.user_memories', 'insert'),
  true,
  'authenticated users can create their own explicit memories'
);
select is(
  has_table_privilege('authenticated', 'public.memory_preferences', 'insert'),
  true,
  'authenticated users can create their own memory settings'
);
select is(
  has_table_privilege(
    'authenticated',
    'public.memory_session_summaries',
    'insert'
  ),
  false,
  'clients cannot forge extraction audit summaries'
);

insert into auth.users (id, aud, role, email)
values
  (
    '51000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'm51-owner@example.test'
  ),
  (
    '51000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'm51-other@example.test'
  );

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"51000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select lives_ok(
  $$
    insert into public.memory_preferences (user_id)
    values ('51000000-0000-4000-8000-000000000001')
  $$,
  'a user can create their own preference row'
);
select lives_ok(
  $$
    insert into public.user_memories (
      user_id,
      memory_key,
      title,
      content,
      status,
      source_type,
      is_explicit
    ) values (
      '51000000-0000-4000-8000-000000000001',
      'preferred-answer-style',
      'Answer style',
      'Prefers concise answers.',
      'active',
      'manual',
      true
    )
  $$,
  'a user can create an owner-scoped explicit memory'
);

set local role postgres;
insert into public.user_memories (
  user_id,
  memory_key,
  title,
  content,
  status,
  source_type
) values (
  '51000000-0000-4000-8000-000000000002',
  'private-other-user-memory',
  'Private',
  'This belongs to another user.',
  'active',
  'manual'
);

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"51000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
select results_eq(
  $$
    select count(*)::bigint
    from public.user_memories
  $$,
  array[1::bigint],
  'RLS hides another user memory'
);

select * from finish();
rollback;
