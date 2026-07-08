import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { describe, expect, it } from 'vitest';
import { getSolarTermsOfYear } from 'manseryeok';
import solarTermsByYear from '@/engine/core/data/solar-terms.generated.json';
import {
  isJeolSolarTerm,
  JEOL_SOLAR_TERM_NAME_SET,
  JEOL_SOLAR_TERM_NAMES,
  getSolarTermOnOrBefore,
  listSolarTermsForYear,
} from '@/engine/core/solar-terms';

const START_YEAR = 1900;
const END_YEAR = 2101;
const RAW_START_YEAR = 1899;
const MAX_ALLOWED_DRIFT_MS = 2 * 60 * 1000;
const TERMS_PER_YEAR = 24;

interface GeneratedSolarTerm {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
  julianDay: number;
}

function kstTermToUtcTimestamp(term: {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}) {
  return Date.UTC(term.year, term.month - 1, term.day, term.hour - 9, term.minute, term.second);
}

function sourceTermToTimestamp(term: GeneratedSolarTerm) {
  return Date.UTC(term.year, term.month - 1, term.day, term.hour, term.minute, term.second);
}

describe('solar term data range and provider verification', () => {
  it('generated JSON covers the raw 1899-2101 support window with sorted 24-term years', () => {
    const raw = solarTermsByYear as Record<string, GeneratedSolarTerm[]>;
    const mismatches: string[] = [];

    for (let year = RAW_START_YEAR; year <= END_YEAR; year += 1) {
      const terms = raw[String(year)] ?? [];
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

    expect(mismatches).toEqual([]);
  });

  it('runtime KST normalization keeps every public supported year complete and sorted', () => {
    const mismatches: string[] = [];

    for (let year = START_YEAR; year <= END_YEAR; year += 1) {
      const terms = listSolarTermsForYear(year);
      if (terms.length !== TERMS_PER_YEAR) {
        mismatches.push(`${year}: count=${terms.length}`);
        continue;
      }

      for (let index = 1; index < terms.length; index += 1) {
        if (terms[index].julianDay <= terms[index - 1].julianDay) {
          mismatches.push(`${year}#${index}: non-increasing normalized julianDay`);
        }
        if (kstTermToUtcTimestamp(terms[index]) <= kstTermToUtcTimestamp(terms[index - 1])) {
          mismatches.push(`${year}#${index}: non-increasing normalized timestamp`);
        }
      }
    }

    expect(mismatches).toEqual([]);
  });

  it('public range edge lookups resolve without falling off the generated data window', () => {
    expect(() => getSolarTermOnOrBefore('1900-01-01')).not.toThrow();
    expect(() => getSolarTermOnOrBefore('2101-12-31')).not.toThrow();
  });

  it('memoizes normalized terms without exposing cache objects to caller mutation', () => {
    const first = listSolarTermsForYear(2024);
    const ipchun = first.find((term) => term.koreanName === '입춘');

    expect(ipchun).toMatchObject({
      koreanName: '입춘',
      year: 2024,
      month: 2,
      day: 4,
      hour: 17,
      minute: 27,
    });

    if (!ipchun) {
      throw new Error('Missing 2024 입춘');
    }

    ipchun.koreanName = 'mutated';
    ipchun.hour = 0;
    first.push({ ...ipchun });

    const second = listSolarTermsForYear(2024);
    const secondIpchun = second.find((term) => term.koreanName === '입춘');

    expect(second).toHaveLength(TERMS_PER_YEAR);
    expect(secondIpchun).toMatchObject({
      koreanName: '입춘',
      year: 2024,
      month: 2,
      day: 4,
      hour: 17,
      minute: 27,
    });
    expect(second[2]).not.toBe(first[2]);
  });

  it('exports the shared 12-jeol major-term policy', () => {
    expect(JEOL_SOLAR_TERM_NAMES).toEqual([
      '소한',
      '입춘',
      '경칩',
      '청명',
      '입하',
      '망종',
      '소서',
      '입추',
      '백로',
      '한로',
      '입동',
      '대설',
    ]);
    expect(JEOL_SOLAR_TERM_NAME_SET.size).toBe(12);
    expect(isJeolSolarTerm('입춘')).toBe(true);
    expect(isJeolSolarTerm({ koreanName: '우수' })).toBe(false);
    const exportedSet = JEOL_SOLAR_TERM_NAME_SET as Set<string>;
    exportedSet.add('우수');
    try {
      expect(JEOL_SOLAR_TERM_NAME_SET.has('우수')).toBe(true);
      expect(isJeolSolarTerm('우수')).toBe(false);
    } finally {
      exportedSet.delete('우수');
    }
  });

  it('matches the public manseryeok provider for all 24 terms from 1900 through 2101', () => {
    const mismatches: string[] = [];

    for (let year = START_YEAR; year <= END_YEAR; year += 1) {
      const ours = listSolarTermsForYear(year);
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
        if (driftMs > MAX_ALLOWED_DRIFT_MS) {
          mismatches.push(`${year} ${ourTerm.koreanName}: drift=${Math.round(driftMs / 1000)}s`);
        }
      }
    }

    expect(mismatches).toEqual([]);
  });

  it('generates a sale-readiness solar term verification report', () => {
    const tempDir = mkdtempSync(path.join(tmpdir(), 'myunglab-solar-term-report-'));

    try {
      const reportPath = path.join(tempDir, 'solar-term-verification-report.md');
      const output = execFileSync(
        process.execPath,
        ['scripts/generate-solar-term-verification-report.mjs', reportPath],
        { cwd: process.cwd(), encoding: 'utf8' },
      );

      expect(output).toContain('Raw mismatches: 0');
      expect(output).toContain('Provider mismatches: 0');
      expect(output).toContain('Provider comparisons: 4848');

      const report = readFileSync(reportPath, 'utf8');
      expect(report).toContain('Solar Term Verification Report');
      expect(report).toContain('Raw generated data range: 1899-2101');
      expect(report).toContain('Public calculation range: 1900-2101');
      expect(report).toContain('Boundary sample policy: first public term, 2024 ipchun/gyeongchip by 24-term index, and final public term');
      expect(report).toContain('Data lineage: vendored precomputed generated JSON; original generator/upstream ephemeris export is not present in this repository');
      expect(report).toContain('| Runtime public range | PASS | 1900-2101, 4848 provider term comparisons |');
      expect(report).toContain('Mismatches');
      expect(report).toContain('- None.');
    } finally {
      rmSync(tempDir, { recursive: true, force: true });
    }
  });
});
