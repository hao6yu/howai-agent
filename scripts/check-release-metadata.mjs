import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const releasePolicy = Object.freeze({
  major: 2,
  minor: 0,
  patch: 3,
  minimumBuild: 48,
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
      `HowAI release requires version ${expectedVersion}; found ${actualVersion}.`,
    );
  }
  if (version.build < policy.minimumBuild) {
    throw new Error(
      `HowAI release requires build ${policy.minimumBuild} or newer; found ${version.build}.`,
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

function findManifestDeclarations(manifest, tagName, androidName) {
  const declarationPattern = new RegExp(`<${tagName}\\b[^>]*>`, 'g');
  return [...manifest.matchAll(declarationPattern)]
    .map(([declaration]) => declaration)
    .filter((declaration) => {
      const nameMatch = declaration.match(
        /\bandroid:name\s*=\s*["']([^"']+)["']/,
      );
      return nameMatch?.[1] === androidName;
    });
}

function readManifestAttribute(declaration, attributeName) {
  const escapedAttributeName = attributeName.replace(
    /[.*+?^${}()|[\]\\]/g,
    '\\$&',
  );
  const attributePattern = new RegExp(
    `\\b${escapedAttributeName}\\s*=\\s*["']([^"']+)["']`,
  );
  return declaration.match(attributePattern)?.[1];
}

export function validateAndroidSourceManifest(manifest) {
  if (
    findManifestDeclarations(
      manifest,
      'uses-permission',
      'android.permission.READ_MEDIA_IMAGES',
    ).length > 0
  ) {
    throw new Error(
      'Android must use system-selected media access, not READ_MEDIA_IMAGES.',
    );
  }

  const cameraFeatures = findManifestDeclarations(
    manifest,
    'uses-feature',
    'android.hardware.camera.any',
  );
  if (
    cameraFeatures.length !== 1 ||
    readManifestAttribute(cameraFeatures[0], 'android:required') !== 'false' ||
    readManifestAttribute(cameraFeatures[0], 'tools:replace') !==
      'android:required'
  ) {
    throw new Error(
      'android.hardware.camera.any must be declared exactly once as an explicit optional override.',
    );
  }

  const invalidPermissionRemovals = findManifestDeclarations(
    manifest,
    'uses-permission',
    'Manifest.permission.CAPTURE_AUDIO_OUTPUT',
  ).filter(
    (declaration) =>
      readManifestAttribute(declaration, 'tools:node') === 'remove',
  );
  if (invalidPermissionRemovals.length !== 1) {
    throw new Error(
      'The flutter_sound_core CAPTURE_AUDIO_OUTPUT permission must have a manifest removal rule.',
    );
  }
}

export function validateMergedAndroidManifest(manifest) {
  for (const permission of [
    'android.permission.READ_MEDIA_IMAGES',
    'Manifest.permission.CAPTURE_AUDIO_OUTPUT',
  ]) {
    if (
      findManifestDeclarations(manifest, 'uses-permission', permission).length >
      0
    ) {
      throw new Error(
        `Merged Android manifest contains forbidden permission: ${permission}.`,
      );
    }
  }

  const cameraFeatures = findManifestDeclarations(
    manifest,
    'uses-feature',
    'android.hardware.camera.any',
  );
  if (
    cameraFeatures.length !== 1 ||
    readManifestAttribute(cameraFeatures[0], 'android:required') !== 'false'
  ) {
    throw new Error(
      'Merged Android manifest must keep android.hardware.camera.any optional.',
    );
  }
}

export function validateAndroidReleaseSigningConfig(buildFile) {
  if (buildFile.includes('signingConfigs.getByName("debug")')) {
    throw new Error(
      'Android release builds must never fall back to the debug signing key.',
    );
  }
  if (!buildFile.includes('Release signing requires android/key.properties')) {
    throw new Error(
      'Android release builds must fail when key.properties is unavailable.',
    );
  }
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
  const androidManifest = fs.readFileSync(
    path.join(rootDirectory, 'android/app/src/main/AndroidManifest.xml'),
    'utf8',
  );
  validateAndroidSourceManifest(androidManifest);
  validateAndroidReleaseSigningConfig(
    fs.readFileSync(
      path.join(rootDirectory, 'android/app/build.gradle.kts'),
      'utf8',
    ),
  );

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
  const mergedManifestFlagIndex = process.argv.indexOf(
    '--merged-android-manifest',
  );
  if (mergedManifestFlagIndex >= 0) {
    const mergedManifestPath = process.argv[mergedManifestFlagIndex + 1];
    if (!mergedManifestPath) {
      throw new Error(
        '--merged-android-manifest requires a manifest file path.',
      );
    }
    validateMergedAndroidManifest(
      fs.readFileSync(path.resolve(rootDirectory, mergedManifestPath), 'utf8'),
    );
    process.stdout.write('Merged Android manifest policy valid\n');
    return;
  }

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
