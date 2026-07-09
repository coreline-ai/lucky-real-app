// C그룹 궁합 툴 — 엔진 직접 호출 parity + 등급 경계(85/70/55/40) 일관성 검증.
// 정확한 경계 점수(84/85 등)를 만드는 출생 쌍은 탐색 불가하므로,
// 실측 다양 등급 쌍(A/B/C + fixture A=78)에 대해 "grade가 threshold 매핑과 일치"를 검증한다.
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { Compatibility } from 'manseryeok-engine';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, connectClient, expectSuccess } from './helpers.js';

let client: Client;

beforeAll(async () => {
  client = await connectClient();
});

afterAll(async () => {
  await client.close();
});

/** 등급 경계 정본: S≥85, A≥70, B≥55, C≥40, D<40 */
function gradeFor(score: number): string {
  if (score >= 85) return 'S';
  if (score >= 70) return 'A';
  if (score >= 55) return 'B';
  if (score >= 40) return 'C';
  return 'D';
}

const birth = (year: number, month: number, day: number, hour: number | null, gender: 'male' | 'female') => ({
  year,
  month,
  day,
  hour,
  minute: hour === null ? null : 0,
  gender,
});

// P2 사전 프로브 실측: 71점 A(경계 70 근접), 63/66점 B, 51점 C
const PAIRS: Array<{ p1: ReturnType<typeof birth>; p2: ReturnType<typeof birth>; expectedGrade: string }> = [
  { p1: birth(1985, 1, 1, 6, 'male'), p2: birth(1985, 1, 13, 6, 'female'), expectedGrade: 'A' },
  { p1: { ...birth(1990, 3, 15, 14, 'male'), minute: 30 }, p2: birth(1992, 7, 20, 10, 'female'), expectedGrade: 'B' },
  { p1: birth(1990, 3, 15, 14, 'male'), p2: birth(1990, 9, 17, 2, 'female'), expectedGrade: 'C' },
  { p1: birth(1970, 5, 5, null, 'male'), p2: birth(2000, 12, 25, null, 'female'), expectedGrade: 'B' },
];

describe('compatibility_score', () => {
  it('등급이 threshold(85/70/55/40) 매핑과 일치하고 엔진 직접 호출과 동일하다', async () => {
    const seenGrades = new Set<string>();
    for (const { p1, p2, expectedGrade } of PAIRS) {
      const result = await callTool(client, 'compatibility_score', { person1: p1, person2: p2 });
      const { result: compat } = expectSuccess<{
        result: { totalScore: number; grade: string; categories: Array<{ maxScore: number }> };
      }>(result);
      const label = `${p1.year}x${p2.year}`;
      expect(compat.grade, `${label} threshold 일관성`).toBe(gradeFor(compat.totalScore));
      expect(compat.grade, `${label} 실측 등급`).toBe(expectedGrade);

      const direct = Compatibility.calculateCompatibility({
        person1: { ...p1, isLunar: false, birthPlace: null },
        person2: { ...p2, isLunar: false, birthPlace: null },
      });
      expect(compat.totalScore, `${label} 엔진 대조`).toBe(direct.totalScore);
      seenGrades.add(compat.grade);
    }
    expect(seenGrades.size, '서로 다른 등급 3종 이상').toBeGreaterThanOrEqual(3);
  });

  it('구조 계약: 카테고리 4개(만점 30/25/25/20), 양쪽 팔자, 조언 포함', async () => {
    const result = await callTool(client, 'compatibility_score', {
      person1: { year: 1990, month: 3, day: 15, hour: 14, minute: 30, gender: 'male' },
      person2: { year: 1992, month: 7, day: 21, hour: 9, minute: 0, gender: 'female' },
    });
    const { result: compat } = expectSuccess<{
      result: {
        categories: Array<{ maxScore: number; score: number }>;
        person1Palja: Record<string, string>;
        person2Palja: Record<string, string>;
        advice: string[];
        summary: string;
      };
    }>(result);
    expect(compat.categories.map((c) => c.maxScore).sort((a, b) => b - a)).toEqual([30, 25, 25, 20]);
    for (const category of compat.categories) {
      expect(category.score).toBeGreaterThanOrEqual(0);
      expect(category.score).toBeLessThanOrEqual(category.maxScore);
    }
    expect(compat.person1Palja.dayGan).toBeTruthy();
    expect(compat.person2Palja.dayGan).toBeTruthy();
    expect(compat.advice.length).toBeGreaterThan(0);
    expect(compat.summary.length).toBeGreaterThan(0);
    const text = (result.content as Array<{ text: string }>)[0].text;
    expect(text).toMatch(/^\d+점 [SABCD]등급/);
  });
});
