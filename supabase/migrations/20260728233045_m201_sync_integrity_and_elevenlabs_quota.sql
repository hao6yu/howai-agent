-- Stable client identities make mobile retries idempotent and preserve the
-- originating local profile on another device.
alter table public.conversations
  add column if not exists client_id uuid,
  add column if not exists profile_client_id uuid,
  add column if not exists profile_name text;

alter table public.messages
  add column if not exists client_id uuid,
  add column if not exists metadata jsonb not null default '{}'::jsonb;

alter table public.messages
  drop constraint if exists messages_metadata_object;
alter table public.messages
  add constraint messages_metadata_object
  check (jsonb_typeof(metadata) = 'object');

create unique index if not exists conversations_user_client_id_key
  on public.conversations (user_id, client_id);

create unique index if not exists messages_conversation_client_id_key
  on public.messages (conversation_id, client_id);

create index if not exists conversations_user_profile_client_idx
  on public.conversations (user_id, profile_client_id);

-- Idempotent message upserts need UPDATE as well as INSERT/SELECT. Keep the
-- permission scoped to messages whose parent conversation belongs to the
-- authenticated user.
drop policy if exists "Users can update messages in own conversations"
  on public.messages;
create policy "Users can update messages in own conversations"
  on public.messages
  for update
  to authenticated
  using (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
    )
  )
  with check (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
    )
  );

-- Keep established RLS behavior while caching auth helpers once per statement.
-- This clears the per-row auth evaluation warnings from the database advisor.
alter policy "Users can update own user profile"
  on public.user_profiles
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter policy "Signed-in users can read their own action runs"
  on public.agent_action_runs
  using (
    (select auth.uid()) = user_id
    and coalesce(
      (((select auth.jwt()) ->> 'is_anonymous')::boolean),
      false
    ) = false
  );

alter policy "Signed-in users can read their own reminders"
  on public.reminders
  using (
    (select auth.uid()) = user_id
    and coalesce(
      (((select auth.jwt()) ->> 'is_anonymous')::boolean),
      false
    ) = false
  );

alter policy "Users can view own memories"
  on public.user_memories
  using ((select auth.uid()) = user_id);
alter policy "Users can insert own memories"
  on public.user_memories
  with check ((select auth.uid()) = user_id);
alter policy "Users can update own memories"
  on public.user_memories
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
alter policy "Users can delete own memories"
  on public.user_memories
  using ((select auth.uid()) = user_id);

alter policy "Users can view own memory summaries"
  on public.memory_session_summaries
  using ((select auth.uid()) = user_id);
alter policy "Users can delete own memory summaries"
  on public.memory_session_summaries
  using ((select auth.uid()) = user_id);

alter policy "Users can view own memory preferences"
  on public.memory_preferences
  using ((select auth.uid()) = user_id);
alter policy "Users can insert own memory preferences"
  on public.memory_preferences
  with check ((select auth.uid()) = user_id);
alter policy "Users can update own memory preferences"
  on public.memory_preferences
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
alter policy "Users can delete own memory preferences"
  on public.memory_preferences
  using ((select auth.uid()) = user_id);

drop policy "All users can view master personality"
  on public.ai_personalities;
drop policy "Users can view own AI personality"
  on public.ai_personalities;
create policy "Users can view available AI personalities"
  on public.ai_personalities
  for select
  to authenticated
  using (
    is_master = true
    or ((select auth.uid()) = user_id and is_master = false)
  );

-- Turn rate limiting into one locked database operation. The Edge Function
-- chooses limits from trusted authentication and entitlement state; clients
-- cannot execute this function directly.
alter table public.elevenlabs_proxy_requests
  alter column status_code set default 0;

drop policy if exists "Users can view their own ElevenLabs proxy logs"
  on public.elevenlabs_proxy_requests;
revoke all on public.elevenlabs_proxy_requests
  from public, anon, authenticated;
grant all on public.elevenlabs_proxy_requests to service_role;

create or replace function public.reserve_elevenlabs_proxy_request(
  p_user_id uuid,
  p_is_anonymous boolean,
  p_endpoint text,
  p_hourly_limit integer,
  p_daily_limit integer,
  p_request_bytes integer default 0
)
returns table (
  accepted boolean,
  reservation_id uuid,
  reason text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_hourly_count bigint;
  v_daily_count bigint;
  v_reservation_id uuid;
begin
  if p_user_id is null
     or p_endpoint is null
     or btrim(p_endpoint) = ''
     or p_hourly_limit < 1
     or p_daily_limit < 1
     or p_request_bytes < 0 then
    return query select false, null::uuid, 'invalid_request';
    return;
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_user_id::text, 0)
  );

  select count(*)
    into v_hourly_count
    from public.elevenlabs_proxy_requests request
   where request.user_id = p_user_id
     and request.created_at >= pg_catalog.now() - interval '1 hour';

  if v_hourly_count >= p_hourly_limit then
    return query select false, null::uuid, 'hourly_limit';
    return;
  end if;

  select count(*)
    into v_daily_count
    from public.elevenlabs_proxy_requests request
   where request.user_id = p_user_id
     and request.created_at >= pg_catalog.now() - interval '24 hours';

  if v_daily_count >= p_daily_limit then
    return query select false, null::uuid, 'daily_limit';
    return;
  end if;

  insert into public.elevenlabs_proxy_requests (
    user_id,
    is_anonymous,
    endpoint,
    status_code,
    request_bytes
  )
  values (
    p_user_id,
    p_is_anonymous,
    p_endpoint,
    0,
    p_request_bytes
  )
  returning id into v_reservation_id;

  return query select true, v_reservation_id, null::text;
end;
$$;

comment on function public.reserve_elevenlabs_proxy_request(
  uuid,
  boolean,
  text,
  integer,
  integer,
  integer
) is
  'Atomically reserves an ElevenLabs proxy request under service-selected quotas.';

revoke all on function public.reserve_elevenlabs_proxy_request(
  uuid,
  boolean,
  text,
  integer,
  integer,
  integer
) from public, anon, authenticated;
grant execute on function public.reserve_elevenlabs_proxy_request(
  uuid,
  boolean,
  text,
  integer,
  integer,
  integer
) to service_role;
