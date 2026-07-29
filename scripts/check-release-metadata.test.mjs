import assert from 'node:assert/strict';
import test from 'node:test';

import {
  findForbiddenMobileSecretReferences,
  parsePubspecVersion,
  validateReleaseVersion,
} from './check-release-metadata.mjs';

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
