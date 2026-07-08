#!/usr/bin/env node
/**
 * EngineGateway fixture generator.
 *
 * Generates deterministic reference snapshots from the TypeScript engine.
 * These fixtures are the ground truth for the Dart engine port
 * (realapp/docs/09-engine-gateway-contract.md).
 *
 * Usage (from engine/):  node scripts/generate-gateway-fixtures.mjs
 * Output: realapp/engine-fixtures/gateway-fixtures.v1.json
 *
 * Determinism rule: no timestamps, no randomness. Re-running must produce
 * byte-identical output.
 */

import { createRequire } from 'node:module';
import { mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const engineDir = path.resolve(__dirname, '..');
const repoDir = path.resolve(engineDir, '..');

const engine = require(path.join(engineDir, 'dist/index.js'));
const pkg = require(path.join(engineDir, 'package.json'));

const {
  calculatePalja,
  calculateSipsin,
  calculateJijangganSipsin,
  extractJijanggan,
  calculateSeun,
  calculateWolun,
  createNormalizedManseryeokContext,
  determineSipsin,
  ManseryeokEngine,
} = engine;

const META = {
  contractVersion: '1.0.0',
  engineVersion: pkg.version,
  ruleVersion: 'krlt-yaja-2026.07',
  timezone: 'Asia/Seoul',
  midnightModeDefault: 'yaja',
};

// ---------------------------------------------------------------------------
// Case definitions
// ---------------------------------------------------------------------------

/** Representative + boundary birth inputs. gender only affects daeun (not palja). */
const FOUR_PILLAR_CASES = [
  // 대표 5건 (양력)
  { id: 'rep-1990-0315-1430-male', input: b(1990, 3, 15, 14, 30, 'male', false) },
  { id: 'rep-1985-1102-0320-female', input: b(1985, 11, 2, 3, 20, 'female', false) },
  { id: 'rep-2000-0229-1200-male-leapday', input: b(2000, 2, 29, 12, 0, 'male', false) },
  { id: 'rep-1962-1231-2340-female-yearend', input: b(1962, 12, 31, 23, 40, 'female', false) },
  { id: 'rep-2026-0707-0915-male-today', input: b(2026, 7, 7, 9, 15, 'male', false) },
  // 음력 / 윤달
  { id: 'lunar-1990-0219-1430-male', input: b(1990, 2, 19, 14, 30, 'male', true, false) },
  { id: 'lunar-leap-1911-0608-1030-male', input: b(1911, 6, 8, 10, 30, 'male', true, true) },
  { id: 'lunar-nonleap-1911-0608-1030-male', input: b(1911, 6, 8, 10, 30, 'male', true, false) },
  // 출생시 미상
  { id: 'unknown-time-1975-0820-female', input: b(1975, 8, 20, null, null, 'female', false) },
  // 야자시/조자시 경계 (23시대)
  { id: 'boundary-2330-yaja', input: b(1993, 5, 10, 23, 30, 'male', false), options: { midnightMode: 'yaja' } },
  { id: 'boundary-2330-joja', input: b(1993, 5, 10, 23, 30, 'male', false), options: { midnightMode: 'joja' } },
  // 성별 무관 확인 (동일 입력, 성별만 다름 → 동일 팔자여야 함)
  { id: 'gender-independence-female', input: b(1990, 3, 15, 14, 30, 'female', false) },
  // 오류: 법정시 전환
  { id: 'err-ambiguous-1954-0321-0015', input: b(1954, 3, 21, 0, 15, 'male', false), expectError: 'AMBIGUOUS_CIVIL_TIME' },
  { id: 'err-nonexistent-1961-0810-0015', input: b(1961, 8, 10, 0, 15, 'male', false), expectError: 'NONEXISTENT_CIVIL_TIME' },
  // 오류: 지원 범위 밖.
  // 하한은 법정시 정책 부재로 POLICY_ERROR, 상한은 절기 데이터 부재로 코드 없는 Error가 발생한다.
  // 게이트웨이는 둘 다 OUT_OF_SUPPORTED_RANGE로 매핑한다 (09 계약 문서).
  { id: 'err-range-1908-0331-below', input: b(1908, 3, 31, 12, 0, 'male', false), expectError: 'MANSERYEOK_POLICY_ERROR' },
  { id: 'err-range-2102-0101-above', input: b(2102, 1, 1, 12, 0, 'male', false), expectError: 'UNCODED' },
];

/** Daily cycle dates (noon-fixed). Includes ipchun boundary 2026-02-03/04. */
const DAILY_CYCLE_DATES = [
  { id: 'daily-2026-07-07', year: 2026, month: 7, day: 7 },
  { id: 'daily-2026-02-03-before-ipchun', year: 2026, month: 2, day: 3 },
  { id: 'daily-2026-02-04-ipchun', year: 2026, month: 2, day: 4 },
  { id: 'daily-2025-12-31', year: 2025, month: 12, day: 31 },
  { id: 'daily-2026-01-01', year: 2026, month: 1, day: 1 },
  { id: 'daily-2024-02-29-leapday', year: 2024, month: 2, day: 29 },
];

/** natal x date pairs for calculateDailyAnalysis interaction snapshot. */
const DAILY_ANALYSIS_CASES = [
  { id: 'analysis-rep1990-on-2026-07-07', natalId: 'rep-1990-0315-1430-male', date: { year: 2026, month: 7, day: 7 } },
  { id: 'analysis-unknown-on-2026-07-07', natalId: 'unknown-time-1975-0820-female', date: { year: 2026, month: 7, day: 7 } },
];

/**
 * 케미(궁합) 케이스 (2차 개발, 09 계약 4번 메서드).
 * TS calculateCompatibility가 정본. 문구 필드는 기록하지 않는다.
 */
const CHEMISTRY_CASES = [
  // 대표 조합 4건
  { id: 'chem-rep-1990x1992', a: b(1990, 3, 15, 14, 30, 'male', false), p2: b(1992, 7, 21, 9, 0, 'female', false) },
  { id: 'chem-rep-1985x1988', a: b(1985, 11, 2, 3, 20, 'female', false), p2: b(1988, 4, 13, 18, 45, 'male', false) },
  { id: 'chem-rep-1995x1995', a: b(1995, 1, 30, 7, 10, 'male', false), p2: b(1995, 12, 25, 22, 5, 'female', false) },
  { id: 'chem-rep-2000x1999', a: b(2000, 2, 29, 12, 0, 'female', false), p2: b(1999, 9, 9, 6, 30, 'male', false) },
  // 경계: 상대 출생시 미상
  { id: 'chem-unknown-time', a: b(1990, 3, 15, 14, 30, 'male', false), p2: b(1975, 8, 20, null, null, 'female', false) },
  // 경계: 동일 인물
  { id: 'chem-same-person', a: b(1990, 3, 15, 14, 30, 'male', false), p2: b(1990, 3, 15, 14, 30, 'male', false) },
  // 경계: 음력 입력 상대
  { id: 'chem-lunar-partner', a: b(1990, 3, 15, 14, 30, 'male', false), p2: b(1990, 2, 19, 14, 30, 'female', true, false) },
  // 경계: 세대 차이 큰 조합 (오행 편중 관찰)
  { id: 'chem-wide-gap', a: b(1955, 5, 5, 5, 5, 'male', false), p2: b(2001, 10, 17, 23, 30, 'female', false) },
];

function chemistrySnapshot({ id, a, p2 }) {
  const result = engine.Compatibility.calculateCompatibility({
    person1: { ...a },
    person2: { ...p2 },
  });
  const category = (key) => result.categories.find((c) => c.key === key);
  return {
    id,
    input: { personA: { ...a }, personB: { ...p2 } },
    expected: {
      totalScore: result.totalScore,
      grade: result.grade,
      dayGan: { score: category('dayGan').score, type: result.dayGanRelation.type },
      dayJi: { score: category('dayJi').score, type: result.dayJiRelation.type },
      ohaeng: { score: category('ohaeng').score },
      guseong: {
        score: category('guseong').score,
        pair: category('guseong').details[0] ?? '',
      },
      paljaA: { dayGan: result.person1Palja.dayGan, dayJi: result.person1Palja.dayJi },
      paljaB: { dayGan: result.person2Palja.dayGan, dayJi: result.person2Palja.dayJi },
    },
  };
}

const LUNAR_SOLAR_CASES = [
  { id: 'solar-to-lunar-1990-0315', direction: 'solarToLunar', input: { year: 1990, month: 3, day: 15, hour: 14, minute: 30 } },
  { id: 'lunar-to-solar-1990-0219', direction: 'lunarToSolar', input: { year: 1990, month: 2, day: 19, isLeapMonth: false, hour: 14, minute: 30 } },
  { id: 'lunar-to-solar-1900-0801-leap', direction: 'lunarToSolar', input: { year: 1900, month: 8, day: 1, isLeapMonth: true } },
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function b(year, month, day, hour, minute, gender, isLunar, isLeapMonth) {
  const input = { year, month, day, hour, minute, gender, isLunar, birthPlace: null };
  if (isLeapMonth !== undefined) input.isLeapMonth = isLeapMonth;
  return input;
}

function pillarsFromPalja(palja, timeKnown) {
  return {
    year: { gan: palja.yearGan, ji: palja.yearJi },
    month: { gan: palja.monthGan, ji: palja.monthJi },
    day: { gan: palja.dayGan, ji: palja.dayJi },
    hour: timeKnown ? { gan: palja.hourGan, ji: palja.hourJi } : null,
  };
}

function captureError(fn) {
  try {
    fn();
    return null;
  } catch (error) {
    return { name: error.name, code: error.code ?? null };
  }
}

function fourPillarsSnapshot({ id, input, options, expectError }) {
  const entry = { id, input: { ...input }, options: options ?? null };

  if (expectError) {
    const error = captureError(() => calculatePalja(input, options));
    if (!error) throw new Error(`case ${id}: expected error ${expectError} but none was thrown`);
    const matched = expectError === 'UNCODED' ? error.code == null : error.code === expectError;
    if (!matched) {
      throw new Error(`case ${id}: expected ${expectError}, got ${error.code}`);
    }
    entry.error = error;
    return entry;
  }

  const palja = calculatePalja(input, options);
  const timeKnown = input.hour !== null && input.minute !== null;
  entry.expected = {
    pillars: pillarsFromPalja(palja, timeKnown),
    dayMaster: palja.dayGan,
    sipsin: calculateSipsin(palja),
    jijanggan: extractJijanggan(palja),
    jijangganSipsin: calculateJijangganSipsin(palja),
  };
  return entry;
}

function dailyCycleSnapshot({ id, year, month, day }) {
  const ganji = ManseryeokEngine.getGanji({ year, month, day, hour: 12, minute: 0 });
  const solarContext = ManseryeokEngine.getSolarContext({ year, month, day, hour: 12, minute: 0 });
  return {
    id,
    date: { year, month, day },
    expected: {
      yearPillar: { gan: ganji.year.gan, ji: ganji.year.ji },
      monthPillar: { gan: ganji.month.gan, ji: ganji.month.ji },
      dayPillar: { gan: ganji.day.gan, ji: ganji.day.ji },
      solarContext,
    },
  };
}

function dailyAnalysisSnapshot({ id, natalId, date }) {
  const natalCase = FOUR_PILLAR_CASES.find((c) => c.id === natalId);
  const natalPalja = calculatePalja(natalCase.input, natalCase.options);
  const dayGanji = ManseryeokEngine.getGanji({ ...date, hour: 12, minute: 0 });
  const seun = calculateSeun(date.year);
  const wolun = calculateWolun(new Date(Date.UTC(date.year, date.month - 1, date.day, 3, 0, 0))); // 12:00 KST
  return {
    id,
    natalId,
    date,
    expected: {
      interaction: {
        dayStemSipsin: determineSipsin(natalPalja.dayGan, dayGanji.day.gan),
        seun: { gan: seun.gan, ji: seun.ji },
        wolun: { gan: wolun.gan, ji: wolun.ji },
      },
    },
  };
}

function lunarSolarSnapshot({ id, direction, input }) {
  const result = direction === 'solarToLunar'
    ? ManseryeokEngine.solarToLunar(input)
    : ManseryeokEngine.lunarToSolar(input);
  return { id, direction, input, expected: result };
}

// ---------------------------------------------------------------------------
// Generate
// ---------------------------------------------------------------------------

const fixtures = {
  meta: META,
  fourPillars: FOUR_PILLAR_CASES.map(fourPillarsSnapshot),
  dailyCycle: DAILY_CYCLE_DATES.map(dailyCycleSnapshot),
  dailyAnalysis: DAILY_ANALYSIS_CASES.map(dailyAnalysisSnapshot),
  lunarSolar: LUNAR_SOLAR_CASES.map(lunarSolarSnapshot),
  chemistry: CHEMISTRY_CASES.map(chemistrySnapshot),
};

// Sanity check: gender must not affect palja.
const male = fixtures.fourPillars.find((c) => c.id === 'rep-1990-0315-1430-male');
const female = fixtures.fourPillars.find((c) => c.id === 'gender-independence-female');
if (JSON.stringify(male.expected.pillars) !== JSON.stringify(female.expected.pillars)) {
  throw new Error('gender unexpectedly affected palja output');
}

const outDir = path.join(repoDir, 'realapp', 'engine-fixtures');
mkdirSync(outDir, { recursive: true });
const outPath = path.join(outDir, 'gateway-fixtures.v1.json');
writeFileSync(outPath, `${JSON.stringify(fixtures, null, 2)}\n`, 'utf8');

const caseCount =
  fixtures.fourPillars.length +
  fixtures.dailyCycle.length +
  fixtures.dailyAnalysis.length +
  fixtures.lunarSolar.length +
  fixtures.chemistry.length;
console.log(`# Gateway fixtures`);
console.log(`cases: ${caseCount}`);
console.log(`output: ${path.relative(repoDir, outPath)}`);
