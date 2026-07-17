-- A verified store purchase may follow the current HowAI account on a device,
-- but it must never grant paid access to multiple accounts simultaneously.
create or replace function public.claim_store_entitlement(
  p_user_id uuid,
  p_source text,
  p_source_reference text,
  p_linked_source_reference text,
  p_verified_at timestamptz,
  p_expires_at timestamptz,
  p_metadata jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.role()) is distinct from 'service_role' then
    raise exception 'service role required' using errcode = '42501';
  end if;
  if p_source not in ('app_store', 'play_store') then
    raise exception 'invalid store source' using errcode = '22023';
  end if;
  if p_source_reference is null
    or length(btrim(p_source_reference)) = 0
    or length(p_source_reference) > 512 then
    raise exception 'invalid store reference' using errcode = '22023';
  end if;
  if p_expires_at is null or p_expires_at <= p_verified_at then
    raise exception 'store entitlement must have a future expiry'
      using errcode = '22023';
  end if;
  if p_metadata is null or jsonb_typeof(p_metadata) <> 'object' then
    raise exception 'metadata must be a JSON object' using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_source || ':' || p_source_reference, 0)
  );

  -- Transfer any previous claim before inserting the new one. Clearing the
  -- reference preserves the historical row without defeating the unique index.
  update public.app_entitlements
  set
    tier = 'free',
    source_reference = null,
    expires_at = p_verified_at,
    verified_at = p_verified_at,
    metadata = metadata || jsonb_build_object(
      'transferred_at', p_verified_at,
      'transferred_to_user_id', p_user_id
    ),
    updated_at = p_verified_at
  where source = p_source
    and (
      source_reference = p_source_reference
      or (
        p_linked_source_reference is not null
        and source_reference = p_linked_source_reference
      )
    )
    and user_id <> p_user_id;

  insert into public.app_entitlements (
    user_id,
    tier,
    source,
    source_reference,
    verified_at,
    expires_at,
    metadata,
    updated_at
  )
  values (
    p_user_id,
    'paid',
    p_source,
    p_source_reference,
    p_verified_at,
    p_expires_at,
    p_metadata,
    p_verified_at
  )
  on conflict (user_id) do update
  set
    tier = excluded.tier,
    source = excluded.source,
    source_reference = excluded.source_reference,
    verified_at = excluded.verified_at,
    expires_at = excluded.expires_at,
    metadata = excluded.metadata,
    updated_at = excluded.updated_at;
end;
$$;

revoke all on function public.claim_store_entitlement(
  uuid, text, text, text, timestamptz, timestamptz, jsonb
) from public, anon, authenticated;
grant execute on function public.claim_store_entitlement(
  uuid, text, text, text, timestamptz, timestamptz, jsonb
) to service_role;

comment on function public.claim_store_entitlement(
  uuid, text, text, text, timestamptz, timestamptz, jsonb
) is
  'Atomically transfers one server-verified store purchase to the current HowAI account.';

-- The old table contained client-reported purchase state and raw purchase
-- tokens. It is retained only for migration history and is no longer writable
-- or readable by mobile clients.
drop policy if exists "Users can insert own subscription status"
  on public.subscription_status;
drop policy if exists "Users can update own subscription status"
  on public.subscription_status;
drop policy if exists "Users can view own subscription status"
  on public.subscription_status;

revoke all on public.subscription_status from anon, authenticated;
grant all on public.subscription_status to service_role;

comment on table public.subscription_status is
  'Deprecated client-reported purchase state. Private and non-authoritative; use app_entitlements.';
