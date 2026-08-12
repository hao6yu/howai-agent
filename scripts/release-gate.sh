#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Resolving Flutter dependencies"
flutter pub get

echo "==> Generating and checking localizations"
flutter gen-l10n
node scripts/check-localizations.mjs

echo "==> Running Flutter static analysis"
ANALYZE_LOG="$(mktemp)"
trap 'rm -f "$ANALYZE_LOG"' EXIT
set +e
flutter analyze --no-fatal-infos --no-fatal-warnings | tee "$ANALYZE_LOG"
ANALYZE_EXIT="${PIPESTATUS[0]}"
set -e

# HowAI 2.x has an inherited analyzer-warning budget. Keep the
# gate useful immediately by preventing that warning debt from increasing.
# Follow-up hardening slices should lower this budget as warnings are removed.
MAX_ANALYZER_WARNINGS=76
ANALYZER_WARNINGS="$(
  awk '/^[[:space:]]*warning / { count += 1 } END { print count + 0 }' "$ANALYZE_LOG"
)"
ANALYZER_ERRORS="$(
  awk '/^[[:space:]]*error / { count += 1 } END { print count + 0 }' "$ANALYZE_LOG"
)"
if (( ANALYZE_EXIT > 1 )); then
  echo "Static analysis failed unexpectedly with exit code ${ANALYZE_EXIT}" >&2
  exit "$ANALYZE_EXIT"
fi
if (( ANALYZER_ERRORS > 0 )); then
  echo "Static analysis found ${ANALYZER_ERRORS} error(s)" >&2
  exit 1
fi
if (( ANALYZER_WARNINGS > MAX_ANALYZER_WARNINGS )); then
  echo "Static analysis warning budget exceeded: ${ANALYZER_WARNINGS} > ${MAX_ANALYZER_WARNINGS}" >&2
  exit 1
fi
echo "Analyzer errors: ${ANALYZER_ERRORS}; warning budget: ${ANALYZER_WARNINGS}/${MAX_ANALYZER_WARNINGS}"

echo "==> Running Flutter tests"
flutter test

echo "==> Running Supabase Edge Function contract tests"
readonly DENO_VERSION="2.1.4"
# Ignore any package.json above the checkout so Deno cannot materialize a
# workspace-local node_modules directory from unrelated parent configuration.
DENO_NO_PACKAGE_JSON=1 npx --yes "deno@${DENO_VERSION}" check \
  --node-modules-dir=none \
  --frozen \
  --lock=deno.lock \
  supabase/functions/*/index.ts
DENO_NO_PACKAGE_JSON=1 npx --yes "deno@${DENO_VERSION}" test \
  --node-modules-dir=none \
  --frozen \
  --lock=deno.lock \
  --allow-env \
  --allow-read \
  supabase/functions/_shared/*.test.ts

echo "==> Checking release metadata and platform privacy files"
node --test scripts/check-release-metadata.test.mjs
node scripts/check-release-metadata.mjs

echo "==> Building the Android debug package"
# Besides exercising the Android build, Flutter creates android/local.properties
# here for clean CI checkouts before the release-only Gradle manifest task below.
flutter build apk --debug

echo "==> Merging and checking the Android release manifest"
(
  cd android
  ./gradlew --no-daemon --max-workers=2 app:processReleaseMainManifest
)
node scripts/check-release-metadata.mjs \
  --merged-android-manifest \
  build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml

APP_VERSION="$(awk '/^version:/ { print $2; exit }' pubspec.yaml)"
echo "==> HowAI ${APP_VERSION} automated release gate passed"
