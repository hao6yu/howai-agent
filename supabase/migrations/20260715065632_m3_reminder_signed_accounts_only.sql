-- Supabase anonymous sessions use the authenticated Postgres role. Keep
-- reminder reads limited to recoverable signed-in accounts at the RLS layer,
-- matching the Edge Function's authentication boundary.

drop policy "Users can read their own action runs"
  on public.agent_action_runs;

create policy "Signed-in users can read their own action runs"
  on public.agent_action_runs
  for select
  to authenticated
  using (
    (select auth.uid()) = user_id
    and coalesce(
      (select (auth.jwt() ->> 'is_anonymous')::boolean),
      false
    ) = false
  );

drop policy "Users can read their own reminders"
  on public.reminders;

create policy "Signed-in users can read their own reminders"
  on public.reminders
  for select
  to authenticated
  using (
    (select auth.uid()) = user_id
    and coalesce(
      (select (auth.jwt() ->> 'is_anonymous')::boolean),
      false
    ) = false
  );
