#!/usr/bin/env node

import { createHash } from 'node:crypto';
import { mkdir, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const ENGINE_ROOT = path.resolve(SCRIPT_DIR, '..');
const DATA_ROOT = path.join(ENGINE_ROOT, 'src/engine/core/data');
const DEFAULT_OUTPUT = path.join(ENGINE_ROOT, 'dist/browser-data');
const VERSION = 1;
const GENERATED_ENTRIES = new Set(['manifest.json', 'lunar-solar', 'solar-terms']);

function parseArguments(argv) {
  let output = DEFAULT_OUTPUT;

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--output') {
      const value = argv[index + 1];
      if (!value) throw new Error('--output requires a directory path');
      output = path.resolve(process.cwd(), value);
      index += 1;
      continue;
    }
    if (argument === '--help' || argument === '-h') {
      console.log('Usage: node scripts/generate-browser-data-shards.mjs [--output <directory>]');
      process.exit(0);
    }
    throw new Error(`Unknown argument: ${argument}`);
  }

  return { output };
}

function stableJson(value) {
  return `${JSON.stringify(value)}\n`;
}

function sha256(content) {
  return createHash('sha256').update(content).digest('hex');
}

function yearFromKey(key) {
  const match = /^(\d{4})-/.exec(key);
  if (!match) throw new Error(`Invalid generated-data key: ${key}`);
  return Number(match[1]);
}

function groupEntriesByYear(record) {
  const result = new Map();
  for (const [key, value] of Object.entries(record)) {
    const year = yearFromKey(key);
    const entries = result.get(year) ?? [];
    entries.push([key, value]);
    result.set(year, entries);
  }
  return result;
}

async function writeShard(outputRoot, relativePath, payload, count) {
  const content = stableJson(payload);
  const destination = path.join(outputRoot, relativePath);
  await mkdir(path.dirname(destination), { recursive: true });
  await writeFile(destination, content, 'utf8');
  return {
    path: relativePath.split(path.sep).join('/'),
    count,
    bytes: Buffer.byteLength(content),
    sha256: sha256(content),
  };
}

async function readGeneratedJson(fileName) {
  return JSON.parse(await readFile(path.join(DATA_ROOT, fileName), 'utf8'));
}

async function prepareOutputRoot(outputRoot) {
  const resolved = path.resolve(outputRoot);
  if (resolved === path.parse(resolved).root || ENGINE_ROOT === resolved || ENGINE_ROOT.startsWith(`${resolved}${path.sep}`)) {
    throw new Error(`Refusing unsafe browser-data output directory: ${resolved}`);
  }

  await mkdir(resolved, { recursive: true });
  const entries = await readdir(resolved);
  if (entries.length === 0) return resolved;

  const unknown = entries.filter((entry) => !GENERATED_ENTRIES.has(entry));
  if (unknown.length > 0) {
    throw new Error(`Browser-data output contains unmanaged files: ${unknown.sort().join(', ')}`);
  }

  let previousManifest;
  try {
    previousManifest = JSON.parse(await readFile(path.join(resolved, 'manifest.json'), 'utf8'));
  } catch {
    throw new Error(`Browser-data output is not a recognized generated directory: ${resolved}`);
  }
  if (
    previousManifest?.version !== VERSION
    || typeof previousManifest?.lunarSolar !== 'object'
    || typeof previousManifest?.solarTerms !== 'object'
  ) {
    throw new Error(`Browser-data output has an unsupported manifest: ${resolved}`);
  }

  await Promise.all([
    rm(path.join(resolved, 'lunar-solar'), { recursive: true, force: true }),
    rm(path.join(resolved, 'solar-terms'), { recursive: true, force: true }),
  ]);
  return resolved;
}

export async function generateBrowserDataShards(outputRoot) {
  const [lunarSolar, solarTerms] = await Promise.all([
    readGeneratedJson('lunar-solar.generated.json'),
    readGeneratedJson('solar-terms.generated.json'),
  ]);

  const solarByYear = groupEntriesByYear(lunarSolar.solarToLunar);
  const lunarByYear = groupEntriesByYear(lunarSolar.lunarToSolar);
  const lunarYears = [...new Set([...solarByYear.keys(), ...lunarByYear.keys()])].sort((a, b) => a - b);
  const solarTermYears = Object.keys(solarTerms).map(Number).sort((a, b) => a - b);

  if (lunarYears.length === 0 || solarTermYears.length === 0) {
    throw new Error('Generated source data is empty');
  }

  outputRoot = await prepareOutputRoot(outputRoot);

  const lunarShards = {};
  for (const year of lunarYears) {
    const solarEntries = solarByYear.get(year) ?? [];
    const lunarEntries = lunarByYear.get(year) ?? [];
    const payload = {
      solarToLunar: Object.fromEntries(solarEntries),
      lunarToSolar: Object.fromEntries(lunarEntries),
    };
    lunarShards[String(year)] = await writeShard(
      outputRoot,
      path.join('lunar-solar', `${year}.json`),
      payload,
      {
        solarToLunar: solarEntries.length,
        lunarToSolar: lunarEntries.length,
        total: solarEntries.length + lunarEntries.length,
      },
    );
  }

  const solarTermShards = {};
  for (const year of solarTermYears) {
    const terms = solarTerms[String(year)];
    solarTermShards[String(year)] = await writeShard(
      outputRoot,
      path.join('solar-terms', `${year}.json`),
      terms,
      terms.length,
    );
  }

  const solarYears = [...solarByYear.keys()].sort((a, b) => a - b);
  const lunarKeyYears = [...lunarByYear.keys()].sort((a, b) => a - b);
  const manifest = {
    version: VERSION,
    lunarSolar: {
      range: { startYear: lunarYears[0], endYear: lunarYears.at(-1) },
      solarToLunarRange: { startYear: solarYears[0], endYear: solarYears.at(-1) },
      lunarToSolarRange: { startYear: lunarKeyYears[0], endYear: lunarKeyYears.at(-1) },
      count: {
        solarToLunar: Object.keys(lunarSolar.solarToLunar).length,
        lunarToSolar: Object.keys(lunarSolar.lunarToSolar).length,
      },
      shards: lunarShards,
    },
    solarTerms: {
      range: { startYear: solarTermYears[0], endYear: solarTermYears.at(-1) },
      count: solarTermYears.reduce((total, year) => total + solarTerms[String(year)].length, 0),
      shards: solarTermShards,
    },
  };
  const manifestContent = stableJson(manifest);
  await writeFile(path.join(outputRoot, 'manifest.json'), manifestContent, 'utf8');

  return manifest;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const { output } = parseArguments(process.argv.slice(2));
  const manifest = await generateBrowserDataShards(output);
  console.log(`Browser data shards written to ${output}`);
  console.log(`Lunar/solar years: ${manifest.lunarSolar.range.startYear}-${manifest.lunarSolar.range.endYear}`);
  console.log(`Solar-term years: ${manifest.solarTerms.range.startYear}-${manifest.solarTerms.range.endYear}`);
}
