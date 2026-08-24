begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(27);

select is(
  has_function_privilege(
    'authenticated',
    'public.reconcile_store_entitlement(uuid,text,text,text,boolean,timestamptz,timestamptz,boolean,jsonb)',
    'execute'
  ),
  false,
  'mobile clients cannot call store reconciliation directly'
);
select is(
  has_function_privilege(
    'service_role',
    'public.reconcile_store_entitlement(uuid,text,text,text,boolean,timestamptz,timestamptz,boolean,jsonb)',
    'execute'
  ),
  true,
  'only the trusted service can reconcile store evidence'
);

insert into auth.users (id, aud, role, email)
values
  ('91000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'store-one@example.test'),
  ('91000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'store-two@example.test');

set local role service_role;

create temporary table expired_without_claim as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'app_store',
  'apple-chain-1',
  null,
  false,
  now(),
  now() - interval '18 days',
  false,
  '{"transaction_id":"expired-first","revoked":false}'::jsonb
);
select is(
  (select applied from expired_without_claim),
  false,
  'expired history does not create a store ownership claim'
);
select is(
  (select count(*) from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  0::bigint,
  'expired history leaves an account without an entitlement row unchanged'
);

create temporary table current_renewal as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'app_store',
  'apple-chain-1',
  null,
  true,
  now() + interval '1 second',
  now() + interval '30 days',
  false,
  '{"transaction_id":"current-renewal","revoked":false}'::jsonb
);
select is((select applied from current_renewal), true, 'a current renewal is applied');
select is((select active from current_renewal), true, 'a current renewal grants access');
select is(
  (select tier from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  'paid',
  'the current renewal is stored as paid'
);

create temporary table stale_expiration as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'app_store',
  'apple-chain-1',
  null,
  false,
  now() + interval '2 seconds',
  now() - interval '18 days',
  false,
  '{"transaction_id":"stale-expired","revoked":false}'::jsonb
);
select is(
  (select applied from stale_expiration),
  false,
  'an older expiration cannot overwrite newer coverage'
);
select is(
  (select active from stale_expiration),
  true,
  'the RPC returns the final active entitlement after ignoring stale evidence'
);
select is(
  (select metadata ->> 'transaction_id' from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  'current-renewal',
  'ignored evidence does not replace current transaction metadata'
);

create temporary table current_revocation as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'app_store',
  'apple-chain-1',
  null,
  false,
  now() + interval '3 seconds',
  now() + interval '30 days',
  true,
  '{"transaction_id":"current-renewal","revoked":true}'::jsonb
);
select is((select applied from current_revocation), true, 'a current-period revocation is applied');
select is((select active from current_revocation), false, 'a current-period revocation removes access');
select is(
  (select tier from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  'free',
  'a current-period revocation is stored as free'
);

create temporary table stale_active_replay as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'app_store',
  'apple-chain-1',
  null,
  true,
  now() + interval '4 seconds',
  now() + interval '30 days',
  false,
  '{"transaction_id":"current-renewal","revoked":false}'::jsonb
);
select is(
  (select applied from stale_active_replay),
  false,
  'the same transaction cannot resurrect access after revocation'
);
select is(
  (select active from stale_active_replay),
  false,
  'revocation remains authoritative after an active replay'
);

create temporary table later_renewal as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'app_store',
  'apple-chain-1',
  null,
  true,
  now() + interval '5 seconds',
  now() + interval '60 days',
  false,
  '{"transaction_id":"later-renewal","revoked":false}'::jsonb
);
select is((select applied from later_renewal), true, 'a genuinely later renewal supersedes revocation');
select is((select active from later_renewal), true, 'a genuinely later renewal restores access');

create temporary table transferred_claim as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000002',
  'app_store',
  'apple-chain-1',
  null,
  true,
  now() + interval '6 seconds',
  now() + interval '61 days',
  false,
  '{"transaction_id":"transferred-renewal","revoked":false}'::jsonb
);
select is(
  (select tier from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  'free',
  'a transferred subscription removes access from the previous account'
);
select is(
  (select tier from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000002'),
  'paid',
  'a transferred subscription grants only the current account'
);

create temporary table play_initial_claim as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'play_store',
  'play-token-old',
  null,
  true,
  now() + interval '7 seconds',
  now() + interval '20 days',
  false,
  '{"product_id":"monthly","subscription_state":"SUBSCRIPTION_STATE_ACTIVE","revoked":false}'::jsonb
);
select is((select applied from play_initial_claim), true, 'an active Google Play token is applied');
select is(
  (select source_reference from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  'play-token-old',
  'the active Google Play token becomes the ownership reference'
);

create temporary table play_linked_renewal as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'play_store',
  'play-token-new',
  'play-token-old',
  true,
  now() + interval '8 seconds',
  now() + interval '40 days',
  false,
  '{"product_id":"yearly","subscription_state":"SUBSCRIPTION_STATE_ACTIVE","revoked":false}'::jsonb
);
select is((select applied from play_linked_renewal), true, 'a linked Google Play replacement is one subscription chain');
select is(
  (select source_reference from public.app_entitlements where user_id = '91000000-0000-4000-8000-000000000001'),
  'play-token-new',
  'the linked replacement advances the stored Google Play token'
);

create temporary table play_stale_old_token as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'play_store',
  'play-token-old',
  null,
  false,
  now() + interval '9 seconds',
  now() + interval '20 days',
  false,
  '{"product_id":"monthly","subscription_state":"SUBSCRIPTION_STATE_EXPIRED","revoked":false}'::jsonb
);
select is((select applied from play_stale_old_token), false, 'an old linked Google token cannot overwrite its replacement');
select is((select active from play_stale_old_token), true, 'stale Google Play evidence returns the effective active replacement');

create temporary table play_on_hold as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'play_store',
  'play-token-new',
  'play-token-old',
  false,
  now() + interval '10 seconds',
  now() + interval '40 days',
  false,
  '{"product_id":"yearly","subscription_state":"SUBSCRIPTION_STATE_ON_HOLD","revoked":false}'::jsonb
);
select is((select active from play_on_hold), false, 'a current Google Play hold removes access');

create temporary table play_recovered as
select * from public.reconcile_store_entitlement(
  '91000000-0000-4000-8000-000000000001',
  'play_store',
  'play-token-new',
  'play-token-old',
  true,
  now() + interval '11 seconds',
  now() + interval '40 days',
  false,
  '{"product_id":"yearly","subscription_state":"SUBSCRIPTION_STATE_ACTIVE","revoked":false}'::jsonb
);
select is((select active from play_recovered), true, 'a newer Google Play recovery can restore the same coverage period');

reset role;
select * from finish();
rollback;
