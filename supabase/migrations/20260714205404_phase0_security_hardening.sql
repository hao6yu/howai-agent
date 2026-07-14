-- Phase 0 security reconciliation for the pulled production baseline.
-- This migration is intentionally not deployed as part of the baseline pull.

revoke truncate, references, trigger on all tables in schema public
  from anon, authenticated;
revoke create on schema public from public, anon, authenticated;

alter default privileges in schema public
  revoke truncate, references, trigger on tables from anon, authenticated;

alter function public.create_user_personality_from_master(uuid)
  set search_path = 'public';
alter function public.get_merged_ai_context(uuid)
  set search_path = 'public';
alter function public.get_user_profile_context(uuid)
  set search_path = 'public';
alter function public.handle_new_user()
  set search_path = 'public';
alter function public.initialize_user_profile()
  set search_path = 'public';
alter function public.reset_user_personality_to_master(uuid)
  set search_path = 'public';
alter function public.update_updated_at_column()
  set search_path = 'public';

revoke all on function public.create_user_personality_from_master(uuid)
  from public, anon, authenticated;
revoke all on function public.get_merged_ai_context(uuid)
  from public, anon, authenticated;
revoke all on function public.get_user_profile_context(uuid)
  from public, anon, authenticated;
revoke all on function public.handle_new_user()
  from public, anon, authenticated;
revoke all on function public.initialize_user_profile()
  from public, anon, authenticated;
revoke all on function public.reset_user_personality_to_master(uuid)
  from public, anon, authenticated;
revoke all on function public.update_updated_at_column()
  from public, anon, authenticated;

grant execute on function public.create_user_personality_from_master(uuid)
  to service_role;
grant execute on function public.get_merged_ai_context(uuid)
  to service_role;
grant execute on function public.get_user_profile_context(uuid)
  to service_role;
grant execute on function public.reset_user_personality_to_master(uuid)
  to service_role;

alter view public.user_personality_status set (security_invoker = true);
revoke all on public.user_personality_status from public, anon, authenticated;
grant select on public.user_personality_status to authenticated;

alter policy "All users can view master personality"
  on public.ai_personalities
  to authenticated
  using (is_master = true);

alter policy "Users can create own AI personality"
  on public.ai_personalities
  to authenticated
  with check ((select auth.uid()) = user_id and is_master = false);

alter policy "Users can delete own AI personality"
  on public.ai_personalities
  to authenticated
  using ((select auth.uid()) = user_id);

alter policy "Users can update own AI personality"
  on public.ai_personalities
  to authenticated
  using ((select auth.uid()) = user_id and is_master = false)
  with check ((select auth.uid()) = user_id and is_master = false);

alter policy "Users can view own AI personality"
  on public.ai_personalities
  to authenticated
  using ((select auth.uid()) = user_id and is_master = false);

alter policy "Users can delete own conversations"
  on public.conversations
  to authenticated
  using ((select auth.uid()) = user_id);

alter policy "Users can insert own conversations"
  on public.conversations
  to authenticated
  with check ((select auth.uid()) = user_id);

alter policy "Users can update own conversations"
  on public.conversations
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter policy "Users can view own conversations"
  on public.conversations
  to authenticated
  using ((select auth.uid()) = user_id);

alter policy "Users can insert own feedback"
  on public.message_feedback
  to authenticated
  with check ((select auth.uid()) = user_id);

alter policy "Users can update own feedback"
  on public.message_feedback
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter policy "Users can view own feedback"
  on public.message_feedback
  to authenticated
  using ((select auth.uid()) = user_id);

alter policy "Users can insert messages in own conversations"
  on public.messages
  to authenticated
  with check (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
    )
  );

alter policy "Users can view messages in own conversations"
  on public.messages
  to authenticated
  using (
    exists (
      select 1
      from public.conversations
      where conversations.id = messages.conversation_id
        and conversations.user_id = (select auth.uid())
    )
  );

drop policy if exists "System can insert evaluations"
  on public.profile_evaluations;

create policy "Users can insert own evaluations"
  on public.profile_evaluations
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

alter policy "Users can view own evaluations"
  on public.profile_evaluations
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Service role can manage profiles" on public.profiles;

alter policy "Users can insert own profile"
  on public.profiles
  to authenticated
  with check ((select auth.uid()) = id);

alter policy "Users can update own profile"
  on public.profiles
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

alter policy "Users can view own profile"
  on public.profiles
  to authenticated
  using ((select auth.uid()) = id);

alter policy "Users can insert own subscription status"
  on public.subscription_status
  to authenticated
  with check ((select auth.uid()) = user_id);

alter policy "Users can update own subscription status"
  on public.subscription_status
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter policy "Users can view own subscription status"
  on public.subscription_status
  to authenticated
  using ((select auth.uid()) = user_id);

comment on table public.subscription_status is
  'Client-reported purchase sync state. Never use this table as authoritative model entitlement.';

alter policy "Users can insert own usage statistics"
  on public.usage_statistics
  to authenticated
  with check ((select auth.uid()) = user_id);

alter policy "Users can update own usage statistics"
  on public.usage_statistics
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter policy "Users can view own usage statistics"
  on public.usage_statistics
  to authenticated
  using ((select auth.uid()) = user_id);

alter policy "Users can insert own user profile"
  on public.user_profiles
  to authenticated
  with check ((select auth.uid()) = user_id);

alter policy "Users can update own user profile"
  on public.user_profiles
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter policy "Users can view own user profile"
  on public.user_profiles
  to authenticated
  using ((select auth.uid()) = user_id);

-- Public buckets remain downloadable by their public object URLs without a
-- blanket SELECT policy that also exposes object listings through the API.
drop policy if exists "public read generated images" on storage.objects;
