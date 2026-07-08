import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import fixtureData from '../fixtures/expert-reference-golden.json';
import candidateData from '../fixtures/expert-review-candidates.json';
import { calculatePalja, type CalculateOptions } from '@/engine/saju/calculator';
import type { BirthInputData, Gender, Palja } from '@/engine/types';

interface ExpertReferenceCase {
  id: string;
  description?: string;
  source: {
    type: 'expert';
    reviewer: string;
    organization?: string;
    referenceTool?: string;
    verifiedAt: string;
    reviewedCandidateId?: string;
    responseStatus?: 'accepted' | 'corrected';
    candidateFixtureSha256?: string;
    evidence?: {
      referenceCaptureFiles?: string;
      referenceCaptureSha256?: string;
      referenceUrls?: string;
    };
    reviewerEvidence?: {
      reviewerCredentials?: string;
      contactRecords?: string;
      auditNotes?: string;
    };
  };
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
  calculateOptions?: CalculateOptions;
  expected: {
    yearPillar: string;
    monthPillar: string;
    dayPillar: string;
    hourPillar?: string;
  };
}

interface ExpertReviewCandidate {
  id: string;
  reviewFocus: string[];
  input: ExpertReferenceCase['input'];
  calculateOptions: CalculateOptions;
  derived: {
    yearPillar: string;
    monthPillar: string;
    dayPillar: string;
    hourPillar: string;
  };
}

function toBirthInput(testCase: ExpertReferenceCase): BirthInputData {
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

function toPillarStrings(palja: Palja) {
  return {
    yearPillar: `${palja.yearGan}${palja.yearJi}`,
    monthPillar: `${palja.monthGan}${palja.monthJi}`,
    dayPillar: `${palja.dayGan}${palja.dayJi}`,
    hourPillar: palja.hourGan && palja.hourJi ? `${palja.hourGan}${palja.hourJi}` : '',
  };
}

const cases = fixtureData.cases as ExpertReferenceCase[];
const acceptedCases = cases.filter((testCase) => testCase.source?.type === 'expert');
const reviewCandidates = candidateData.cases as ExpertReviewCandidate[];
const candidateById = new Map(reviewCandidates.map((candidate) => [candidate.id, candidate]));
const candidateFixtureSha256 = createHash('sha256')
  .update(readFileSync('tests/fixtures/expert-review-candidates.json'))
  .digest('hex');

const PILLAR_PATTERN = /^[甲乙丙丁戊己庚辛壬癸][子丑寅卯辰巳午未申酉戌亥]$/;
const ISO_DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
const SHA256_PATTERN = /^[a-f0-9]{64}$/;
const REVIEWER_PLACEHOLDERS = new Set(['reviewer-a', 'reviewer-b', 'reviewer']);
const REFERENCE_TOOL_PLACEHOLDERS = new Set(['reference-tool-a', 'reference-tool-b', 'reference-tool']);
const DATE_PLACEHOLDERS = new Set(['yyyy-mm-dd']);

function coverageFocusAreas(testCases: ExpertReferenceCase[]) {
  const areas = new Set<string>();

  for (const testCase of testCases) {
    const reviewedCandidate = candidateById.get(testCase.source.reviewedCandidateId as string);
    const focus = new Set(reviewedCandidate?.reviewFocus ?? []);

    if (focus.has('ipchun-boundary')) areas.add('ipchun-boundary');
    if (focus.has('month-solar-term-boundary')) areas.add('month-solar-term-boundary');
    if (focus.has('lunar-calendar')) areas.add('lunar-calendar');
    if (focus.has('leap-month')) areas.add('leap-month');
    if (focus.has('regional-birth-place')) areas.add('regional-birth-place');
    if (testCase.calculateOptions?.trueSolarTime || focus.has('true-solar-time')) {
      areas.add('true-solar-time');
    }
    if (focus.has('midnight-boundary') && testCase.calculateOptions?.midnightMode === 'yaja') {
      areas.add('midnight-yaja');
    }
    if (focus.has('midnight-boundary') && testCase.calculateOptions?.midnightMode === 'joja') {
      areas.add('midnight-joja');
    }
  }

  return areas;
}

function splitDeclaredValues(value: unknown) {
  return String(value ?? '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);
}

function consensusEvidence(testCases: ExpertReferenceCase[]) {
  const reviewers = new Set<string>();
  const referenceTools = new Set<string>();

  for (const testCase of testCases) {
    for (const reviewer of splitDeclaredValues(testCase.source.reviewer)) {
      reviewers.add(reviewer);
    }
    for (const referenceTool of splitDeclaredValues(testCase.source.referenceTool)) {
      referenceTools.add(referenceTool);
    }
  }

  return { reviewers, referenceTools };
}

function expectNonEmptyString(value: unknown, fieldName: string) {
  expect(typeof value, `${fieldName} must be a string`).toBe('string');
  expect((value as string).trim().length, `${fieldName} must not be empty`).toBeGreaterThan(0);
}

function expectValidPillar(value: unknown, fieldName: string) {
  expectNonEmptyString(value, fieldName);
  expect(value, `${fieldName} must be a ganji pillar such as 甲子`).toMatch(PILLAR_PATTERN);
}

function expectValidDate(value: unknown, fieldName: string) {
  expectNonEmptyString(value, fieldName);
  expect(value, `${fieldName} must be YYYY-MM-DD`).toMatch(ISO_DATE_PATTERN);
  expect(Number.isNaN(Date.parse(`${value as string}T00:00:00+09:00`))).toBe(false);
}

function expectNoPlaceholder(value: unknown, placeholders: Set<string>, fieldName: string) {
  const normalized = String(value ?? '').trim().toLowerCase();
  expect(placeholders.has(normalized), `${fieldName} must not use package placeholder metadata`).toBe(false);
}

function expectValidOptionalEvidence(
  evidence: ExpertReferenceCase['source']['evidence'],
  fieldName: string,
) {
  if (!evidence) return;

  if (evidence.referenceCaptureFiles !== undefined) {
    expect(typeof evidence.referenceCaptureFiles, `${fieldName}.referenceCaptureFiles must be a string`).toBe('string');
  }

  if (evidence.referenceUrls !== undefined) {
    expect(typeof evidence.referenceUrls, `${fieldName}.referenceUrls must be a string`).toBe('string');
  }

  if (evidence.referenceCaptureSha256 !== undefined && evidence.referenceCaptureSha256.trim().length > 0) {
    for (const hash of evidence.referenceCaptureSha256.split(',').map((item) => item.trim()).filter(Boolean)) {
      expect(hash, `${fieldName}.referenceCaptureSha256 must contain SHA-256 hex digests`).toMatch(SHA256_PATTERN);
    }
  }
}

function expectRequiredCaptureEvidence(
  evidence: ExpertReferenceCase['source']['evidence'],
  fieldName: string,
) {
  expect(evidence, `${fieldName} is required for accepted expert cases`).toBeDefined();
  const captureFiles = evidence?.referenceCaptureFiles;
  const captureSha256 = evidence?.referenceCaptureSha256;
  expectNonEmptyString(captureFiles, `${fieldName}.referenceCaptureFiles`);
  expectNonEmptyString(captureSha256, `${fieldName}.referenceCaptureSha256`);

  for (const hash of String(captureSha256).split(',').map((item) => item.trim()).filter(Boolean)) {
    expect(hash, `${fieldName}.referenceCaptureSha256 must contain SHA-256 hex digests`).toMatch(SHA256_PATTERN);
  }
}

function expectRequiredReviewerEvidence(
  evidence: ExpertReferenceCase['source']['reviewerEvidence'],
  fieldName: string,
) {
  expect(evidence, `${fieldName} is required for accepted expert cases`).toBeDefined();
  expectNonEmptyString(evidence?.reviewerCredentials, `${fieldName}.reviewerCredentials`);
  if (evidence?.contactRecords !== undefined) {
    expect(typeof evidence.contactRecords, `${fieldName}.contactRecords must be a string`).toBe('string');
  }
  if (evidence?.auditNotes !== undefined) {
    expect(typeof evidence.auditNotes, `${fieldName}.auditNotes must be a string`).toBe('string');
  }
}

describe('전문가 검수 레퍼런스 만세력 fixture schema', () => {
  it('fixture policy가 판매 검수 기준을 명시한다', () => {
    expect(fixtureData.requiredAcceptedCases.min).toBe(5);
    expect(fixtureData.requiredAcceptedCases.max).toBe(10);
    expect(fixtureData.requiredCoverage.minDistinctFocusAreas).toBe(5);
    expect(fixtureData.requiredConsensus.minDistinctReviewers).toBe(2);
    expect(fixtureData.requiredConsensus.minDistinctReferenceTools).toBe(2);
    expect(fixtureData.requiredCoverage.focusAreas).toEqual(expect.arrayContaining([
      'ipchun-boundary',
      'month-solar-term-boundary',
      'midnight-yaja',
      'midnight-joja',
      'lunar-calendar',
      'leap-month',
      'true-solar-time',
    ]));
    expect(fixtureData.policy.timezone).toBe('Asia/Seoul');
    expect(fixtureData.policy.dayBoundary).toBe('configurable');
    expect(fixtureData.policy.trueSolarTime).toBe('configurable');
  });

  it.each(cases)('$id - 출처/입력/예상 기둥 메타데이터가 완전하다', (testCase) => {
    expectNonEmptyString(testCase.id, 'id');
    expect(testCase.source?.type).toBe('expert');
    expectNonEmptyString(testCase.source.reviewer, 'source.reviewer');
    expectNonEmptyString(testCase.source.referenceTool, 'source.referenceTool');
    expectValidDate(testCase.source.verifiedAt, 'source.verifiedAt');
    expectNoPlaceholder(testCase.source.reviewer, REVIEWER_PLACEHOLDERS, 'source.reviewer');
    expectNoPlaceholder(testCase.source.referenceTool, REFERENCE_TOOL_PLACEHOLDERS, 'source.referenceTool');
    expectNoPlaceholder(testCase.source.verifiedAt, DATE_PLACEHOLDERS, 'source.verifiedAt');
    expectNonEmptyString(testCase.source.reviewedCandidateId, 'source.reviewedCandidateId');
    expect(['accepted', 'corrected']).toContain(testCase.source.responseStatus);
    expectNonEmptyString(testCase.source.candidateFixtureSha256, 'source.candidateFixtureSha256');
    expect(testCase.source.candidateFixtureSha256).toMatch(SHA256_PATTERN);
    expect(testCase.source.candidateFixtureSha256).toBe(candidateFixtureSha256);
    expectValidOptionalEvidence(testCase.source.evidence, 'source.evidence');

    const reviewedCandidate = candidateById.get(testCase.source.reviewedCandidateId as string);
    expect(reviewedCandidate, `${testCase.id} source.reviewedCandidateId must exist in expert-review-candidates.json`).toBeDefined();
    expect(testCase.input).toEqual(reviewedCandidate?.input);
    expect(testCase.calculateOptions).toEqual(reviewedCandidate?.calculateOptions);

    if (testCase.source.responseStatus === 'accepted') {
      expect(testCase.expected).toEqual({
        yearPillar: reviewedCandidate?.derived.yearPillar,
        monthPillar: reviewedCandidate?.derived.monthPillar,
        dayPillar: reviewedCandidate?.derived.dayPillar,
        hourPillar: reviewedCandidate?.derived.hourPillar,
      });
    }

    expect(['solar', 'lunar']).toContain(testCase.input.calendar);
    expect(testCase.input.year).toBeGreaterThanOrEqual(1900);
    expect(testCase.input.year).toBeLessThanOrEqual(2101);
    expect(testCase.input.month).toBeGreaterThanOrEqual(1);
    expect(testCase.input.month).toBeLessThanOrEqual(12);
    expect(testCase.input.day).toBeGreaterThanOrEqual(1);
    expect(testCase.input.day).toBeLessThanOrEqual(31);
    expect(['male', 'female']).toContain(testCase.input.gender);

    if (testCase.input.hour !== null) {
      expect(testCase.input.hour).toBeGreaterThanOrEqual(0);
      expect(testCase.input.hour).toBeLessThanOrEqual(23);
    }

    if (testCase.input.minute !== null) {
      expect(testCase.input.minute).toBeGreaterThanOrEqual(0);
      expect(testCase.input.minute).toBeLessThanOrEqual(59);
    }

    expect(['yaja', 'joja']).toContain(testCase.calculateOptions?.midnightMode);
    expect(typeof testCase.calculateOptions?.trueSolarTime).toBe('boolean');

    if (testCase.calculateOptions?.trueSolarTime) {
      expect(testCase.calculateOptions.longitude).toBeGreaterThanOrEqual(-180);
      expect(testCase.calculateOptions.longitude).toBeLessThanOrEqual(180);
    }

    expectValidPillar(testCase.expected.yearPillar, 'expected.yearPillar');
    expectValidPillar(testCase.expected.monthPillar, 'expected.monthPillar');
    expectValidPillar(testCase.expected.dayPillar, 'expected.dayPillar');

    if (testCase.expected.hourPillar !== undefined) {
      expectValidPillar(testCase.expected.hourPillar, 'expected.hourPillar');
    }
  });
});

const describeWhenReady = acceptedCases.length > 0 ? describe : describe.skip;

describeWhenReady('전문가 검수 레퍼런스 만세력 fixture acceptance', () => {
  it('전문가 검수 케이스 수가 판매 검수 기준을 만족한다', () => {
    expect(acceptedCases.length).toBeGreaterThanOrEqual(fixtureData.requiredAcceptedCases.min);
    expect(acceptedCases.length).toBeLessThanOrEqual(fixtureData.requiredAcceptedCases.max);
  });

  it('판매 검증에 필요한 핵심 경계 영역을 충분히 포함한다', () => {
    const areas = coverageFocusAreas(acceptedCases);
    const allowedAreas = new Set(fixtureData.requiredCoverage.focusAreas);

    for (const area of areas) {
      expect(allowedAreas.has(area), `${area} must be declared in requiredCoverage.focusAreas`).toBe(true);
    }

    expect(areas.size).toBeGreaterThanOrEqual(fixtureData.requiredCoverage.minDistinctFocusAreas);
  });

  it('전문가 검수 출처가 독립 리뷰어와 독립 도구 기준을 만족한다', () => {
    const consensus = consensusEvidence(acceptedCases);

    expect(consensus.reviewers.size).toBeGreaterThanOrEqual(fixtureData.requiredConsensus.minDistinctReviewers);
    expect(consensus.referenceTools.size).toBeGreaterThanOrEqual(fixtureData.requiredConsensus.minDistinctReferenceTools);
  });

  it.each(acceptedCases)('$id - accepted expert evidence includes a hashed capture file', (testCase) => {
    expectRequiredCaptureEvidence(testCase.source.evidence, 'source.evidence');
  });

  it.each(acceptedCases)('$id - accepted expert evidence includes reviewer credentials', (testCase) => {
    expectRequiredReviewerEvidence(testCase.source.reviewerEvidence, 'source.reviewerEvidence');
  });

  it.each(acceptedCases)('$id', (testCase) => {
    const palja = calculatePalja(toBirthInput(testCase), testCase.calculateOptions);
    const actual = toPillarStrings(palja);

    expect(actual.yearPillar).toBe(testCase.expected.yearPillar);
    expect(actual.monthPillar).toBe(testCase.expected.monthPillar);
    expect(actual.dayPillar).toBe(testCase.expected.dayPillar);

    if (testCase.expected.hourPillar !== undefined) {
      expect(actual.hourPillar).toBe(testCase.expected.hourPillar);
    }
  });
});
