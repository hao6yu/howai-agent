begin;

create extension if not exists pgtap with schema extensions;
set local search_path = extensions, public, pg_catalog;
select plan(20);

select is(
  has_schema_privilege('authenticated', 'private', 'usage'),
  false,
  'authenticated clients cannot use the private schema'
);

select is(
  has_table_privilege(
    'authenticated',
    'private.trial_image_generation_usage',
    'select'
  ),
  false,
  'authenticated clients cannot read trial-image reservations'
);

select is(
  has_table_privilege(
    'service_role',
    'private.trial_image_generation_usage',
    'select'
  ),
  true,
  'the service role can inspect trial-image reservations'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.reserve_trial_image_generation(uuid,uuid,text,bigint,integer,integer,bigint,bigint)',
    'execute'
  ),
  false,
  'authenticated clients cannot reserve trial images'
);

select is(
  has_function_privilege(
    'service_role',
    'public.reserve_trial_image_generation(uuid,uuid,text,bigint,integer,integer,bigint,bigint)',
    'execute'
  ),
  true,
  'the service role can reserve trial images'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.reconcile_trial_image_generation(uuid,boolean,integer,bigint)',
    'execute'
  ),
  false,
  'authenticated clients cannot reconcile trial images'
);

select has_column(
  'public',
  'openai_proxy_requests',
  'image_generation_offered',
  'request telemetry records whether image generation was offered'
);

select has_column(
  'public',
  'openai_proxy_requests',
  'image_generation_calls',
  'request telemetry records completed image calls'
);

select has_column(
  'public',
  'openai_proxy_requests',
  'image_generation_quota_denied',
  'request telemetry records trial quota denials'
);

insert into auth.users (id, aud, role, email)
values
  (
    '12000000-0000-0000-0000-000000000001',
    'authenticated',
    'authenticated',
    'anonymous-image-trial@example.test'
  ),
  (
    '12000000-0000-0000-0000-000000000002',
    'authenticated',
    'authenticated',
    'free-image-trial@example.test'
  ),
  (
    '12000000-0000-0000-0000-000000000003',
    'authenticated',
    'authenticated',
    'global-image-trial@example.test'
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
  user_id,
  cohort,
  'primary_chat',
  'howai-chat',
  model_role,
  resolved_model,
  'low',
  1000
from (
  values
    (
      '42000000-0000-0000-0000-000000000001'::uuid,
      '12000000-0000-0000-0000-000000000001'::uuid,
      'anonymous',
      'nano',
      'gpt-5-nano'
    ),
    (
      '42000000-0000-0000-0000-000000000002'::uuid,
      '12000000-0000-0000-0000-000000000001'::uuid,
      'anonymous',
      'nano',
      'gpt-5-nano'
    ),
    (
      '42000000-0000-0000-0000-000000000003'::uuid,
      '12000000-0000-0000-0000-000000000001'::uuid,
      'anonymous',
      'nano',
      'gpt-5-nano'
    ),
    (
      '42000000-0000-0000-0000-000000000101'::uuid,
      '12000000-0000-0000-0000-000000000002'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    ),
    (
      '42000000-0000-0000-0000-000000000102'::uuid,
      '12000000-0000-0000-0000-000000000002'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    ),
    (
      '42000000-0000-0000-0000-000000000103'::uuid,
      '12000000-0000-0000-0000-000000000002'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    ),
    (
      '42000000-0000-0000-0000-000000000104'::uuid,
      '12000000-0000-0000-0000-000000000002'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    ),
    (
      '42000000-0000-0000-0000-000000000105'::uuid,
      '12000000-0000-0000-0000-000000000002'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    ),
    (
      '42000000-0000-0000-0000-000000000106'::uuid,
      '12000000-0000-0000-0000-000000000002'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    ),
    (
      '42000000-0000-0000-0000-000000000201'::uuid,
      '12000000-0000-0000-0000-000000000003'::uuid,
      'free',
      'luna',
      'gpt-5.6-luna'
    )
) as requests(
  request_id,
  user_id,
  cohort,
  model_role,
  resolved_model
);

select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set local role service_role;

select is(
  (
    select accepted
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000001',
      '42000000-0000-0000-0000-000000000001',
      'anonymous',
      10000, 1, 86400, 1000000, 10000000
    )
  ),
  true,
  'the anonymous trial accepts its first image reservation'
);

select is(
  (
    select accepted
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000001',
      '42000000-0000-0000-0000-000000000001',
      'anonymous',
      10000, 1, 86400, 1000000, 10000000
    )
  ),
  true,
  'retrying the same image request is idempotent while reserved'
);

select is(
  (select count(*) from private.trial_image_generation_usage),
  1::bigint,
  'an idempotent retry does not create a second reservation'
);

select is(
  (
    select reason
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000001',
      '42000000-0000-0000-0000-000000000002',
      'anonymous',
      10000, 1, 86400, 1000000, 10000000
    )
  ),
  'user_generation_limit',
  'a reserved image consumes the anonymous allowance atomically'
);

select lives_ok(
  $$select public.reconcile_trial_image_generation(
    '42000000-0000-0000-0000-000000000001', false, 0, 0
  )$$,
  'a response that did not generate an image releases its reservation'
);

select is(
  (
    select accepted
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000001',
      '42000000-0000-0000-0000-000000000002',
      'anonymous',
      10000, 1, 86400, 1000000, 10000000
    )
  ),
  true,
  'a released reservation restores the anonymous allowance'
);

select lives_ok(
  $$select public.reconcile_trial_image_generation(
    '42000000-0000-0000-0000-000000000002', true, 1, 10000
  )$$,
  'a completed image reconciles as successful usage'
);

select is(
  (
    select reason
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000001',
      '42000000-0000-0000-0000-000000000003',
      'anonymous',
      10000, 1, 86400, 1000000, 10000000
    )
  ),
  'user_generation_limit',
  'one completed image exhausts the anonymous daily trial'
);

select is(
  (
    select count(*)
    from (
      values
        ('42000000-0000-0000-0000-000000000101'::uuid),
        ('42000000-0000-0000-0000-000000000102'::uuid),
        ('42000000-0000-0000-0000-000000000103'::uuid),
        ('42000000-0000-0000-0000-000000000104'::uuid),
        ('42000000-0000-0000-0000-000000000105'::uuid)
    ) as request_ids(request_id)
    cross join lateral public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000002',
      request_ids.request_id,
      'free',
      10000, 5, 604800, 1000000, 10000000
    ) as reservation
    where reservation.accepted
  ),
  5::bigint,
  'signed-in Free users receive five weekly image reservations'
);

select is(
  (
    select reason
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000002',
      '42000000-0000-0000-0000-000000000106',
      'free',
      10000, 5, 604800, 1000000, 10000000
    )
  ),
  'user_generation_limit',
  'the sixth Free image reservation is denied'
);

select is(
  (
    select reason
    from public.reserve_trial_image_generation(
      '12000000-0000-0000-0000-000000000003',
      '42000000-0000-0000-0000-000000000201',
      'free',
      10000, 5, 604800, 60000, 60000
    )
  ),
  'global_daily_cost_limit',
  'the global trial-image circuit breaker includes reserved and reconciled cost'
);

select * from finish();
rollback;
