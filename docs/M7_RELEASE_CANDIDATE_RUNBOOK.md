# M7 release candidate runbook

Status: ready for internal validation  
Release: `2.0.0+40`  
Rollout: internal, then full

M7 converts the completed HowAI 2.0 feature work into a reproducible mobile
release. M6 Persistent Research and the full M4.6 Places redesign remain
deferred and do not block this release.

## What M7 hardens

- Complete localization coverage for every shipped ARB locale.
- Firebase Crashlytics capture for uncaught Flutter, platform-dispatcher, and
  zoned asynchronous failures in non-debug builds.
- Android API 36 targeting and removal of unused foreground-service and legacy
  storage declarations.
- An app-owned Apple privacy manifest and removal of an unused always-location
  purpose string.
- A repeatable automated release gate in `scripts/release-gate.sh`.
- A simple internal-to-full feature rollout with a documented rollback.

Crashlytics intentionally does not attach the Supabase user ID, message text,
voice transcripts, prompts, device tokens, or automation content to crash
reports.

## Automated gate

From a clean checkout:

```sh
scripts/release-gate.sh
```

The gate resolves dependencies, generates localizations, checks every locale,
runs Flutter analysis and tests, runs the Edge Function contract tests, and
checks release metadata/privacy files.

The database job remains separate because it starts the local Supabase stack:

```sh
supabase start
supabase db lint --local --level warning
supabase test db
supabase stop --no-backup
```

Before a production build:

```sh
supabase migration list --linked
supabase db lint --linked --level warning
supabase db advisors --linked --type security --level warn --fail-on error
```

Known advisor warnings are reviewed, not silently ignored:

- Anonymous sessions are a deliberate accountless-mode feature. Owner-scoped
  policies continue to bind rows to `auth.uid()`.
- `pg_net` and the `cron` schema are managed scheduling dependencies.
- Existing per-row `auth.uid()` initialization warnings are performance debt,
  not cross-user access.
- Leaked-password protection should be enabled in Supabase if password login is
  introduced; the current mobile authentication paths are OAuth/anonymous.

## Internal release matrix

Use a signed release-mode build with the normal public `.env` proxy values.
Never add provider secrets to the app bundle.

Run these flows on one physical iPhone and one physical Android device:

1. Upgrade over the current production app without clearing local storage.
2. Fresh install, Google sign-in, Apple sign-in on iOS, and accountless mode.
3. Existing paid user entitlement restores as Pro after sign-in and app resume.
4. Text chat covers short chat, GPT-5.6, automatic current-data search,
   multilingual/code-switched replies, copy/selection, report, and retry.
5. One-time and recurring reminder create, edit, pause, resume, snooze, delete,
   foreground refresh, push delivery, and notification deep link.
6. News Automation create, approve, edit recurrence, Run now, verified
   conversation delivery, push notification, and failure withholding.
7. Realtime voice covers greeting, interruption, mute, search, spoken action
   approval, camera on/off, camera switching, session cleanup, and fallback.
8. Knowledge Hub covers personalization toggles, suggested memory review,
   chat/voice learning, opt-out, and owner isolation.
9. Light/dark mode, text scaling, VoiceOver/TalkBack labels, keyboard,
   landscape recovery, background/resume, and offline/error recovery.
10. Verify Crashlytics receives one deliberate internal non-fatal test event,
    then remove the test trigger before full rollout.

Do not advance while there is a reproducible startup crash, cross-user data
access, duplicate automation/reminder delivery, missing approval boundary, or
provider secret in a client artifact.

## Store and privacy checklist

### Apple

- Archive `2.0.0 (40)` from a clean release build.
- Confirm the archive contains `PrivacyInfo.xcprivacy`, the push entitlement,
  Firebase configuration, and readable Crashlytics symbols.
- App Privacy answers must describe account identifiers, purchases, user
  content, optional voice/camera inputs, diagnostics, and the stated
  app-functionality purposes. Mark tracking as not used.
- Usage descriptions must match the optional camera, microphone, photo, and
  when-in-use location behavior.
- Test Sign in with Apple and subscription restore in TestFlight.

### Google Play

- Build an API 36 Android App Bundle and upload it to Internal testing first.
- Complete Data safety for account identifiers, purchases, user content,
  optional audio/photos, diagnostics, and deletion behavior.
- Declare notification, microphone, camera, photo, and when-in-use location
  access only for their user-visible features.
- Verify Google sign-in and Play Billing restore with a license tester.

## Rollout

Keep the existing M1/M3/M4/M4.5/M5 flags in `internal` mode while the internal
matrix runs. Capture the current rows before changing anything:

```sql
select key, enabled, payload, updated_at
from public.feature_flags
order by key;
```

After internal sign-off, switch only the validated public features in one
transaction. Keep `automation_market_data` off until a structured market-data
provider is available, and keep `research_workspace` off because M6 is
deferred.

```sql
begin;

update public.feature_flags
set enabled = true,
    payload = jsonb_set(payload, '{mode}', '"full"', true),
    updated_at = now()
where key in (
  'reminders',
  'push_notifications',
  'automations',
  'automation_web_retrieval',
  'automation_validation',
  'automation_notifications',
  'realtime_voice'
);

commit;
```

Model-policy and free-search rollout retain their own server-owned quota and
cohort payloads; promote them only through their existing M1 canary procedure.

## Rollback

Store the pre-rollout feature rows with the release record. A fast functional
rollback is:

```sql
begin;

update public.feature_flags
set payload = jsonb_set(payload, '{mode}', '"internal"', true),
    updated_at = now()
where key in (
  'reminders',
  'push_notifications',
  'automations',
  'automation_web_retrieval',
  'automation_validation',
  'automation_notifications',
  'realtime_voice'
);

commit;
```

For a severe incident, set the affected row to `enabled = false` and
`payload.mode = "off"`. Do not roll back additive migrations merely to disable
a feature. Submit a mobile hotfix only after the server-side flag has limited
impact.

## Exit criteria

- Automated gate and local database tests pass from a clean checkout.
- iOS release archive and Android release bundle build successfully.
- Internal physical-device matrix passes.
- Crashlytics receives symbolicated release diagnostics without user content.
- Store privacy forms and release notes are complete.
- Rollback is exercised once in internal mode.
- Internal sign-off is recorded before the single full rollout.
