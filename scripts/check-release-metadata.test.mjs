import assert from 'node:assert/strict';
import test from 'node:test';

import {
  findForbiddenMobileSecretReferences,
  parsePubspecVersion,
  validateAndroidReleaseSigningConfig,
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
  assert.deepEqual(parsePubspecVersion('name: haogpt\nversion: 2.0.5+50\n'), {
    major: 2,
    minor: 0,
    patch: 5,
    build: 50,
  });
});

test('accepts the 2.0.5 release line and later build numbers', () => {
  assert.equal(
    validateReleaseVersion('version: 2.0.5+50\n').build,
    50,
  );
});

test('rejects the previous 2.0.4 release line', () => {
  assert.throws(
    () => validateReleaseVersion('version: 2.0.4+99\n'),
    /requires version 2\.0\.5/,
  );
});

test('rejects a reused build number', () => {
  assert.throws(
    () => validateReleaseVersion('version: 2.0.5+49\n'),
    /requires build 50 or newer/,
  );
});

test('rejects a version without a numeric build', () => {
  assert.throws(
    () => validateReleaseVersion('version: 2.0.5\n'),
    /numeric build/,
  );
});

test('accepts fail-closed Android release signing', () => {
  assert.doesNotThrow(() =>
    validateAndroidReleaseSigningConfig(`
      throw GradleException("Release signing requires android/key.properties")
      signingConfig = signingConfigs.getByName("release")
    `),
  );
});

test('rejects Android debug signing fallback', () => {
  assert.throws(
    () =>
      validateAndroidReleaseSigningConfig(`
        signingConfig = signingConfigs.getByName("debug")
      `),
    /must never fall back to the debug signing key/,
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
