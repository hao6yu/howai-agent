# HowAI 2.0.1 — Trust and Polish

Status: Engineering hardening complete; manual release validation pending
Working release: `2.0.1+42`
Branch: `codex/howai-2-0-1-trust-polish`

## Release objective

HowAI 2.0.1 is a maintenance release focused on making the HowAI 2.0 feature
set dependable in normal mobile use. It does not add another major workspace or
provider integration.

The release should improve confidence in:

- app upgrades and fresh installs;
- authentication and subscription restoration;
- text chat, attachments, and streamed responses;
- reminders, generated Automations, push delivery, and deep links;
- Realtime voice, optional vision, and fallback behavior;
- sync, offline recovery, and user-visible error handling.

## Baseline — July 28, 2026

- `scripts/release-gate.sh` passes from the current checkout.
- 133 Flutter unit and widget tests pass.
- 144 Supabase Edge Function contract tests pass.
- Localization coverage is complete for 987 messages in 17 non-English
  locale files.
- Flutter analysis initially reported 503 issues, including 79 warnings. The
  2.0.1 gate prevents that warning debt from increasing and was tightened as
  the hardening work removed warnings.
- Physical-device, store-build, upgrade, and rollback checks remain manual
  release gates.

## Implemented engineering hardening

- Isolated SQLite databases and ID mappings by recoverable account, including a
  one-time move of legacy local data into the first account that claims it.
- Replaced volatile sync retries and title/timestamp duplicate guesses with a
  durable SQLite outbox and stable client UUIDs.
- Removed destructive duplicate cleanup, added complete pagination, preserved
  local profile identity, and round-tripped image and rich-message metadata.
- Changed database repair to use `PRAGMA quick_check`; a database is replaced
  only after SQLite reports corruption, and the original is backed up first.
- Deduplicated post-auth work, handled restored sessions and stream errors, and
  switched the active local store on every auth transition.
- Corrected audio playback state and listener lifecycles, added mobile and Edge
  request timeouts, and removed raw provider failures from user-facing errors.
- Added persistent speaker/earpiece routing, kept Realtime VAD active through
  the opening greeting, and aligned speaking/interruption state with audible
  WebRTC playback without fixed microphone-gating delays.
- Copied imported knowledge files into account-scoped app storage and replaced
  path-based fingerprints with SHA-256 content fingerprints.
- Removed all mobile ElevenLabs secret fallbacks. The proxy now derives the
  trusted entitlement cohort and atomically reserves quota before provider use.
- Pinned Supabase Edge dependencies with a Deno lockfile and made CI invoke the
  same release gate used locally.
- Updated the Android build to Gradle 8.14.3, Android Gradle Plugin 8.11.1, and
  Kotlin 2.2.20; removed the obsolete Jetifier transform.
- Upgraded the Flutter purchase stack to Google Play Billing Library 8, blocked
  purchases without a recoverable signed-in HowAI account, and corrected
  recurring-price display for trial offers.

Automated verification after these changes:

- 167 Flutter tests pass.
- 144 Supabase Edge Function contract tests pass.
- 305 database assertions pass and database lint reports no schema errors.
- Flutter analysis has no errors; the warning budget is now 76, down from 79.
- Debug and signed release APK builds pass with the updated toolchain, as does
  the Play Store App Bundle.

## Workstreams

### P0 — Release trust

- Run the signed-release physical-device matrix on iOS and Android.
- Validate upgrade over 2.0.0 without clearing local storage.
- Exercise server-side feature rollback before public enablement.
- Verify StoreKit and Play Billing restoration for existing subscribers.
- Confirm notification delivery is idempotent and deep links reopen the
  intended reminder, Automation, or conversation.

### P1 — Automated quality gate

- Accept and validate the `2.0.1` maintenance release line and require build 42
  or newer.
- Test release-version parsing and reject stale or malformed metadata.
- Prevent analyzer warnings from exceeding the inherited baseline.
- Lower the warning budget in small, behavior-preserving cleanup slices.
- Add smoke coverage around critical cross-service flows where practical.

### P2 — First-session and composer polish

- Progressively reveal secondary attachment and utility actions.
- Recheck compact-width grouping, thumb reach, and accidental-tap risk.
- Validate the path from first launch to first successful message or voice
  session.
- Preserve draft text and attachments through upgrade, paywall, and recoverable
  error paths.

### P3 — Recovery and observability

- Make authentication, entitlement, upload, stream, sync, push, and voice
  failures actionable without exposing provider internals.
- Verify Crashlytics diagnostics remain free of prompts, messages, transcripts,
  device tokens, and personal memory.
- Record privacy-safe success/failure signals needed to evaluate rollout
  reliability.
- Keep existing server-side kill switches and provider fallbacks operational.

### P4 — Maintenance debt

- Reconcile stale release documentation with the shipped build.
- Audit discontinued dependencies separately; do not combine broad dependency
  upgrades with reliability fixes.
- Continue extracting oversized chat and Places components only behind
  characterization tests.

## Explicitly out of scope

- Persistent Research projects.
- New calendars, task managers, messaging connectors, or market-data providers.
- Places and Maps redesign.
- A Provider/state-management migration.
- Adding another text-to-speech provider.
- Broad dependency-major upgrades.

## Definition of done

- The automated gate passes for the final `2.0.1` build.
- No analyzer warning exceeds the checked-in warning budget, and the budget does
  not increase.
- Signed iOS and Android builds pass the release matrix on physical devices.
- Upgrade, subscription restore, reminder/Automation delivery, Realtime voice,
  attachment streaming, and rollback paths pass.
- Store metadata, privacy disclosures, and release notes match the shipped
  behavior.
- No reproducible startup crash, cross-user access, duplicate notification,
  approval bypass, or client-bundled provider secret remains.
