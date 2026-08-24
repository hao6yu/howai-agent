-- Atomically reconcile signed store evidence in one short transaction.
--
-- StoreKit may redeliver transactions from the same subscription chain out of
-- order. A transaction with an older coverage end must never overwrite a newer
-- entitlement, while a revocation for the current coverage period must still
-- be able to remove access.
create or replace function public.reconcile_store_entitlement(
  p_user_id uuid,
  p_source text,
  p_source_reference text,
  p_linked_source_reference text,
  p_active boolean,
  p_verified_at timestamptz,
  p_expires_at timestamptz,
  p_revoked boolean default false,
  p_metadata jsonb default '{}'::jsonb
)
returns table (
  applied boolean,
  active boolean,
  effective_tier text,
  effective_source text,
  effective_source_reference text,
  effective_expires_at timestamptz,
  effective_verified_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_current public.app_entitlements%rowtype;
  v_has_current boolean := false;
  v_existing_revoked boolean := false;
  v_should_apply boolean := false;
begin
  if p_user_id is null then
    raise exception 'user id is required' using errcode = '22023';
  end if;
  if p_source not in ('app_store', 'play_store') then
    raise exception 'invalid store source' using errcode = '22023';
  end if;
  if p_source_reference is null
    or length(btrim(p_source_reference)) = 0
    or length(p_source_reference) > 512 then
    raise exception 'invalid store reference' using errcode = '22023';
  end if;
  if p_verified_at is null or p_expires_at is null then
    raise exception 'verified and expiration timestamps are required'
      using errcode = '22023';
  end if;
  if p_active and p_expires_at <= p_verified_at then
    raise exception 'active store entitlement must have a future expiry'
      using errcode = '22023';
  end if;
  if p_metadata is null or jsonb_typeof(p_metadata) <> 'object' then
    raise exception 'metadata must be a JSON object' using errcode = '22023';
  end if;

  -- All updates for one store subscription chain are ordered here. The Edge
  -- Function performs Apple/Google network verification before this RPC, so
  -- the lock is held only for local row reads and writes.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_source || ':' || p_source_reference, 0)
  );

  select *
  into v_current
  from public.app_entitlements
  where user_id = p_user_id
  for update;
  v_has_current := found;

  if not v_has_current then
    -- Do not create ownership claims from expired historical evidence.
    v_should_apply := p_active;
  elsif v_current.source = p_source
    and v_current.source_reference = p_source_reference then
    v_existing_revoked := v_current.metadata ->> 'revoked' = 'true';

    if v_current.expires_at is null then
      v_should_apply := p_active;
    elsif p_expires_at > v_current.expires_at then
      -- A later renewal/coverage period supersedes the stored transaction.
      v_should_apply := true;
    elsif p_expires_at = v_current.expires_at then
      -- On the same coverage period, revocation wins permanently. Otherwise
      -- the newer verification wins so expiration can take effect at term end.
      if v_existing_revoked and not p_revoked then
        v_should_apply := false;
      elsif p_revoked and not v_existing_revoked then
        v_should_apply := true;
      else
        v_should_apply := p_verified_at >= v_current.verified_at;
      end if;
    end if;
  elsif p_active then
    -- A different active store claim may replace an older store claim, but it
    -- may not shorten newer coverage or overwrite an active admin grant.
    if v_current.source in ('app_store', 'play_store') then
      v_should_apply := v_current.expires_at is null
        or p_expires_at > v_current.expires_at;
    else
      v_should_apply := v_current.tier <> 'paid'
        or (
          v_current.expires_at is not null
          and p_expires_at > v_current.expires_at
        );
    end if;
  end if;

  if v_should_apply then
    if p_active then
      -- A verified purchase may move to the signed-in HowAI account, but one
      -- store subscription must never grant two accounts simultaneously.
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
    end if;

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
      case when p_active then 'paid' else 'free' end,
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
  end if;

  select *
  into v_current
  from public.app_entitlements
  where user_id = p_user_id;
  v_has_current := found;

  if not v_has_current then
    return query select
      v_should_apply,
      false,
      'free'::text,
      null::text,
      null::text,
      null::timestamptz,
      null::timestamptz;
    return;
  end if;

  return query select
    v_should_apply,
    (
      v_current.tier = 'paid'
      and (
        v_current.expires_at is null
        or v_current.expires_at > pg_catalog.clock_timestamp()
      )
    ),
    v_current.tier,
    v_current.source,
    v_current.source_reference,
    v_current.expires_at,
    v_current.verified_at;
end;
$$;

revoke all on function public.reconcile_store_entitlement(
  uuid, text, text, text, boolean, timestamptz, timestamptz, boolean, jsonb
) from public, anon, authenticated;
grant execute on function public.reconcile_store_entitlement(
  uuid, text, text, text, boolean, timestamptz, timestamptz, boolean, jsonb
) to service_role;

comment on function public.reconcile_store_entitlement(
  uuid, text, text, text, boolean, timestamptz, timestamptz, boolean, jsonb
) is
  'Atomically applies only current server-verified store evidence and returns the final effective entitlement.';
