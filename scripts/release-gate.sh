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
flutter analyze --no-fatal-infos --no-fatal-warnings

echo "==> Running Flutter tests"
flutter test

echo "==> Running Supabase Edge Function contract tests"
npx --yes deno@2.1.4 test \
  --no-lock \
  --allow-env \
  --allow-read \
  supabase/functions/_shared/*.test.ts

echo "==> Checking release metadata and platform privacy files"
node - <<'NODE'
const fs = require('node:fs');

const pubspec = fs.readFileSync('pubspec.yaml', 'utf8');
if (!/^version: 2\.0\.0\+\d+$/m.test(pubspec)) {
  throw new Error('M7 requires a 2.0.0 release version and numeric build.');
}

for (const file of [
  'android/app/google-services.json',
  'ios/Runner/GoogleService-Info.plist',
  'ios/Runner/PrivacyInfo.xcprivacy',
]) {
  if (!fs.existsSync(file)) {
    throw new Error(`Missing release configuration: ${file}`);
  }
}
NODE

echo "==> M7 automated release gate passed"
