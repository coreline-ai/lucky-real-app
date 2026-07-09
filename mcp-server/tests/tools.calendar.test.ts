// A그룹 5툴 정상 케이스 — 엔진 직접 호출 결과와 대조한다.
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import {
  Calendar,
  getSolarTermsOnDate,
  listSolarTermsForYear,
  resolveKoreanLegalTime,
  solarToLunar,
} from 'manseryeok-engine';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, connectClient, expectSuccess } from './helpers.js';

let client: Client;

beforeAll(async () => {
  client = await connectClient();
});

afterAll(async () => {
  await client.close();
});

describe('tools/list', () => {
  it('A그룹 5툴 + B·C그룹 4툴이 등록되고, 전 툴이 readOnly annotations와 outputSchema를 갖는다', async () => {
    const { tools } = await client.listTools();
    const names = tools.map((t) => t.name);
    expect(names).toEqual(
      expect.arrayContaining([
        // A그룹 (P1)
        'calendar_day_info',
        'calendar_month',
        'date_convert',
        'korean_legal_time',
        'solar_terms',
        // B·C그룹 (P2)
        'saju_full_reading',
        'saju_palja',
        'saju_daeun',
        'compatibility_score',
      ]),
    );
    // 전 툴 공통 불변식 (계획서 공통 규칙)
    for (const tool of tools) {
      expect(tool.annotations?.readOnlyHint, `${tool.name} readOnlyHint`).toBe(true);
      expect(tool.annotations?.openWorldHint, `${tool.name} openWorldHint`).toBe(false);
      expect(tool.outputSchema, `${tool.name} outputSchema (D10)`).toBeDefined();
    }
  });
});

describe('calendar_day_info', () => {
  it('2026-07-09 일진이 엔진 직접 호출과 일치한다 (갑신일)', async () => {
    const result = await callTool(client, 'calendar_day_info', { year: 2026, month: 7, day: 9 });
    const structured = expectSuccess<{ day: Record<string, unknown> }>(result);
    const direct = Calendar.getCalendarDay(2026, 7, 9);
    expect(structured.day).toEqual({ ...direct });
    expect(structured.day.dayGanJi).toBe('갑신');
    expect(structured.day.lunarDate).toBe('2026-05-25');
    expect(structured.day.gilhyung).toBe('평');
    const text = (result.content as Array<{ text: string }>)[0].text;
    expect(text).toContain('갑신');
    expect(text).toContain('2026-07-09');
  });
});

describe('calendar_month', () => {
  it('2026년 7월 full 모드: 31일 전체 + 월간지가 엔진과 일치한다', async () => {
    const result = await callTool(client, 'calendar_month', { year: 2026, month: 7 });
    const structured = expectSuccess<{ monthGanJi: string; compact: boolean; days: unknown[] }>(result);
    const direct = Calendar.getMonthlyCalendar(2026, 7);
    expect(structured.compact).toBe(false);
    expect(structured.monthGanJi).toBe(direct.monthGanJi);
    expect(structured.days).toHaveLength(31);
    expect(structured.days).toEqual(direct.days.map((d) => ({ ...d })));
  });

  it('compact 모드: 일별 항목이 3필드로 축약된다', async () => {
    const result = await callTool(client, 'calendar_month', { year: 2026, month: 7, compact: true });
    const structured = expectSuccess<{ compact: boolean; days: Array<Record<string, unknown>> }>(result);
    expect(structured.compact).toBe(true);
    expect(structured.days).toHaveLength(31);
    for (const day of structured.days) {
      expect(Object.keys(day).sort()).toEqual(['dayGanJi', 'gilhyung', 'solarDate']);
    }
  });
});

describe('date_convert', () => {
  it('양→음: 2026-07-09 → 음 2026-05-25 (엔진 일치)', async () => {
    const result = await callTool(client, 'date_convert', {
      direction: 'solar_to_lunar',
      year: 2026,
      month: 7,
      day: 9,
    });
    const structured = expectSuccess<{ result: Record<string, unknown> }>(result);
    expect(structured.result).toEqual({ ...solarToLunar({ year: 2026, month: 7, day: 9 }) });
    expect(structured.result.year).toBe(2026);
    expect(structured.result.month).toBe(5);
    expect(structured.result.day).toBe(25);
    expect(structured.result.isLeapMonth).toBe(false);
  });

  it('음→양 왕복: 음 2026-05-25 → 양 2026-07-09', async () => {
    const result = await callTool(client, 'date_convert', {
      direction: 'lunar_to_solar',
      year: 2026,
      month: 5,
      day: 25,
      isLeapMonth: false,
    });
    const structured = expectSuccess<{ result: { year: number; month: number; day: number } }>(result);
    expect(structured.result.year).toBe(2026);
    expect(structured.result.month).toBe(7);
    expect(structured.result.day).toBe(9);
  });
});

describe('solar_terms', () => {
  it('연도 조회: 2026년 절기 24개가 엔진과 일치한다', async () => {
    const result = await callTool(client, 'solar_terms', { year: 2026 });
    const structured = expectSuccess<{ terms: unknown[] }>(result);
    expect(structured.terms).toHaveLength(24);
    expect(structured.terms).toEqual(listSolarTermsForYear(2026).map((t) => ({ ...t })));
  });

  it('특정일 조회: 2026-02-04는 입춘', async () => {
    const result = await callTool(client, 'solar_terms', { year: 2026, month: 2, day: 4 });
    const structured = expectSuccess<{ terms: Array<{ koreanName: string }> }>(result);
    expect(structured.terms.map((t) => t.koreanName)).toEqual(
      getSolarTermsOnDate(2026, 2, 4).map((t) => t.koreanName),
    );
    expect(structured.terms[0]?.koreanName).toBe('입춘');
  });
});

describe('korean_legal_time', () => {
  it('2026-07-09 12:00 → UTC+9h 표준시 (엔진 일치)', async () => {
    const result = await callTool(client, 'korean_legal_time', {
      year: 2026,
      month: 7,
      day: 9,
      hour: 12,
      minute: 0,
    });
    const structured = expectSuccess<{ resolution: Record<string, unknown> }>(result);
    const direct = resolveKoreanLegalTime({ year: 2026, month: 7, day: 9, hour: 12, minute: 0, second: 0 });
    expect(structured.resolution).toEqual({ ...direct });
    expect(structured.resolution.totalOffsetMinutes).toBe(540);
    expect(structured.resolution.transitionStatus).toBe('standard');
  });
});
