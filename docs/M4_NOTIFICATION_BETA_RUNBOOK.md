# M4 Notification beta runbook

M4 wakes signed-in users for approved reminders through Firebase Cloud
Messaging. It follows the hobby-app rollout agreed for HowAI: internal accounts
first, then one full rollout. Reminder writes and reminder delivery have
separate kill switches.

## Delivered boundary

- Firebase project: `howai-fcm-sender` (personal project dedicated to push
  delivery; Supabase remains the app's auth and data backend)
- Android app: `com.hyu.haogpt`
- iOS app: `com.hyu.HaoGPT`
- The Flutter app asks for notification permission only after the user approves
  a reminder or explicitly taps Enable in Actions.
- `push-devices` authenticates the current Supabase user and keeps FCM tokens in
  a service-only table. Tokens rotate, support multiple devices, and are
  disabled on sign-out or permanent FCM errors.
- Supabase Cron invokes `dispatch-reminders` once per minute. The worker creates
  one durable row per scheduled occurrence, claims work with a short lease,
  skips devices already sent successfully, retries transient provider errors,
  and advances recurring reminders from their local wall-clock rules.
- Lock-screen content includes the reminder title but never its notes.
- Tapping a reminder notification opens the Actions workspace. Direct Complete
  and Snooze buttons are deferred until their authenticated background-action
  path is supported consistently on both Android and iOS.

The migration leaves `push_notifications` disabled. A deployed client therefore
has no delivery behavior until the server flag and credentials are ready.

## Production credentials

Two long-lived credentials must never enter git or Flutter assets:

1. In Firebase Project settings → Service accounts, generate a private key for a
   dedicated sender service account with only the Firebase Cloud Messaging API
   permission needed to send messages. Store the complete JSON as the Supabase
   secret `FIREBASE_SERVICE_ACCOUNT_JSON`. The current sender belongs to the
   same `howai-fcm-sender` project as the mobile app registrations so it does
   not depend on organization-level cross-project IAM grants.
2. In Apple Developer, create or reuse an APNs authentication key (`.p8`). In
   Firebase Project settings → Cloud Messaging → Apple app, upload it with its
   Key ID and Apple Team ID. One APNs key can serve development and production.

Also generate a random value for `REMINDER_DISPATCH_SECRET`. Store it both as a
Supabase Edge Function secret and as the Vault secret
`howai_reminder_dispatch_secret`. Store
`https://yjxoreszkpdealtzyvyu.supabase.co` as Vault secret
`howai_project_url`. Use a temporary private env file outside the repository for
CLI secret upload and remove it afterward.

## Deployment sequence

1. Take private schema, role, and data backups of the linked Supabase project.
2. Apply migration `20260715071756_m4_push_notifications.sql` while the rollout
   flag remains off.
3. Deploy `push-devices` with JWT verification and `dispatch-reminders` without
   gateway JWT verification. The dispatcher performs its own constant-time
   scheduler-secret check.
4. Store the Firebase sender JSON and dispatcher secret in Supabase secrets;
   store the matching scheduler values in Vault.
5. Upload the APNs key to Firebase.
6. Set `feature_flags.push_notifications.enabled = true` and payload mode to
   `internal`. Internal access uses the existing
   `app_entitlements.model_policy_canary` marker.
7. Run the physical-device acceptance flow below. Change payload mode to `full`
   only after both iOS and Android pass.

Steps 1–4 are complete in production. A Vault-authenticated scheduler probe
returned HTTP 200 from `dispatch-reminders`. The notification flag remains off
until the APNs key and physical-device acceptance steps are complete.

Rollback is immediate: set `push_notifications.enabled = false`. This prevents
new token registrations and makes the claim RPC return no work. Existing
reminders remain intact. The Cron job may stay installed safely while the flag
is off.

## Internal acceptance flow

- Use a signed-in internal account. Create and approve a reminder two minutes
  ahead; accept the contextual notification prompt.
- Lock or background the physical device and confirm one notification arrives
  during the scheduled minute. Remote push timing is ultimately OS-controlled.
- Tap the notification and confirm HowAI opens Actions.
- Keep HowAI foregrounded for another reminder. Confirm Android presents it
  through the Reminders channel and iOS presents banner/sound once.
- Create daily and selected-weekday reminders around a daylight-saving boundary
  and verify the next occurrence preserves local wall-clock time.
- Register a second device for the same user and confirm both receive one copy.
- Trigger a worker retry and confirm a device with a prior successful attempt
  does not receive a duplicate.
- Sign out, then schedule from another signed-in device. Confirm the signed-out
  token remains disabled.
- Verify another non-internal account cannot register while mode is `internal`.

The iOS acceptance run must use a physical device. The simulator can exercise
permission and navigation UI but does not prove APNs token registration or
delivery.

## Automated verification

```sh
supabase db reset --local --no-seed
supabase test db
npx --yes deno fmt --check \
  supabase/functions/_shared/firebase-cloud-messaging.ts \
  supabase/functions/push-devices/index.ts \
  supabase/functions/dispatch-reminders/index.ts
npx --yes deno check \
  supabase/functions/_shared/firebase-cloud-messaging.ts \
  supabase/functions/push-devices/index.ts \
  supabase/functions/dispatch-reminders/index.ts
npx --yes deno test \
  supabase/functions/_shared/firebase-cloud-messaging.test.ts \
  supabase/functions/_shared/reminder-recurrence.test.ts
flutter test
flutter analyze
flutter build apk --debug
flutter build ios --debug --no-codesign
```
