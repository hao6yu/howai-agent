-- Conversation deletion is replicated as an immutable tombstone. Clients may
-- never infer deletion from a row being absent from a paginated response.
-- Production migration version: 20260821001125.
alter table public.conversations
  add column if not exists deleted_at timestamptz;

create index if not exists conversations_user_id_keyset_idx
  on public.conversations (user_id, id);

create index if not exists messages_conversation_id_id_keyset_idx
  on public.messages (conversation_id, id);

create schema if not exists private;

create or replace function private.apply_conversation_tombstone()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_role text := coalesce((select auth.role()), '');
begin
  -- A tombstone is final. Returning OLD makes retries and stale upserts safe:
  -- they become no-ops instead of clearing or rewriting the deletion marker.
  if old.deleted_at is not null then
    return old;
  end if;

  if new.deleted_at is null then
    return new;
  end if;

  -- RLS already checks ownership for API updates. Keep an explicit check in
  -- this SECURITY DEFINER function before it deletes child rows.
  if v_uid is not null and v_uid <> old.user_id then
    raise exception 'Conversation ownership mismatch';
  end if;
  if v_uid is null
     and v_role <> 'service_role'
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

drop trigger if exists apply_conversation_tombstone
  on public.conversations;
create trigger apply_conversation_tombstone
before update on public.conversations
for each row
execute function private.apply_conversation_tombstone();

-- Older app versions issue a physical DELETE. Convert authenticated API
-- deletes into the same tombstone transition so mixed-version devices remain
-- safe. Administrative/service-role deletes still work for account erasure
-- and referential cascades.
create or replace function private.convert_conversation_delete_to_tombstone()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    return old;
  end if;
  if v_uid <> old.user_id then
    raise exception 'Conversation ownership mismatch';
  end if;

  update public.conversations
     set deleted_at = pg_catalog.now(),
         updated_at = pg_catalog.now()
   where id = old.id
     and deleted_at is null;

  return null;
end;
$$;

revoke all on function private.convert_conversation_delete_to_tombstone()
  from public, anon, authenticated;

drop trigger if exists convert_conversation_delete_to_tombstone
  on public.conversations;
create trigger convert_conversation_delete_to_tombstone
before delete on public.conversations
for each row
execute function private.convert_conversation_delete_to_tombstone();

-- New messages can only be attached to active conversations. This closes the
-- race where a stale device inserts a child after another device tombstones
-- the parent.
alter policy "Users can insert messages in own conversations"
  on public.messages
  with check (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
        and conversations.deleted_at is null
    )
  );

alter policy "Users can update messages in own conversations"
  on public.messages
  using (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
        and conversations.deleted_at is null
    )
  )
  with check (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
        and conversations.deleted_at is null
    )
  );

alter policy "Users can view messages in own conversations"
  on public.messages
  using (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
        and conversations.deleted_at is null
    )
  );

comment on column public.conversations.deleted_at is
  'Immutable conversation deletion tombstone replicated to every device.';
