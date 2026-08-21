-- Keep tombstone authentication checks on current JWT claims. auth.role()
-- is deprecated and anonymous sessions also use the authenticated DB role.
create or replace function private.apply_conversation_tombstone()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_jwt_role text := coalesce((select auth.jwt() ->> 'role'), '');
begin
  if old.deleted_at is not null then
    return old;
  end if;

  if new.deleted_at is null then
    return new;
  end if;

  if v_uid is not null and v_uid <> old.user_id then
    raise exception 'Conversation ownership mismatch';
  end if;
  if v_uid is null
     and v_jwt_role <> 'service_role'
     and session_user not in ('postgres', 'supabase_admin') then
    raise exception 'Conversation tombstone requires authentication';
  end if;

  new.user_id := old.user_id;
  new.deleted_at := pg_catalog.now();
  new.updated_at := greatest(
    coalesce(new.updated_at, new.deleted_at),
    new.deleted_at
  );

  delete from public.messages
  where conversation_id = old.id;

  return new;
end;
$$;

revoke all on function private.apply_conversation_tombstone()
  from public, anon, authenticated;

-- Legacy remote messages predate stable client IDs. Devices claim their
-- already-persisted local UUIDs in bounded batches, so a mapping-cache loss can
-- no longer duplicate the same cloud rows. SECURITY INVOKER keeps message and
-- conversation RLS in force; the explicit ownership predicate is defense in
-- depth and prevents claims outside the active account.
create or replace function public.claim_message_client_ids(claims jsonb)
returns table (id uuid, client_id uuid)
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_is_anonymous boolean := coalesce(
    (select (auth.jwt() ->> 'is_anonymous')::boolean),
    false
  );
begin
  if v_uid is null or v_is_anonymous then
    raise exception 'Message identity claims require a signed-in account';
  end if;
  if claims is null or pg_catalog.jsonb_typeof(claims) <> 'array' then
    raise exception 'Message identity claims must be a JSON array';
  end if;
  if pg_catalog.jsonb_array_length(claims) > 200 then
    raise exception 'Message identity claim batch exceeds 200 rows';
  end if;

  return query
  with parsed as materialized (
    select distinct on (claim.id)
      claim.id,
      claim.client_id
    from pg_catalog.jsonb_to_recordset(claims)
      as claim(id uuid, client_id uuid)
    where claim.id is not null
      and claim.client_id is not null
    order by claim.id, claim.client_id
  ),
  updated as (
    update public.messages as message
       set client_id = parsed.client_id
      from parsed
     where message.id = parsed.id
       and message.client_id is null
       and exists (
         select 1
         from public.conversations as conversation
         where conversation.id = message.conversation_id
           and conversation.user_id = v_uid
           and conversation.deleted_at is null
       )
    returning message.id, message.client_id
  ),
  existing as (
    select message.id, message.client_id
    from public.messages as message
    join parsed on parsed.id = message.id
    join public.conversations as conversation
      on conversation.id = message.conversation_id
    where message.client_id is not null
      and conversation.user_id = v_uid
      and conversation.deleted_at is null
  )
  select updated.id, updated.client_id
  from updated
  union all
  select existing.id, existing.client_id
  from existing
  where not exists (
    select 1 from updated where updated.id = existing.id
  );
end;
$$;

revoke all on function public.claim_message_client_ids(jsonb)
  from public, anon;
grant execute on function public.claim_message_client_ids(jsonb)
  to authenticated;
