begin;

create extension if not exists pgtap with schema extensions;
set local role postgres;
set local search_path = extensions, public, pg_catalog;
select plan(14);

select has_column(
  'public',
  'profiles',
  'name_status',
  'profiles track preferred-name onboarding state'
);
select has_column(
  'public',
  'profiles',
  'name_source',
  'profiles track the origin of a preferred name'
);
select has_column(
  'public',
  'profiles',
  'name_prompted_at',
  'profiles track the one-time onboarding prompt'
);
select col_not_null(
  'public',
  'profiles',
  'name',
  'profile names always retain a safe display fallback'
);
select col_default_is(
  'public',
  'profiles',
  'name',
  'User',
  'the profile display fallback is User'
);
select col_default_is(
  'public',
  'profiles',
  'name_status',
  'unknown',
  'new profiles start with an unknown preferred name'
);

insert into auth.users (id, aud, role, email, raw_user_meta_data)
values
  (
    '71100000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'blank-name@example.test',
    '{}'::jsonb
  ),
  (
    '71100000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'literal-user@example.test',
    '{"name":"uSeR"}'::jsonb
  ),
  (
    '71100000-0000-4000-8000-000000000003',
    'authenticated',
    'authenticated',
    'email-handle@example.test',
    '{"name":"email-handle"}'::jsonb
  ),
  (
    '71100000-0000-4000-8000-000000000004',
    'authenticated',
    'authenticated',
    'real-name@example.test',
    '{"given_name":"  Hao   Yu  "}'::jsonb
  );

select is(
  (select name from public.profiles
   where id = '71100000-0000-4000-8000-000000000001'),
  'User',
  'missing metadata receives only the safe display fallback'
);
select is(
  (select name_status from public.profiles
   where id = '71100000-0000-4000-8000-000000000001'),
  'unknown',
  'missing metadata remains eligible for one onboarding prompt'
);
select is(
  (select name_status from public.profiles
   where id = '71100000-0000-4000-8000-000000000002'),
  'unknown',
  'literal User metadata is not trusted as a preferred name'
);
select is(
  (select name_status from public.profiles
   where id = '71100000-0000-4000-8000-000000000003'),
  'unknown',
  'an email handle is not trusted as a preferred name'
);
select is(
  (select name from public.profiles
   where id = '71100000-0000-4000-8000-000000000004'),
  'Hao Yu',
  'explicit auth metadata is normalized'
);
select is(
  (select name_status from public.profiles
   where id = '71100000-0000-4000-8000-000000000004'),
  'known',
  'explicit auth metadata is recognized as a known name'
);
select is(
  (select name_source from public.profiles
   where id = '71100000-0000-4000-8000-000000000004'),
  'auth',
  'explicit auth metadata records its source'
);

select throws_ok(
  $$
    update public.profiles
    set name_status = 'trusted-somehow'
    where id = '71100000-0000-4000-8000-000000000004'
  $$,
  '23514',
  null,
  'invalid name states are rejected'
);

select * from finish();
rollback;
