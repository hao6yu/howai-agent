import assert from 'node:assert/strict';
import test from 'node:test';

import {
  findForbiddenMobileSecretReferences,
  parsePubspecVersion,
  validateAndroidSourceManifest,
  validateMergedAndroidManifest,
  validateReleaseVersion,
} from './check-release-metadata.mjs';

const compliantSourceManifest = `
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
  <uses-feature
      android:name="android.hardware.camera.any"
      android:required="false"
      tools:replace="android:required" />
  <uses-permission
      android:name="Manifest.permission.CAPTURE_AUDIO_OUTPUT"
      tools:node="remove" />
</manifest>
`;

const compliantMergedManifest = `
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-feature
      android:name="android.hardware.camera.any"
      android:required="false" />
</manifest>
`;

test('parses the HowAI app version and numeric build', () => {
  assert.deepEqual(parsePubspecVersion('name: haogpt\nversion: 2.0.1+42\n'), {
    major: 2,
    minor: 0,
    patch: 1,
    build: 42,
  });
});

test('accepts the 2.0.1 release line and later build numbers', () => {
  assert.equal(
    validateReleaseVersion('version: 2.0.1+47\n').build,
    47,
  );
});

test('rejects the previous 2.0.0 release line', () => {
  assert.throws(
    () => validateReleaseVersion('version: 2.0.0+99\n'),
    /requires version 2\.0\.1/,
  );
});

test('rejects a reused build number', () => {
  assert.throws(
    () => validateReleaseVersion('version: 2.0.1+41\n'),
    /requires build 42 or newer/,
  );
});

test('rejects a version without a numeric build', () => {
  assert.throws(
    () => validateReleaseVersion('version: 2.0.1\n'),
    /numeric build/,
  );
});

test('rejects provider secret configuration in mobile source', () => {
  assert.deepEqual(
    findForbiddenMobileSecretReferences([
      {
        relativePath: 'lib/safe.dart',
        content: "const proxy = 'elevenlabs-proxy';",
      },
      {
        relativePath: 'lib/unsafe.dart',
        content: "String.fromEnvironment('ELEVENLABS_API_KEY');",
      },
    ]),
    ['lib/unsafe.dart'],
  );
});

test('accepts Android source manifest hardening rules', () => {
  assert.doesNotThrow(() =>
    validateAndroidSourceManifest(compliantSourceManifest),
  );
});

test('rejects broad Android photo-library access', () => {
  assert.throws(
    () =>
      validateAndroidSourceManifest(
        compliantSourceManifest.replace(
          '</manifest>',
          '<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />\n</manifest>',
        ),
      ),
    /system-selected media access/,
  );
});

test('requires camera hardware to remain optional', () => {
  assert.throws(
    () =>
      validateAndroidSourceManifest(
        compliantSourceManifest.replace(
          'android:required="false"',
          'android:required="true"',
        ),
      ),
    /camera\.any must be declared exactly once as an explicit optional override/,
  );
});

test('requires an explicit override for dependency camera requirements', () => {
  assert.throws(
    () =>
      validateAndroidSourceManifest(
        compliantSourceManifest.replace(
          'tools:replace="android:required"',
          '',
        ),
      ),
    /camera\.any must be declared exactly once as an explicit optional override/,
  );
});

test('requires removal of flutter_sound_core invalid permission', () => {
  assert.throws(
    () =>
      validateAndroidSourceManifest(
        compliantSourceManifest.replace('tools:node="remove"', ''),
      ),
    /must have a manifest removal rule/,
  );
});

test('accepts a hardened merged Android manifest', () => {
  assert.doesNotThrow(() =>
    validateMergedAndroidManifest(compliantMergedManifest),
  );
});

test('rejects required camera hardware in the merged Android manifest', () => {
  assert.throws(
    () =>
      validateMergedAndroidManifest(
        compliantMergedManifest.replace(
          'android:required="false"',
          'android:required="true"',
        ),
      ),
    /must keep android\.hardware\.camera\.any optional/,
  );
});

for (const permission of [
  'android.permission.READ_MEDIA_IMAGES',
  'Manifest.permission.CAPTURE_AUDIO_OUTPUT',
]) {
  test(`rejects ${permission} in the merged Android manifest`, () => {
    assert.throws(
      () =>
        validateMergedAndroidManifest(
          compliantMergedManifest.replace(
            '</manifest>',
            `<uses-permission android:name="${permission}" />\n</manifest>`,
          ),
        ),
      /contains forbidden permission/,
    );
  });
}
