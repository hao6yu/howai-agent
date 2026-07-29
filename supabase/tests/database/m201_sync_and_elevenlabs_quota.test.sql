begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(19);

select has_column(
  'public',
  'conversations',
  'client_id',
  'conversations have a stable client identity'
);
select has_column(
  'public',
  'conversations',
  'profile_client_id',
  'conversations preserve the originating profile'
);
select has_column(
  'public',
  'messages',
  'client_id',
  'messages have a stable client identity'
);
select has_column(
  'public',
  'messages',
  'metadata',
  'rich message metadata is persisted'
);
select ok(
  to_regclass('public.conversations_user_client_id_key') is not null,
  'conversation retry identity is unique per account'
);
select ok(
  to_regclass('public.messages_conversation_client_id_key') is not null,
  'message retry identity is unique per conversation'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.reserve_elevenlabs_proxy_request(uuid,boolean,text,integer,integer,integer)',
    'execute'
  ),
  false,
  'clients cannot bypass ElevenLabs authorization'
);
select is(
  has_function_privilege(
    'service_role',
    'public.reserve_elevenlabs_proxy_request(uuid,boolean,text,integer,integer,integer)',
    'execute'
  ),
  true,
  'the Edge Function can reserve ElevenLabs usage'
);
select is(
  has_table_privilege(
    'authenticated',
    'public.elevenlabs_proxy_requests',
    'select'
  ),
  false,
  'provider diagnostics are not exposed through the Data API'
);

insert into auth.users (id, aud, role, email)
values
  (
    '51000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'elevenlabs-quota@example.test'
  ),
  (
    '51000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'sync-isolation@example.test'
  );

insert into public.conversations (id, user_id, title)
values
  (
    '52000000-0000-4000-8000-000000000001',
    '51000000-0000-4000-8000-000000000001',
    'Owned conversation'
  ),
  (
    '52000000-0000-4000-8000-000000000002',
    '51000000-0000-4000-8000-000000000002',
    'Other conversation'
  );

insert into public.messages (id, conversation_id, content, client_id)
values
  (
    '53000000-0000-4000-8000-000000000001',
    '52000000-0000-4000-8000-000000000001',
    'Before retry',
    '54000000-0000-4000-8000-000000000001'
  ),
  (
    '53000000-0000-4000-8000-000000000002',
    '52000000-0000-4000-8000-000000000002',
    'Other user message',
    '54000000-0000-4000-8000-000000000002'
  );

set local role authenticated;
select set_config(
  'request.jwt.claims',
  '{"sub":"51000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);

select results_eq(
  $$
    update public.messages
       set content = 'Retry succeeded'
     where id = '53000000-0000-4000-8000-000000000001'
     returning content
  $$,
  $$ values ('Retry succeeded'::text) $$,
  'idempotent message retry can update the account owner''s row'
);
select is_empty(
  $$
    update public.messages
       set content = 'Cross-account write'
     where id = '53000000-0000-4000-8000-000000000002'
     returning id
  $$,
  'message retry cannot update another account''s row'
);

reset role;
set local role service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);

create temporary table first_reservation as
select *
from public.reserve_elevenlabs_proxy_request(
  '51000000-0000-4000-8000-000000000001',
  false,
  '/v1/voices',
  1,
  2,
  0
);

select is(
  (select accepted from first_reservation),
  true,
  'the first server-authorized request is reserved'
);
select isnt(
  (select reservation_id from first_reservation),
  null::uuid,
  'the reservation returns its audit row'
);
select is(
  (
    select reason
    from public.reserve_elevenlabs_proxy_request(
      '51000000-0000-4000-8000-000000000001',
      false,
      '/v1/voices',
      1,
      2,
      0
    )
  ),
  'hourly_limit',
  'an overlapping request cannot race past the hourly quota'
);

update public.elevenlabs_proxy_requests
set created_at = now() - interval '2 hours'
where id = (select reservation_id from first_reservation);

select is(
  (
    select accepted
    from public.reserve_elevenlabs_proxy_request(
      '51000000-0000-4000-8000-000000000001',
      false,
      '/v1/text-to-speech/test',
      10,
      2,
      12
    )
  ),
  true,
  'a later request is accepted inside the daily quota'
);
select is(
  (
    select reason
    from public.reserve_elevenlabs_proxy_request(
      '51000000-0000-4000-8000-000000000001',
      false,
      '/v1/text-to-speech/test',
      10,
      2,
      12
    )
  ),
  'daily_limit',
  'reserved requests consume the daily quota immediately'
);
select is(
  (
    select count(*)
    from public.elevenlabs_proxy_requests
    where user_id = '51000000-0000-4000-8000-000000000001'
  ),
  2::bigint,
  'rejected reservations do not create audit rows'
);
select is(
  (
    select accepted
    from public.reserve_elevenlabs_proxy_request(
      '51000000-0000-4000-8000-000000000001',
      false,
      '',
      10,
      10,
      0
    )
  ),
  false,
  'invalid reservation policy fails closed'
);
select is(
  (
    select status_code
    from public.elevenlabs_proxy_requests
    where id = (select reservation_id from first_reservation)
  ),
  0,
  'a reservation begins pending until the proxy finalizes it'
);

select * from finish();
rollback;
