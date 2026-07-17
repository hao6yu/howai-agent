alter table public.app_entitlements
  add column if not exists model_policy_canary boolean not null default false;

comment on column public.app_entitlements.model_policy_canary is
  'Private allowlist marker for the internal GPT-5.6 model-policy canary.';

update public.feature_flags
set payload = jsonb_build_object(
  'mode', 'off',
  'rollout_percent', 0,
  'rollout_salt', 'gpt56-m1-v1'
) || payload,
updated_at = now()
where key = 'model_policy_v2';

alter table public.openai_proxy_requests
  add column if not exists requested_alias text,
  add column if not exists rollout_cohort text,
  add column if not exists rollout_bucket smallint,
  add column if not exists rollout_percent smallint,
  add column if not exists eval_version text,
  add column if not exists error_category text;

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conname = 'openai_proxy_requests_rollout_cohort_check'
      and conrelid = 'public.openai_proxy_requests'::regclass
  ) then
    alter table public.openai_proxy_requests
      add constraint openai_proxy_requests_rollout_cohort_check
      check (
        rollout_cohort is null
        or rollout_cohort in ('legacy', 'internal', 'percentage')
      );
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conname = 'openai_proxy_requests_rollout_bucket_check'
      and conrelid = 'public.openai_proxy_requests'::regclass
  ) then
    alter table public.openai_proxy_requests
      add constraint openai_proxy_requests_rollout_bucket_check
      check (
        rollout_bucket is null
        or rollout_bucket between 0 and 9999
      );
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conname = 'openai_proxy_requests_rollout_percent_check'
      and conrelid = 'public.openai_proxy_requests'::regclass
  ) then
    alter table public.openai_proxy_requests
      add constraint openai_proxy_requests_rollout_percent_check
      check (
        rollout_percent is null
        or rollout_percent between 0 and 100
      );
  end if;
end
$$;

create index if not exists openai_proxy_requests_canary_created_idx
  on public.openai_proxy_requests (rollout_cohort, created_at desc)
  where rollout_cohort in ('internal', 'percentage');

create index if not exists openai_proxy_requests_usage_ledger_idx
  on public.openai_proxy_requests (usage_ledger_id)
  where usage_ledger_id is not null;

alter policy "Users can view their own OpenAI proxy logs"
  on public.openai_proxy_requests
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.openai_proxy_requests from anon, authenticated;
grant select on public.openai_proxy_requests to authenticated;
grant all on public.openai_proxy_requests to service_role;
