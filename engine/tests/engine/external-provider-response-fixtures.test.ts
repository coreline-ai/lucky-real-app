import { createHash } from 'node:crypto';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import { calculatePalja, type CalculateOptions } from '@/engine/saju/calculator';
import type { BirthInputData, Gender, MidnightMode, Palja } from '@/engine/types';

interface ExternalProviderResponseFile {
  schemaVersion: 1;
  provider: {
    name: string;
    type: 'http-api' | 'manual-export' | 'app-transcription';
    url?: string;
    capturedAt: string;
    notes?: string;
  };
  candidateSet?: {
    fixtureSha256: string;
    candidateIds: string[];
  };
  cases: ExternalProviderCase[];
}

interface ExternalProviderCase {
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
    birthPlace?: string | null;
  };
  calculateOptions: {
    midnightMode: MidnightMode;
    trueSolarTime: boolean;
    longitude: number;
  };
  providerExpected: Partial<{
    solar: string;
    yearPillar: string;
    monthPillar: string;
    dayPillar: string;
    hourPillar: string;
  }>;
  evidence?: {
    providerCaptureFile?: string;
    providerCaptureSha256?: string;
    providerCaseUrl?: string;
  };
}

interface PillarSnapshot {
  solar?: string;
  yearPillar: string;
  monthPillar: string;
  dayPillar: string;
  hourPillar: string;
}

const rootDir = process.cwd();
const responseDir = path.join(rootDir, 'tests', 'fixtures', 'external-provider-responses');
const candidatePath = path.join(rootDir, 'tests', 'fixtures', 'expert-review-candidates.json');
const ISO_DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
const SHA256_PATTERN = /^[a-f0-9]{64}$/;
const PILLAR_PATTERN = /^[甲乙丙丁戊己庚辛壬癸][子丑寅卯辰巳午未申酉戌亥]$/;
const PROVIDER_NAME_PLACEHOLDERS = new Set(['provider-a', 'provider-b', 'provider']);
const DATE_PLACEHOLDERS = new Set(['yyyy-mm-dd']);

function sha256(filePath: string) {
  return createHash('sha256').update(readFileSync(filePath)).digest('hex');
}

function formatDate(year: number, month: number, day: number): string {
  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

function toBirthInput(testCase: ExternalProviderCase): BirthInputData {
  return {
    year: testCase.input.year,
    month: testCase.input.month,
    day: testCase.input.day,
    hour: testCase.input.hour,
    minute: testCase.input.minute,
    gender: testCase.input.gender,
    isLunar: testCase.input.calendar === 'lunar',
    isLeapMonth: testCase.input.calendar === 'lunar' ? testCase.input.isLeapMonth ?? false : false,
    birthPlace: testCase.input.birthPlace ?? null,
  };
}

function toPillarStrings(palja: Palja): Omit<PillarSnapshot, 'solar'> {
  return {
    yearPillar: `${palja.yearGan}${palja.yearJi}`,
    monthPillar: `${palja.monthGan}${palja.monthJi}`,
    dayPillar: `${palja.dayGan}${palja.dayJi}`,
    hourPillar: palja.hourGan && palja.hourJi ? `${palja.hourGan}${palja.hourJi}` : '',
  };
}

function calculateOurs(testCase: ExternalProviderCase): PillarSnapshot {
  const input = toBirthInput(testCase);
  const calculateOptions: CalculateOptions = testCase.calculateOptions;
  const snapshot: PillarSnapshot = toPillarStrings(calculatePalja(input, calculateOptions));

  if (testCase.input.calendar === 'lunar') {
    const solar = ManseryeokEngine.lunarToSolar({
      year: testCase.input.year,
      month: testCase.input.month,
      day: testCase.input.day,
      isLeapMonth: testCase.input.isLeapMonth ?? false,
    });
    snapshot.solar = formatDate(solar.year, solar.month, solar.day);
  } else {
    snapshot.solar = formatDate(testCase.input.year, testCase.input.month, testCase.input.day);
  }

  return snapshot;
}

function assertProviderFileShape(fileName: string, data: ExternalProviderResponseFile) {
  expect(data.schemaVersion, `${fileName} schemaVersion`).toBe(1);
  expect(data.provider?.name, `${fileName} provider.name`).toEqual(expect.any(String));
  expect(data.provider.name.trim().length, `${fileName} provider.name`).toBeGreaterThan(0);
  expect(
    PROVIDER_NAME_PLACEHOLDERS.has(data.provider.name.trim().toLowerCase()),
    `${fileName} provider.name must not use template placeholder metadata`,
  ).toBe(false);
  expect(['http-api', 'manual-export', 'app-transcription']).toContain(data.provider?.type);
  expect(data.provider?.capturedAt, `${fileName} provider.capturedAt`).toMatch(ISO_DATE_PATTERN);
  expect(
    DATE_PLACEHOLDERS.has(data.provider.capturedAt.trim().toLowerCase()),
    `${fileName} provider.capturedAt must not use template placeholder metadata`,
  ).toBe(false);
  expect(Array.isArray(data.cases), `${fileName} cases`).toBe(true);
  expect(data.cases.length, `${fileName} cases`).toBeGreaterThan(0);

  if (data.candidateSet) {
    expect(data.candidateSet.fixtureSha256, `${fileName} candidateSet.fixtureSha256`).toBe(sha256(candidatePath));
    expect(Array.isArray(data.candidateSet.candidateIds), `${fileName} candidateSet.candidateIds`).toBe(true);
  }
}

function assertCaseShape(fileName: string, testCase: ExternalProviderCase) {
  expect(testCase.id, `${fileName} case.id`).toEqual(expect.any(String));
  expect(['solar', 'lunar']).toContain(testCase.input?.calendar);
  expect(testCase.input?.year, `${testCase.id} year`).toBeGreaterThanOrEqual(1900);
  expect(testCase.input?.year, `${testCase.id} year`).toBeLessThanOrEqual(2101);
  expect(testCase.input?.month, `${testCase.id} month`).toBeGreaterThanOrEqual(1);
  expect(testCase.input?.month, `${testCase.id} month`).toBeLessThanOrEqual(12);
  expect(testCase.input?.day, `${testCase.id} day`).toBeGreaterThanOrEqual(1);
  expect(testCase.input?.day, `${testCase.id} day`).toBeLessThanOrEqual(31);
  expect(['male', 'female']).toContain(testCase.input?.gender);
  expect(['yaja', 'joja']).toContain(testCase.calculateOptions?.midnightMode);
  expect(typeof testCase.calculateOptions?.trueSolarTime).toBe('boolean');
  expect(testCase.calculateOptions?.longitude, `${testCase.id} longitude`).toBeGreaterThanOrEqual(-180);
  expect(testCase.calculateOptions?.longitude, `${testCase.id} longitude`).toBeLessThanOrEqual(180);

  const expectedFields = Object.entries(testCase.providerExpected ?? {});
  expect(expectedFields.length, `${testCase.id} providerExpected`).toBeGreaterThan(0);
  for (const [field, value] of expectedFields) {
    if (field === 'solar') {
      expect(value, `${testCase.id} solar`).toMatch(ISO_DATE_PATTERN);
    } else {
      expect(value, `${testCase.id} ${field}`).toMatch(PILLAR_PATTERN);
    }
  }

  if (testCase.evidence) {
    if (testCase.evidence.providerCaptureFile !== undefined) {
      expect(typeof testCase.evidence.providerCaptureFile, `${testCase.id} providerCaptureFile`).toBe('string');
    }
    if (testCase.evidence.providerCaptureSha256 !== undefined && testCase.evidence.providerCaptureSha256.trim().length > 0) {
      expect(testCase.evidence.providerCaptureSha256, `${testCase.id} providerCaptureSha256`).toMatch(SHA256_PATTERN);
    }
    if (testCase.evidence.providerCaseUrl !== undefined) {
      expect(typeof testCase.evidence.providerCaseUrl, `${testCase.id} providerCaseUrl`).toBe('string');
    }
  }
}

const responseFiles = existsSync(responseDir)
  ? readdirSync(responseDir).filter((fileName) => fileName.endsWith('.json')).sort()
  : [];

describe('외부 API/앱 응답 fixture 교차검증', () => {
  it('응답 fixture 디렉터리는 선택 사항이다', () => {
    expect(Array.isArray(responseFiles)).toBe(true);
  });

  it.each(responseFiles)('%s', (fileName) => {
    const filePath = path.join(responseDir, fileName);
    const data = JSON.parse(readFileSync(filePath, 'utf8')) as ExternalProviderResponseFile;
    assertProviderFileShape(fileName, data);

    for (const testCase of data.cases) {
      assertCaseShape(fileName, testCase);
      const ours = calculateOurs(testCase);

      for (const [field, providerValue] of Object.entries(testCase.providerExpected)) {
        expect(
          ours[field as keyof PillarSnapshot],
          `${fileName} ${testCase.id} ${field}`,
        ).toBe(providerValue);
      }
    }
  });
});
