# M3 Actions beta runbook

M3 adds durable reminders and recurring reminders without push delivery. It is
controlled by the existing `reminders` feature flag and follows the agreed
rollout: internal accounts first, then a single full rollout.

## Safety boundary

1. GPT can emit only the strict `reminders_create` proposal tool.
2. The Edge Function authenticates the signed-in user and revalidates every
   title, timezone, local time, recurrence, conversation, and reminder version.
3. The app shows the normalized schedule and warnings in an approval card.
4. Only an explicit approval calls the service-only atomic database RPC.
5. Authenticated clients have owner-scoped read access but no direct insert,
   update, or delete privileges on reminder or action-audit tables.

Anonymous/local-only sessions cannot use server reminders. The app never claims
that a proposal was scheduled before the server returns a successful result.

## Internal rollout

The database migration leaves reminder mode `off`. For internal testing:

- deploy the `reminder-actions` and updated `openai-proxy` functions;
- set `feature_flags.reminders.enabled = true` and payload mode to `internal`;
- mark the intended test accounts with
  `app_entitlements.model_policy_canary = true`;
- leave all other accounts excluded.

For the later full rollout, change only the reminder flag payload mode to
`full`. The same flag can be disabled immediately as a write/tool kill switch.

## Internal acceptance flow

- Ask: “Remind me tomorrow at 9 AM to call Mom.”
- Confirm that chat shows a review card and does not claim the reminder exists.
- Approve it and confirm it appears under Actions → Upcoming.
- Ask for a daily, selected-weekday, and monthly reminder and verify the exact
  local time and timezone on each proposal.
- Exercise edit, snooze, pause/resume, skip next, complete, and delete. Every
  mutation must show a second approval before it changes the reminder.
- Reject a proposal and verify no reminder row is created.
- Repeat an approval request and confirm no duplicate reminder is created.
- Sign in as another account and confirm it cannot see the first account’s
  reminders or action history.
- Test a daylight-saving boundary in an IANA timezone and confirm the local
  wall-clock time remains stable.

## Automated verification

```sh
supabase db reset --local --no-seed
supabase test db
npx -y deno@2.1.4 check --no-lock \
  supabase/functions/openai-proxy/index.ts \
  supabase/functions/reminder-actions/index.ts
npx -y deno@2.1.4 test --no-lock \
  supabase/functions/_shared/reminder-recurrence.test.ts
flutter test
flutter analyze
```

M4 adds Firebase/APNs delivery, due-occurrence dispatch, notification actions,
and device deep links. M3 alone does not wake the user at the scheduled time.
