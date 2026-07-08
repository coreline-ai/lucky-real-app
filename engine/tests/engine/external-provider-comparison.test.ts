import { describe, expect, it } from 'vitest';
import {
  calculateFourPillars,
  lunarToSolar as providerLunarToSolar,
} from 'manseryeok';
import {
  calculateSajuSimple,
  lunarToSolar as fullstackLunarToSolar,
} from '@fullstackfamily/manseryeok';
import { calculateSaju as calculateSsaju } from 'ssaju';
import fixtureData from '../fixtures/manseryeok-golden.json';
import referenceProviders from '../fixtures/reference-providers.json';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import { calculatePalja } from '@/engine/saju/calculator';
import type { BirthInputData, Gender, Palja } from '@/engine/types';

interface GoldenCase {
  id: string;
  input: {
    calendar: 'solar' | 'lunar';
    year: number;
    month: number;
    day: number;
    isLeapMonth?: boolean;
    hour: number | null;
    minute: number | null;
    gender: Gender;
  };
  expected: Partial<{
    solar: string;
    yearPillar: string;
    monthPillar: string;
    dayPillar: string;
    hourPillar: string;
  }>;
  externalProviders?: string[];
}

interface PillarSnapshot {
  solar?: string;
  yearPillar?: string;
  monthPillar?: string;
  dayPillar?: string;
  hourPillar?: string;
}

function formatDate(year: number, month: number, day: number): string {
  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

function toBirthInput(testCase: GoldenCase): BirthInputData {
  return {
    year: testCase.input.year,
    month: testCase.input.month,
    day: testCase.input.day,
    hour: testCase.input.hour,
    minute: testCase.input.minute,
    gender: testCase.input.gender,
    isLunar: testCase.input.calendar === 'lunar',
    isLeapMonth: testCase.input.calendar === 'lunar' ? testCase.input.isLeapMonth ?? false : false,
    birthPlace: null,
  };
}

function toPillarStrings(palja: Palja): PillarSnapshot {
  return {
    yearPillar: `${palja.yearGan}${palja.yearJi}`,
    monthPillar: `${palja.monthGan}${palja.monthJi}`,
    dayPillar: `${palja.dayGan}${palja.dayJi}`,
    hourPillar: palja.hourGan && palja.hourJi ? `${palja.hourGan}${palja.hourJi}` : '',
  };
}

function ourSnapshot(testCase: GoldenCase): PillarSnapshot {
  const snapshot = toPillarStrings(calculatePalja(toBirthInput(testCase)));
  if (testCase.input.calendar === 'lunar') {
    const solar = ManseryeokEngine.lunarToSolar({
      year: testCase.input.year,
      month: testCase.input.month,
      day: testCase.input.day,
      isLeapMonth: testCase.input.isLeapMonth ?? false,
    });
    snapshot.solar = formatDate(solar.year, solar.month, solar.day);
  }
  return snapshot;
}

function manseryeokSnapshot(testCase: GoldenCase): PillarSnapshot {
  const result = calculateFourPillars({
    year: testCase.input.year,
    month: testCase.input.month,
    day: testCase.input.day,
    hour: testCase.input.hour ?? 0,
    minute: testCase.input.minute ?? 0,
    isLunar: testCase.input.calendar === 'lunar',
    isLeapMonth: testCase.input.calendar === 'lunar' ? testCase.input.isLeapMonth ?? false : undefined,
    gender: testCase.input.gender,
    dayBoundary: 'splitJasi',
  });
  const hanja = result.toHanjaObject();
  const snapshot: PillarSnapshot = {
    yearPillar: hanja.year.hanja,
    monthPillar: hanja.month.hanja,
    dayPillar: hanja.day.hanja,
    hourPillar: hanja.hour.hanja,
  };

  if (testCase.input.calendar === 'lunar') {
    const solar = providerLunarToSolar(
      testCase.input.year,
      testCase.input.month,
      testCase.input.day,
      testCase.input.isLeapMonth ?? false,
    );
    snapshot.solar = formatDate(solar.year, solar.month, solar.day);
  }

  return snapshot;
}

function fullstackSnapshot(testCase: GoldenCase): PillarSnapshot {
  let year = testCase.input.year;
  let month = testCase.input.month;
  let day = testCase.input.day;
  const snapshot: PillarSnapshot = {};

  if (testCase.input.calendar === 'lunar') {
    const converted = fullstackLunarToSolar(
      testCase.input.year,
      testCase.input.month,
      testCase.input.day,
      testCase.input.isLeapMonth ?? false,
    );
    year = converted.solar.year;
    month = converted.solar.month;
    day = converted.solar.day;
    snapshot.solar = formatDate(year, month, day);
  }

  const result = calculateSajuSimple(year, month, day, testCase.input.hour ?? 0);
  return {
    ...snapshot,
    yearPillar: result.yearPillarHanja,
    monthPillar: result.monthPillarHanja,
    dayPillar: result.dayPillarHanja,
    hourPillar: result.hourPillarHanja ?? '',
  };
}

function ssajuSnapshot(testCase: GoldenCase): PillarSnapshot {
  const result = calculateSsaju({
    year: testCase.input.year,
    month: testCase.input.month,
    day: testCase.input.day,
    hour: testCase.input.hour ?? 0,
    minute: testCase.input.minute ?? 0,
    gender: testCase.input.gender === 'male' ? '남' : '여',
    calendar: testCase.input.calendar,
    leap: testCase.input.calendar === 'lunar' ? testCase.input.isLeapMonth ?? false : false,
    timezone: 'Asia/Seoul',
    applyLocalMeanTime: false,
  });

  const snapshot: PillarSnapshot = {
    yearPillar: result.pillars.year,
    monthPillar: result.pillars.month,
    dayPillar: result.pillars.day,
    hourPillar: result.pillars.hour,
  };

  if (testCase.input.calendar === 'lunar') {
    snapshot.solar = formatDate(result.solar.year, result.solar.month, result.solar.day);
  }

  return snapshot;
}

function assertProviderMatches(
  testCase: GoldenCase,
  providerName: string,
  providerSnapshot: PillarSnapshot,
) {
  const ours = ourSnapshot(testCase);
  for (const key of ['solar', 'yearPillar', 'monthPillar', 'dayPillar', 'hourPillar'] as const) {
    if (testCase.expected[key]) {
      expect(providerSnapshot[key], `${testCase.id} ${providerName} ${key}`).toBe(ours[key]);
    }
  }
}

const comparableCases = (fixtureData.cases as GoldenCase[]).filter(
  (testCase) => testCase.externalProviders?.length,
);
const activeAutomatedProviderIds = new Set(
  referenceProviders.automatedProviders
    .filter((provider) => provider.ciStatus === 'active')
    .map((provider) => provider.id),
);
const manualBenchmarkIds = new Set(referenceProviders.manualBenchmarks.map((provider) => provider.id));
const candidateProviderIds = new Set((referenceProviders.candidateProviders ?? []).map((provider) => provider.id));

describe('외부 공개 만세력 provider 교차검증', () => {
  it('registers every automated fixture provider separately from manual commercial benchmarks', () => {
    expect(referenceProviders.schemaVersion).toBe(1);
    expect(activeAutomatedProviderIds.size).toBeGreaterThanOrEqual(3);

    for (const provider of referenceProviders.automatedProviders) {
      expect(provider.id).toEqual(expect.any(String));
      expect(provider.id.trim().length).toBeGreaterThan(0);
      expect(provider.kind).toMatch(/^(npm|github|http-api)$/);
      expect(provider.sourceUrl || provider.registryUrl).toBeTruthy();
    }

    for (const benchmark of referenceProviders.manualBenchmarks) {
      expect(benchmark.status).toBe('manual-capture-only');
      expect(benchmark.publicApiStatus).toMatch(/^(not-verified|unavailable|candidate)$/);
      expect(benchmark.openSourceStatus).toMatch(/^(not-verified|unavailable|candidate)$/);
      expect(benchmark.automationEligibility).toBe('blocked-until-official-api-or-oss');
      expect(benchmark.captureMode).toMatch(/^manual-/);
      expect(benchmark.evidenceRequired).toEqual(
        expect.arrayContaining(['providerCaptureFile', 'providerCaptureSha256']),
      );
      expect(benchmark.checkedAt).toMatch(/^\d{4}-\d{2}-\d{2}$/);
      expect(benchmark.urls.length).toBeGreaterThan(0);
      expect(activeAutomatedProviderIds.has(benchmark.id)).toBe(false);
    }

    for (const provider of referenceProviders.candidateProviders ?? []) {
      expect(provider.status).toBe('candidate');
      expect(provider.kind).toMatch(/^(http-api|github|npm)$/);
      expect(provider.automationEligibility).toMatch(/^blocked-/);
      expect(provider.checkedAt).toMatch(/^\d{4}-\d{2}-\d{2}$/);
      expect(provider.urls.length).toBeGreaterThan(0);
      expect(activeAutomatedProviderIds.has(provider.id)).toBe(false);
      expect(manualBenchmarkIds.has(provider.id)).toBe(false);
    }

    for (const testCase of comparableCases) {
      for (const providerId of testCase.externalProviders ?? []) {
        expect(activeAutomatedProviderIds.has(providerId), `${testCase.id} ${providerId} must be registered as an active automated provider`).toBe(true);
        expect(manualBenchmarkIds.has(providerId), `${testCase.id} ${providerId} must not be a manual-only benchmark`).toBe(false);
        expect(candidateProviderIds.has(providerId), `${testCase.id} ${providerId} must not be a candidate provider without adapter coverage`).toBe(false);
      }
    }
  });

  it.each(comparableCases)('$id - manseryeok', (testCase) => {
    if (!testCase.externalProviders?.includes('manseryeok')) return;
    assertProviderMatches(testCase, 'manseryeok', manseryeokSnapshot(testCase));
  });

  it.each(comparableCases)('$id - fullstackfamily', (testCase) => {
    if (!testCase.externalProviders?.includes('fullstackfamily')) return;
    assertProviderMatches(testCase, 'fullstackfamily', fullstackSnapshot(testCase));
  });

  it.each(comparableCases)('$id - ssaju', (testCase) => {
    if (!testCase.externalProviders?.includes('ssaju')) return;
    assertProviderMatches(testCase, 'ssaju', ssajuSnapshot(testCase));
  });
});
