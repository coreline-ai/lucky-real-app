import { createRequire } from 'node:module';
import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

const solarTermsByYear = require('../src/engine/core/data/solar-terms.generated.json');
const { getSolarTermsOfYear } = require('manseryeok');

const outputPath = process.argv[2] ? path.resolve(rootDir, process.argv[2]) : null;
const RAW_START_YEAR = 1899;
const START_YEAR = 1900;
const END_YEAR = 2101;
const TERMS_PER_YEAR = 24;
const SOURCE_TO_KST_OFFSET_HOURS = 1;
const MAX_ALLOWED_DRIFT_MS = 2 * 60 * 1000;
const SAMPLE_TERM_INDEXES_2024 = new Set([2, 4]); // ipchun and gyeongchip boundary cases.

function sourceTermToTimestamp(term) {
  return Date.UTC(term.year, term.month - 1, term.day, term.hour, term.minute, term.second);
}

function normalizeToKst(term) {
  const shifted = new Date(Date.UTC(
    term.year,
    term.month - 1,
    term.day,
    term.hour + SOURCE_TO_KST_OFFSET_HOURS,
    term.minute,
    term.second,
  ));

  return {
    ...term,
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1,
    day: shifted.getUTCDate(),
    hour: shifted.getUTCHours(),
    minute: shifted.getUTCMinutes(),
    second: shifted.getUTCSeconds(),
    julianDay: term.julianDay + SOURCE_TO_KST_OFFSET_HOURS / 24,
  };
}

function kstTermToUtcTimestamp(term) {
  return Date.UTC(term.year, term.month - 1, term.day, term.hour - 9, term.minute, term.second);
}

function pad(value) {
  return String(value).padStart(2, '0');
}

function formatKst(term) {
  return `${term.year}-${pad(term.month)}-${pad(term.day)} ${pad(term.hour)}:${pad(term.minute)}:${pad(term.second)} KST`;
}

function escapeCell(value) {
  return String(value ?? '').replaceAll('|', '\\|').replace(/\s+/g, ' ').trim();
}

function verifyRawData() {
  const mismatches = [];

  for (let year = RAW_START_YEAR; year <= END_YEAR; year += 1) {
    const terms = solarTermsByYear[String(year)] ?? [];
    if (terms.length !== TERMS_PER_YEAR) {
      mismatches.push(`${year}: count=${terms.length}`);
      continue;
    }

    for (let index = 0; index < terms.length; index += 1) {
      const term = terms[index];
      if (term.year !== year) mismatches.push(`${year}#${index}: term.year=${term.year}`);
      if (term.month < 1 || term.month > 12) mismatches.push(`${year}#${index}: month=${term.month}`);
      if (term.day < 1 || term.day > 31) mismatches.push(`${year}#${index}: day=${term.day}`);
      if (term.hour < 0 || term.hour > 23) mismatches.push(`${year}#${index}: hour=${term.hour}`);
      if (term.minute < 0 || term.minute > 59) mismatches.push(`${year}#${index}: minute=${term.minute}`);
      if (term.second < 0 || term.second > 59) mismatches.push(`${year}#${index}: second=${term.second}`);
      if (!Number.isFinite(term.julianDay)) mismatches.push(`${year}#${index}: julianDay=${term.julianDay}`);

      if (index > 0) {
        const previous = terms[index - 1];
        if (term.julianDay <= previous.julianDay) {
          mismatches.push(`${year}#${index}: non-increasing julianDay`);
        }
        if (sourceTermToTimestamp(term) <= sourceTermToTimestamp(previous)) {
          mismatches.push(`${year}#${index}: non-increasing source timestamp`);
        }
      }
    }
  }

  return mismatches;
}

function verifyProvider() {
  const mismatches = [];
  let maxDriftMs = 0;
  let maxDriftCase = null;
  let comparedTerms = 0;
  const samples = [];

  for (let year = START_YEAR; year <= END_YEAR; year += 1) {
    const ours = (solarTermsByYear[String(year)] ?? []).map(normalizeToKst);
    const provider = getSolarTermsOfYear(year);

    if (ours.length !== TERMS_PER_YEAR || provider.length !== TERMS_PER_YEAR) {
      mismatches.push(`${year}: count ours=${ours.length} provider=${provider.length}`);
      continue;
    }

    for (let index = 0; index < TERMS_PER_YEAR; index += 1) {
      const ourTerm = ours[index];
      const providerTerm = provider[index];

      if (ourTerm.koreanName !== providerTerm.name) {
        mismatches.push(`${year}#${index}: name ours=${ourTerm.koreanName} provider=${providerTerm.name}`);
        continue;
      }

      const driftMs = Math.abs(kstTermToUtcTimestamp(ourTerm) - providerTerm.date.getTime());
      comparedTerms += 1;

      if (driftMs > maxDriftMs) {
        maxDriftMs = driftMs;
        maxDriftCase = {
          year,
          index,
          name: ourTerm.koreanName,
          ours: formatKst(ourTerm),
          providerUtc: providerTerm.date.toISOString(),
          driftSeconds: Math.round(driftMs / 1000),
        };
      }

      if (
        (year === START_YEAR && index === 0) ||
        (year === 2024 && SAMPLE_TERM_INDEXES_2024.has(index)) ||
        (year === END_YEAR && index === TERMS_PER_YEAR - 1)
      ) {
        samples.push({
          year,
          name: ourTerm.koreanName,
          ours: formatKst(ourTerm),
          providerUtc: providerTerm.date.toISOString(),
          driftSeconds: Math.round(driftMs / 1000),
        });
      }

      if (driftMs > MAX_ALLOWED_DRIFT_MS) {
        mismatches.push(`${year} ${ourTerm.koreanName}: drift=${Math.round(driftMs / 1000)}s`);
      }
    }
  }

  return {
    mismatches,
    comparedTerms,
    maxDriftMs,
    maxDriftCase,
    samples,
  };
}

function renderMarkdown(summary) {
  const statusRows = [
    ['Raw generated years', summary.rawMismatches.length === 0 ? 'PASS' : 'FAIL', `${RAW_START_YEAR}-${END_YEAR}, ${TERMS_PER_YEAR} terms/year`],
    ['Runtime public range', summary.providerMismatches.length === 0 ? 'PASS' : 'FAIL', `${START_YEAR}-${END_YEAR}, ${summary.provider.comparedTerms} provider term comparisons`],
    ['Allowed provider drift', summary.provider.maxDriftMs <= MAX_ALLOWED_DRIFT_MS ? 'PASS' : 'FAIL', `max ${Math.round(summary.provider.maxDriftMs / 1000)}s / allowed ${Math.round(MAX_ALLOWED_DRIFT_MS / 1000)}s`],
  ];

  const sampleRows = summary.provider.samples.map((sample) => [
    sample.year,
    sample.name,
    sample.ours,
    sample.providerUtc,
    `${sample.driftSeconds}s`,
  ]);

  const maxDrift = summary.provider.maxDriftCase;

  return `# Solar Term Verification Report

Generated from \`src/engine/core/data/solar-terms.generated.json\` and the public \`manseryeok\` npm provider.

## Scope

- Raw generated data range: ${RAW_START_YEAR}-${END_YEAR}
- Public calculation range: ${START_YEAR}-${END_YEAR}
- Terms per year: ${TERMS_PER_YEAR}
- Provider comparisons: ${summary.provider.comparedTerms}
- Source-to-runtime normalization: +${SOURCE_TO_KST_OFFSET_HOURS} hour to Korean Standard Time
- Allowed drift: ${Math.round(MAX_ALLOWED_DRIFT_MS / 1000)} seconds
- Boundary sample policy: first public term, 2024 ipchun/gyeongchip by 24-term index, and final public term
- Data lineage: vendored precomputed generated JSON; original generator/upstream ephemeris export is not present in this repository

## Result

| Check | Status | Detail |
| --- | --- | --- |
${statusRows.map((row) => `| ${row.map(escapeCell).join(' | ')} |`).join('\n')}

## Max Drift

${maxDrift
    ? `- ${maxDrift.year} ${maxDrift.name}: ${maxDrift.driftSeconds}s (${maxDrift.ours} vs ${maxDrift.providerUtc})`
    : '- None.'}

## Boundary Samples

| Year | Term | Runtime KST | Provider UTC | Drift |
| --- | --- | --- | --- | ---: |
${sampleRows.map((row) => `| ${row.map(escapeCell).join(' | ')} |`).join('\n')}

## Mismatches

${summary.rawMismatches.length === 0 && summary.providerMismatches.length === 0
    ? '- None.'
    : [...summary.rawMismatches, ...summary.providerMismatches].slice(0, 20).map((item) => `- ${item}`).join('\n')}
`;
}

const rawMismatches = verifyRawData();
const provider = verifyProvider();
const markdown = renderMarkdown({
  rawMismatches,
  providerMismatches: provider.mismatches,
  provider,
});

if (outputPath) {
  mkdirSync(path.dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, markdown, 'utf8');
  console.log(`Wrote ${outputPath}`);
}

process.stdout.write(`# Solar term verification\n`);
process.stdout.write(`Raw mismatches: ${rawMismatches.length}\n`);
process.stdout.write(`Provider mismatches: ${provider.mismatches.length}\n`);
process.stdout.write(`Provider comparisons: ${provider.comparedTerms}\n`);
process.stdout.write(`Max drift seconds: ${Math.round(provider.maxDriftMs / 1000)}\n`);

if (rawMismatches.length > 0 || provider.mismatches.length > 0) {
  process.exitCode = 1;
}
