import { describe, expect, it } from 'vitest';
import fixtureData from '../fixtures/manseryeok-policy-cases.json';

interface PolicyFixtureSectionItem {
  id: string;
}

interface SourceReference extends PolicyFixtureSectionItem {
  url: string;
}

interface LegalTimeCase extends PolicyFixtureSectionItem {
  title: string;
  legalOffsetMinutes: number;
  dstOffsetMinutes: number;
  effectiveOffsetMinutes: number;
  sourceIds: string[];
  assertion: string;
}

interface DaeunPolicyCase extends PolicyFixtureSectionItem {
  direction: string;
  targetPolicy: Record<string, unknown>;
  assertion: string;
}

interface BaselineReproduction extends PolicyFixtureSectionItem {
  title: string;
  input: Record<string, unknown>;
  currentObserved: Record<string, unknown>;
  targetAfterFix: Record<string, unknown>;
}

interface PolicyFixtureData {
  schemaVersion: number;
  metadata: {
    sources: SourceReference[];
  };
  legalTimeCases: LegalTimeCase[];
  daeunPolicyCases: DaeunPolicyCase[];
  baselineReproductions: BaselineReproduction[];
}

const policyFixtures = fixtureData as PolicyFixtureData;

const requiredLegalTimeCaseIds = [
  'legal-1908-utc-plus-0830',
  'legal-1912-utc-plus-0900',
  'legal-1954-utc-plus-0830',
  'legal-1956-dst-utc-plus-0930',
  'legal-1961-utc-plus-0900',
  'legal-1987-dst-utc-plus-1000',
  'legal-1988-dst-utc-plus-1000',
  'legal-post-1989-utc-plus-0900',
] as const;

const requiredDaeunPolicyCaseIds = [
  'daeun-subyear-forward-0y-1m-after-birth',
  'daeun-subyear-reverse-0y-months-before-jeol',
  'daeun-subyear-exact-hours-minutes-included',
  'daeun-zero-age-display-metadata',
  'daeun-no-min-one-regression',
] as const;

const requiredBaselineReproductionIds = [
  'baseline-lunar-true-solar-2000-02-04',
  'baseline-1987-dst-hour-pillar-emulation',
  'baseline-1955-utc0830-emulation',
  'baseline-host-timezone-shiftSolarDate',
  'baseline-same-day-ipchun-current-term-context',
  'baseline-current-daeun-min-one-behavior',
] as const;

function idsFor(items: PolicyFixtureSectionItem[]): string[] {
  return items.map((item) => item.id);
}

function expectUniqueIds(sectionName: string, items: PolicyFixtureSectionItem[]): void {
  const ids = idsFor(items);
  expect(new Set(ids).size, `${sectionName} contains duplicate IDs`).toBe(ids.length);
}

function expectObject(value: unknown, label: string): asserts value is Record<string, unknown> {
  expect(value && typeof value === 'object' && !Array.isArray(value), label).toBe(true);
}

describe('Korean legal-time policy fixtures', () => {
  it('uses schema version 1 and known source references', () => {
    expect(policyFixtures.schemaVersion).toBe(1);
    expect(policyFixtures.metadata.sources.length).toBeGreaterThan(0);

    for (const source of policyFixtures.metadata.sources) {
      expect(source.id).toEqual(expect.any(String));
      expect(source.url).toMatch(/^https?:\/\//);
    }
  });

  it('contains the required fixture IDs without duplicates', () => {
    expectUniqueIds('legalTimeCases', policyFixtures.legalTimeCases);
    expectUniqueIds('daeunPolicyCases', policyFixtures.daeunPolicyCases);
    expectUniqueIds('baselineReproductions', policyFixtures.baselineReproductions);

    expect(idsFor(policyFixtures.legalTimeCases)).toEqual(
      expect.arrayContaining([...requiredLegalTimeCaseIds]),
    );
    expect(idsFor(policyFixtures.daeunPolicyCases)).toEqual(
      expect.arrayContaining([...requiredDaeunPolicyCaseIds]),
    );
    expect(idsFor(policyFixtures.baselineReproductions)).toEqual(
      expect.arrayContaining([...requiredBaselineReproductionIds]),
    );
  });

  it('keeps legal-time cases source-backed and arithmetically coherent', () => {
    const knownSourceIds = new Set(policyFixtures.metadata.sources.map((source) => source.id));

    for (const testCase of policyFixtures.legalTimeCases) {
      expect(testCase.title).toEqual(expect.any(String));
      expect(testCase.assertion).toEqual(expect.any(String));
      expect(testCase.sourceIds.length, `${testCase.id} sourceIds`).toBeGreaterThan(0);
      expect(testCase.legalOffsetMinutes + testCase.dstOffsetMinutes).toBe(
        testCase.effectiveOffsetMinutes,
      );

      for (const sourceId of testCase.sourceIds) {
        expect(knownSourceIds.has(sourceId), `${testCase.id} unknown source ${sourceId}`).toBe(true);
      }
    }
  });

  it('keeps Daeun policy fixtures executable as future behavior gates', () => {
    for (const testCase of policyFixtures.daeunPolicyCases) {
      expect(testCase.direction).toEqual(expect.any(String));
      expect(testCase.assertion).toEqual(expect.any(String));
      expectObject(testCase.targetPolicy, `${testCase.id} targetPolicy`);
    }
  });

  it('keeps baseline reproductions with current and target payloads', () => {
    for (const testCase of policyFixtures.baselineReproductions) {
      expect(testCase.title).toEqual(expect.any(String));
      expectObject(testCase.input, `${testCase.id} input`);
      expectObject(testCase.currentObserved, `${testCase.id} currentObserved`);
      expectObject(testCase.targetAfterFix, `${testCase.id} targetAfterFix`);
    }
  });
});
