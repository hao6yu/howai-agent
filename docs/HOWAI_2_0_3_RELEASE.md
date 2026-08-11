# HowAI 2.0.3 release candidate

Status: engineering validation

Release: `2.0.3+48`

Scope: focused chat, photo, sync, and packaging hotfix

If build 48 has already been uploaded to either store, increase the build
number everywhere before creating artifacts. Never reuse an uploaded build.

## Included changes

- Prevent a stale cloud snapshot from deleting a conversation uploaded while
  that snapshot is downloading.
- Route photo analysis through the complete-response path while keeping normal
  text chat streaming enabled.
- Keep the chat request busy until a streamed response actually completes.
- Decode bounded attachment thumbnails instead of full-resolution camera files.
- Give photo-only conversations a localized provisional title.
- Pin the Edge Function Deno toolchain used by the release gate.
- Refuse to create Android release packages without the release keystore.
- Add regression coverage for stale sync snapshots, image response routing,
  photo-only titles, and bounded thumbnail decoding.

## Automated gate

Run from a clean checkout with Flutter 3.44.6:

```sh
./scripts/release-gate.sh
```

The gate must complete without changing `deno.lock` or leaving source changes.
It validates localization coverage, the analyzer warning budget, Flutter tests,
Edge Function contracts, release metadata, privacy files, and Android manifest
policy.

## Required build configuration

Create a private `.env` containing public mobile configuration. Provider API
keys must remain in Supabase secrets and must not be placed in the app bundle.

Android additionally requires:

- Android SDK and API 36 tooling;
- `android/key.properties` pointing to the production upload keystore;
- a non-empty `GOOGLE_MAPS_API_KEY` in `android/local.properties`.

iOS additionally requires:

- an Apple Distribution identity and the production team/profile;
- valid push and Sign in with Apple entitlements;
- App Store subscription products available in the release environment.

## Build commands

```sh
scripts/with-public-mobile-config.sh flutter build appbundle --release
scripts/with-public-mobile-config.sh flutter build ipa --release
```

The Android build intentionally fails when `android/key.properties` is absent.
Do not weaken this check or use a debug-signed artifact for store upload.

This repository is currently stored under iCloud-backed `Documents`. Finder
metadata can make iOS codesign reject generated frameworks. Prefer a clean
checkout outside iCloud for the archive. If an existing generated build is
affected, remove only its extended attributes and rebuild:

```sh
xattr -cr build/ios
```

## Focused physical-device matrix

Run on one physical iPhone and one physical Android device, using both an
upgrade install and a fresh install:

1. Start a new chat with one photo and no text. Confirm `Photo Analysis` (or
   its localized equivalent) appears immediately and the chat remains open
   until the answer is saved.
2. Start a new chat with a photo and text, then background and resume the app
   while the response is pending. Confirm the conversation remains selected.
3. Send several photos, remove one before sending, and confirm thumbnails stay
   responsive without a memory termination.
4. Send a normal text-only chat and confirm streaming still renders while the
   composer remains locked until completion.
5. With sync active on another device, create a photo chat during foreground
   refresh. Confirm it is present locally and remotely after another sync.
6. Force a photo-analysis timeout and an offline failure. Confirm the
   conversation retains its title and can be retried.
7. Verify sign-in, subscription restoration, photo allowance accounting,
   notification deep links, and account switching do not change behavior.

## Artifact inspection

- Confirm the displayed app version is `2.0.3` and build is `48` or higher.
- Confirm the iOS archive contains `PrivacyInfo.xcprivacy`, Firebase config,
  distribution provisioning, push entitlement, and symbol files.
- Confirm the Android AAB is signed by the production upload certificate and
  its merged manifest does not contain broad photo-library access.
- Install each signed artifact from its internal store track; do not validate
  only a debug or directly installed build.

## Store release notes

> Photo chats now stay open reliably while HowAI analyzes an image. This update
> also improves photo attachment memory use, conversation naming, streaming
> stability, and cloud conversation synchronization.

## Rollout and rollback

Release to TestFlight and Google Play Internal testing first. Hold promotion
for at least one complete focused-device pass. Do not promote with a
reproducible conversation disappearance, startup failure, entitlement failure,
or incorrectly signed artifact.

The sync change requires no schema migration and can be rolled back with the
mobile binary. If a severe chat or sync issue appears, pause store rollout;
server feature flags do not disable this local synchronization path.

## Deferred work

- Broad dependency upgrades and Swift Package Manager migration.
- General analyzer-debt cleanup.
- New attachment-count limits or other user-visible feature changes.
- Large chat-screen refactoring unrelated to the reported regression.
