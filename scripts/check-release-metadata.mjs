import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const releasePolicy = Object.freeze({
  major: 2,
  minor: 0,
  patch: 1,
  minimumBuild: 42,
});

export function parsePubspecVersion(pubspec) {
  const match = pubspec.match(
    /^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$/m,
  );
  if (!match) {
    throw new Error(
      'pubspec.yaml must contain a semantic app version with a numeric build.',
    );
  }

  return {
    major: Number(match[1]),
    minor: Number(match[2]),
    patch: Number(match[3]),
    build: Number(match[4]),
  };
}

export function validateReleaseVersion(pubspec, policy = releasePolicy) {
  const version = parsePubspecVersion(pubspec);
  const expectedVersion = `${policy.major}.${policy.minor}.${policy.patch}`;
  const actualVersion = `${version.major}.${version.minor}.${version.patch}`;

  if (actualVersion !== expectedVersion) {
    throw new Error(
      `HowAI 2.0.1 requires version ${expectedVersion}; found ${actualVersion}.`,
    );
  }
  if (version.build < policy.minimumBuild) {
    throw new Error(
      `HowAI 2.0.1 requires build ${policy.minimumBuild} or newer; found ${version.build}.`,
    );
  }

  return version;
}

export function findForbiddenMobileSecretReferences(files) {
  const forbidden = /\b(?:OPENAI_API_KEY|ELEVENLABS_API_KEY|XI_API_KEY)\b/;
  return files
    .filter(({ content }) => forbidden.test(content))
    .map(({ relativePath }) => relativePath);
}

function readDartSources(directory, rootDirectory) {
  const sources = [];
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      if (entry.name !== 'example') {
        sources.push(...readDartSources(absolutePath, rootDirectory));
      }
    } else if (entry.isFile() && entry.name.endsWith('.dart')) {
      sources.push({
        relativePath: path.relative(rootDirectory, absolutePath),
        content: fs.readFileSync(absolutePath, 'utf8'),
      });
    }
  }
  return sources;
}

export function validateReleaseMetadata(rootDirectory) {
  const pubspecPath = path.join(rootDirectory, 'pubspec.yaml');
  const pubspec = fs.readFileSync(pubspecPath, 'utf8');
  const version = validateReleaseVersion(pubspec);

  for (const relativePath of [
    'android/app/google-services.json',
    'ios/Runner/GoogleService-Info.plist',
    'ios/Runner/PrivacyInfo.xcprivacy',
  ]) {
    if (!fs.existsSync(path.join(rootDirectory, relativePath))) {
      throw new Error(`Missing release configuration: ${relativePath}`);
    }
  }

  const forbiddenSecretReferences = findForbiddenMobileSecretReferences(
    readDartSources(path.join(rootDirectory, 'lib'), rootDirectory),
  );
  if (forbiddenSecretReferences.length > 0) {
    throw new Error(
      `Provider secret configuration is forbidden in mobile sources: ${forbiddenSecretReferences.join(', ')}`,
    );
  }

  return version;
}

function run() {
  const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
  const rootDirectory = path.resolve(scriptDirectory, '..');
  const version = validateReleaseMetadata(rootDirectory);
  process.stdout.write(
    `Release metadata valid for ${version.major}.${version.minor}.${version.patch}+${version.build}\n`,
  );
}

const invokedPath = process.argv[1] ? path.resolve(process.argv[1]) : '';
if (invokedPath === fileURLToPath(import.meta.url)) {
  try {
    run();
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}
