// 골든 fixture parity — 3개 구현체(TS 엔진·Dart 게이트웨이 계약·MCP)가 같은 답을 내는지 검증.
// - engine/tests/fixtures/manseryeok-golden.json: 외부 만세력 대조 케이스 (기둥 결합 문자열 "壬申")
// - realapp/engine-fixtures/gateway-fixtures.v1.json: Dart 게이트웨이 계약 케이스 ({gan, ji} 중첩)
//   → TS Palja(8필드 플랫)와 포맷이 다르므로 비교용 매핑 헬퍼를 여기 둔다 (계획서 P2 주의사항).
import { readFileSync } from 'node:fs';
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, connectClient, expectErrorPayload, expectSuccess } from './helpers.js';

interface GoldenCase {
  id: string;
  input: {
    calendar: 'solar' | 'lunar';
    year: number;
    month: number;
    day: number;
    hour: number | null;
    minute?: number | null;
    gender: 'male' | 'female';
    isLeapMonth?: boolean;
  };
  /** 케이스 종류에 따라 4주 또는 양력 변환 결과(solar)만 있을 수 있다 */
  expected: {
    yearPillar?: string;
    monthPillar?: string;
    dayPillar?: string;
    hourPillar?: string | null;
    solar?: string;
  };
}

interface GatewayFourPillarsCase {
  id: string;
  input: {
    year: number;
    month: number;
    day: number;
    hour: number | null;
    minute: number | null;
    gender: 'male' | 'female';
    isLunar: boolean;
    isLeapMonth?: boolean;
  };
  options: { midnightMode?: 'yaja' | 'joja' } | null;
  /** 정상 케이스: expected.pillars / 오류 기대 케이스: error */
  expected?: {
    pillars: Record<'year' | 'month' | 'day', { gan: string; ji: string }> & {
      hour: { gan: string; ji: string } | null;
    };
  };
  error?: { name: string; code: string | null };
}

interface ChemistryCase {
  id: string;
  input: {
    personA: GatewayFourPillarsCase['input'];
    personB: GatewayFourPillarsCase['input'];
  };
  expected: {
    totalScore: number;
    grade: string;
    dayGan: { score: number; type: string };
    dayJi: { score: number; type: string };
  };
}

const golden = JSON.parse(
  readFileSync(new URL('../../engine/tests/fixtures/manseryeok-golden.json', import.meta.url), 'utf8'),
) as { cases: GoldenCase[] };

const gateway = JSON.parse(
  readFileSync(new URL('../../realapp/engine-fixtures/gateway-fixtures.v1.json', import.meta.url), 'utf8'),
) as { fourPillars: GatewayFourPillarsCase[]; chemistry: ChemistryCase[] };

/** fixture input → 툴 birth 인자 */
function toBirthArgs(
  input: GoldenCase['input'] | GatewayFourPillarsCase['input'],
  midnightMode?: 'yaja' | 'joja',
): Record<string, unknown> {
  const calendarType =
    'calendar' in input ? input.calendar : input.isLunar ? 'lunar' : 'solar';
  return {
    year: input.year,
    month: input.month,
    day: input.day,
    hour: input.hour ?? null,
    minute: input.minute ?? null,
    gender: input.gender,
    calendarType,
    ...(input.isLeapMonth ? { isLeapMonth: true } : {}),
    ...(midnightMode ? { midnightMode } : {}),
  };
}

/** 게이트웨이 {gan, ji} 중첩 포맷 → 플랫 Palja 8필드 (매핑 헬퍼) */
function pillarsToPalja(pillars: GatewayFourPillarsCase['expected']['pillars']): Record<string, string> {
  return {
    yearGan: pillars.year.gan,
    yearJi: pillars.year.ji,
    monthGan: pillars.month.gan,
    monthJi: pillars.month.ji,
    dayGan: pillars.day.gan,
    dayJi: pillars.day.ji,
    hourGan: pillars.hour?.gan ?? '',
    hourJi: pillars.hour?.ji ?? '',
  };
}

let client: Client;

beforeAll(async () => {
  client = await connectClient();
});

afterAll(async () => {
  await client.close();
});

describe('manseryeok-golden.json (외부 만세력 대조 케이스)', () => {
  it('4주 케이스의 팔자가 일치한다', async () => {
    const paljaCases = golden.cases.filter((c) => c.expected.yearPillar);
    expect(paljaCases.length).toBeGreaterThanOrEqual(3);
    for (const testCase of paljaCases) {
      const result = await callTool(client, 'saju_palja', { birth: toBirthArgs(testCase.input) });
      const { palja } = expectSuccess<{ palja: Record<string, string> }>(result);
      const label = `[${testCase.id}]`;
      expect(palja.yearGan + palja.yearJi, `${label} 연주`).toBe(testCase.expected.yearPillar);
      expect(palja.monthGan + palja.monthJi, `${label} 월주`).toBe(testCase.expected.monthPillar);
      expect(palja.dayGan + palja.dayJi, `${label} 일주`).toBe(testCase.expected.dayPillar);
      if (testCase.expected.hourPillar) {
        expect(palja.hourGan + palja.hourJi, `${label} 시주`).toBe(testCase.expected.hourPillar);
      }
    }
  });

  it('음력 케이스의 양력 변환(expected.solar)이 date_convert와 일치한다 — 1911 윤6월 포함', async () => {
    const lunarCases = golden.cases.filter((c) => c.input.calendar === 'lunar' && c.expected.solar);
    expect(lunarCases.length).toBeGreaterThanOrEqual(2);
    for (const testCase of lunarCases) {
      const result = await callTool(client, 'date_convert', {
        direction: 'lunar_to_solar',
        year: testCase.input.year,
        month: testCase.input.month,
        day: testCase.input.day,
        isLeapMonth: testCase.input.isLeapMonth ?? false,
      });
      const { result: converted } = expectSuccess<{
        result: { year: number; month: number; day: number };
      }>(result);
      const solarString = `${converted.year}-${String(converted.month).padStart(2, '0')}-${String(converted.day).padStart(2, '0')}`;
      expect(solarString, `[${testCase.id}]`).toBe(testCase.expected.solar);
    }
  });
});

describe('gateway-fixtures.v1.json fourPillars (Dart 게이트웨이 계약 케이스)', () => {
  it('정상 케이스(12건)의 팔자가 일치한다 — 시주 미상·midnightMode 케이스 포함', async () => {
    const normalCases = gateway.fourPillars.filter((c) => c.expected?.pillars);
    expect(normalCases.length).toBeGreaterThanOrEqual(12);
    for (const testCase of normalCases) {
      const result = await callTool(client, 'saju_palja', {
        birth: toBirthArgs(testCase.input, testCase.options?.midnightMode),
      });
      const { palja, birthTimeKnown } = expectSuccess<{
        palja: Record<string, string>;
        birthTimeKnown: boolean;
      }>(result);
      expect(palja, `[${testCase.id}]`).toEqual(pillarsToPalja(testCase.expected!.pillars));
      expect(birthTimeKnown, `[${testCase.id}] birthTimeKnown`).toBe(testCase.input.hour !== null);
    }
  });

  it('오류 기대 케이스(4건)의 오류 코드가 계약대로 전달된다 — 1908 정책 오류 포함', async () => {
    const errorCases = gateway.fourPillars.filter((c) => c.error);
    expect(errorCases.length).toBeGreaterThanOrEqual(4);
    for (const testCase of errorCases) {
      const result = await callTool(client, 'saju_palja', {
        birth: toBirthArgs(testCase.input, testCase.options?.midnightMode),
      });
      const payload = expectErrorPayload(result);
      // fixture가 code: null(plain Error)로 기대하는 케이스는 errors.ts가
      // MANSERYEOK_DATA_ERROR로 정규화한다 (P1 이슈 3의 오류 계약).
      const expectedCode = testCase.error!.code ?? 'MANSERYEOK_DATA_ERROR';
      expect(payload.code, `[${testCase.id}]`).toBe(expectedCode);
    }
  });
});

describe('gateway-fixtures.v1.json chemistry (궁합 계약 케이스)', () => {
  it('전 케이스의 총점·등급·일간/일지 관계가 일치한다', async () => {
    expect(gateway.chemistry.length).toBeGreaterThan(0);
    for (const testCase of gateway.chemistry) {
      const result = await callTool(client, 'compatibility_score', {
        person1: toBirthArgs(testCase.input.personA),
        person2: toBirthArgs(testCase.input.personB),
      });
      const { result: compat } = expectSuccess<{
        result: {
          totalScore: number;
          grade: string;
          dayGanRelation: { type: string };
          dayJiRelation: { type: string };
        };
      }>(result);
      const label = `[${testCase.id}]`;
      expect(compat.totalScore, `${label} 총점`).toBe(testCase.expected.totalScore);
      expect(compat.grade, `${label} 등급`).toBe(testCase.expected.grade);
      expect(compat.dayGanRelation.type, `${label} 일간 관계`).toBe(testCase.expected.dayGan.type);
      expect(compat.dayJiRelation.type, `${label} 일지 관계`).toBe(testCase.expected.dayJi.type);
    }
  });
});
