# HowAI 2.0.5 release candidate

Status: engineering validation

Release: `2.0.5+50`

Scope: conversation drawer reliability, large-history performance, chat motion,
and Android/iOS release parity

If build 50 has already been uploaded to either store, increase the build
number before creating another artifact. Store build numbers must not be
reused.

## Included changes

- Keep drawer controls and vertical scrolling interactive while the opening
  spring is still moving.
- Let horizontal drawer gestures safely interrupt an animation without leaving
  an unresolved animation future.
- Lazily render active and archived conversation rows instead of laying out the
  full history on every drawer rebuild.
- Debounce local message-content searches and suppress redundant conversation
  provider notifications.
- Isolate streamed response refreshes from the rest of the chat surface.
- Smooth bottom following, stop following when the user reads older content,
  and expose an animated latest-message control.
- Preserve the viewport when older messages load into the reversed chat list.
- Apply shared reduced-motion-aware transitions to loading, typing, selection,
  search, and archived-section states.

## Automated gate

Run from a clean checkout with Flutter 3.44.6:

```sh
./scripts/release-gate.sh
```

The gate must pass localization checks, the inherited analyzer-warning budget,
Flutter tests, Edge Function contracts, release metadata checks, and the
Android debug/merged-manifest build.

Candidate validation completed on August 25, 2026:

- The complete automated gate passed, including 217 Flutter tests.
- A signed `2.0.5` (`50`) API 36 App Bundle was built and its JAR signature,
  application ID, version metadata, upload-key configuration, and Maps manifest
  injection were verified.
- The arm64 and x86_64 native libraries in the bundle use 16 KB-or-greater ELF
  LOAD alignment. Recheck Play's native-library diagnostics after upload because
  release 48 reports a legacy DataStore RELRO warning.
- The release app installed and launched on an Android 15/API 35 emulator. The
  drawer opened, search accepted input, and the profile row opened Settings.
- The iOS release target compiled successfully without code signing.

The physical-device matrix, store-delivered install, billing/sign-in checks,
and Play Console artifact scan remain required before production rollout.

## Store builds

Use only the allowlisted public mobile configuration. Provider API keys must
remain in Supabase secrets and must not be bundled into either app.

```sh
scripts/with-public-mobile-config.sh flutter build appbundle --release
scripts/with-public-mobile-config.sh flutter build ipa --release
```

Android release packaging must fail if `android/key.properties` or the upload
keystore is unavailable. Do not substitute a debug signing identity.

## Focused physical-device matrix

Run both an upgrade install and a fresh install on one physical iPhone and one
physical Android phone:

1. Open the drawer and immediately tap search, profile, settings, and a
   conversation while the panel is still moving.
2. Open the drawer and immediately scroll vertically; confirm the drawer does
   not freeze or begin a horizontal close gesture.
3. Fling a history containing at least 500 conversations, expand Archived, and
   search rapidly across titles and message contents.
4. Start a long streamed response, scroll upward while it is arriving, and
   confirm the app does not pull the viewport back down.
5. Tap the latest-message control and confirm it returns smoothly to the active
   response.
6. Load older messages and confirm the current reading position does not jump.
7. Show and dismiss the keyboard repeatedly while the composer is expanded and
   while a response is streaming.
8. Repeat the drawer, chat, keyboard, and loading-state checks in light mode,
   dark mode, large text, reduced-motion mode, and landscape.
9. Verify accountless mode, Google sign-in, Apple sign-in on iOS, subscription
   restore, notification deep links, microphone, camera, and when-in-use
   location permissions.

## Google Play checklist

- Upload the signed API 36 App Bundle to Internal testing first.
- Confirm version `2.0.5` and build `50` in the artifact explorer.
- Confirm the production upload certificate, Play App Signing status, mapping
  file, native debug symbols, and merged permission declarations.
- Verify Google sign-in and Play Billing restoration with a license tester.
- Recheck Data safety declarations for account identifiers, purchases, user
  content, optional audio/photos/location, and diagnostics.
- Install from the Internal testing track and complete the physical-device
  matrix before production promotion.

## App Store checklist

- Archive the same `2.0.5+50` source revision.
- Confirm distribution signing, push and Sign in with Apple entitlements,
  privacy manifest, Firebase configuration, and dSYMs.
- Install from TestFlight and complete the same focused matrix before release.

## Store release notes

> Conversation history is now smoother and more responsive, especially with
> large chat libraries. This update also fixes an issue that could freeze the
> side panel, improves live-response scrolling, and polishes animations across
> chat on iPhone and Android.

## Rollout and rollback

Hold both platforms in internal testing until the automated gate and the full
physical-device matrix pass. Promote Android and iOS from the same source
revision. Pause rollout immediately for a reproducible frozen drawer, viewport
jump, startup failure, entitlement failure, or signing mismatch. These changes
require no database migration and can be rolled back with the mobile binary.
