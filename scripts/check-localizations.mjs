#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDirectory, '..');
const l10nDirectory = path.join(root, 'lib', 'l10n');
const templatePath = path.join(l10nDirectory, 'app_en.arb');
const template = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
const messageKeys = Object.keys(template).filter(
  (key) => key !== '@@locale' && !key.startsWith('@'),
);

const localeFiles = fs
  .readdirSync(l10nDirectory)
  .filter((name) => /^app_.+\.arb$/.test(name) && name !== 'app_en.arb')
  .sort();

const failures = [];
for (const fileName of localeFiles) {
  const messages = JSON.parse(
    fs.readFileSync(path.join(l10nDirectory, fileName), 'utf8'),
  );
  const missing = messageKeys.filter((key) => !(key in messages));
  if (missing.length > 0) {
    failures.push(`${fileName}: ${missing.join(', ')}`);
  }
}

if (failures.length > 0) {
  console.error('Localization coverage is incomplete:');
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

console.log(
  `Localization coverage complete: ${messageKeys.length} messages across ${localeFiles.length} non-English locale files.`,
);
