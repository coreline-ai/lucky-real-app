// A그룹: 만세력·달력 툴 5종 (dev-plan 툴 카탈로그 A)
//
// 도메인 범위(1899~2101, 월 1~12 등)는 의도적으로 zod에 두지 않는다 —
// 엔진의 공식 오류 코드(MANSERYEOK_DATA_ERROR 등)를 오류 계약 그대로 전달하기 위함.
// zod는 타입 수준(int) 검증만 담당한다.
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import {
  Calendar,
  getSolarTermsOnDate,
  listSolarTermsForYear,
  lunarToSolar,
  resolveKoreanLegalTime,
  solarToLunar,
} from 'manseryeok-engine';
import { z } from 'zod';

import { invalidInput, withErrorMapping } from '../errors.js';
import { ENGINE_META } from '../meta.js';
import {
  summarizeCalendarDay,
  summarizeCalendarMonth,
  summarizeDateConvert,
  summarizeLegalTime,
  summarizeSolarTerms,
} from '../render/summary.js';
import {
  calendarDayInfoOutput,
  calendarMonthOutput,
  dateConvertOutput,
  koreanLegalTimeOutput,
  solarTermsOutput,
} from '../schemas/output.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

const yearField = z.number().int().describe('양력 연도 (지원 1899~2101, 범위 밖은 엔진 오류 코드 반환)');
const monthField = z.number().int().describe('월 (1~12)');
const dayField = z.number().int().describe('일 (1~31)');

export function registerCalendarTools(server: McpServer): void {
  server.registerTool(
    'calendar_day_info',
    {
      title: '일진·역학달력 하루 정보',
      description:
        '양력 날짜 하루의 일진(간지)·음력 날짜·오행·12신살·길흉·택일 정보·절기를 반환합니다. KST 기준.',
      inputSchema: { year: yearField, month: monthField, day: dayField },
      outputSchema: calendarDayInfoOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ year, month, day }: { year: number; month: number; day: number }) => {
      const dayInfo = Calendar.getCalendarDay(year, month, day);
      return {
        content: [{ type: 'text' as const, text: summarizeCalendarDay(dayInfo) }],
        structuredContent: { meta: { ...ENGINE_META }, day: dayInfo },
      };
    }),
  );

  server.registerTool(
    'calendar_month',
    {
      title: '월간 역학달력',
      description:
        '양력 연·월의 월간지와 일별 일진 배열을 반환합니다. compact=true면 일별 항목을 날짜·간지·길흉 3필드로 축약합니다(토큰 절약).',
      inputSchema: {
        year: yearField,
        month: monthField,
        compact: z.boolean().default(false).describe('true면 일별 항목을 solarDate/dayGanJi/gilhyung만으로 축약'),
      },
      outputSchema: calendarMonthOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ year, month, compact }: { year: number; month: number; compact: boolean }) => {
      const calendar = Calendar.getMonthlyCalendar(year, month);
      const days = compact
        ? calendar.days.map((d) => ({ solarDate: d.solarDate, dayGanJi: d.dayGanJi, gilhyung: d.gilhyung }))
        : calendar.days;
      return {
        content: [{ type: 'text' as const, text: summarizeCalendarMonth(calendar, compact) }],
        structuredContent: {
          meta: { ...ENGINE_META },
          year: calendar.year,
          month: calendar.month,
          monthGanJi: calendar.monthGanJi,
          compact,
          days,
        },
      };
    }),
  );

  server.registerTool(
    'date_convert',
    {
      title: '양력·음력 변환',
      description:
        '양력↔음력 날짜를 변환합니다. direction=solar_to_lunar(양→음) 또는 lunar_to_solar(음→양). 음력 입력의 윤달은 isLeapMonth로 지정합니다.',
      inputSchema: {
        direction: z.enum(['solar_to_lunar', 'lunar_to_solar']).describe('변환 방향'),
        year: yearField,
        month: monthField,
        day: dayField,
        isLeapMonth: z.boolean().default(false).describe('음력 입력(lunar_to_solar)의 윤달 여부. solar_to_lunar에서는 무시'),
      },
      outputSchema: dateConvertOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        direction,
        year,
        month,
        day,
        isLeapMonth,
      }: {
        direction: 'solar_to_lunar' | 'lunar_to_solar';
        year: number;
        month: number;
        day: number;
        isLeapMonth: boolean;
      }) => {
        const input =
          direction === 'solar_to_lunar' ? { year, month, day } : { year, month, day, isLeapMonth };
        const result =
          direction === 'solar_to_lunar'
            ? solarToLunar({ year, month, day })
            : lunarToSolar({ year, month, day, isLeapMonth });
        return {
          content: [{ type: 'text' as const, text: summarizeDateConvert(direction, input, result) }],
          structuredContent: { meta: { ...ENGINE_META }, direction, input, result },
        };
      },
    ),
  );

  server.registerTool(
    'solar_terms',
    {
      title: '24절기 조회',
      description:
        '연도의 24절기 목록(정확한 KST 입절 시각 포함)을 반환합니다. month·day를 함께 주면 해당 날짜의 절기만 조회합니다(없으면 빈 배열).',
      inputSchema: {
        year: yearField,
        month: monthField.optional().describe('특정일 조회 시 월 — day와 함께 지정'),
        day: dayField.optional().describe('특정일 조회 시 일 — month와 함께 지정'),
      },
      outputSchema: solarTermsOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ year, month, day }: { year: number; month?: number; day?: number }) => {
      if ((month === undefined) !== (day === undefined)) {
        return invalidInput('month와 day는 함께 지정해야 합니다.', { month, day });
      }
      const terms =
        month !== undefined && day !== undefined
          ? getSolarTermsOnDate(year, month, day)
          : listSolarTermsForYear(year);
      const query = { year, ...(month !== undefined ? { month } : {}), ...(day !== undefined ? { day } : {}) };
      return {
        content: [{ type: 'text' as const, text: summarizeSolarTerms(query, terms) }],
        structuredContent: { meta: { ...ENGINE_META }, query, terms },
      };
    }),
  );

  server.registerTool(
    'korean_legal_time',
    {
      title: '한국 법정시 해석 (전문가용)',
      description:
        '주어진 KST 시각의 법정시 오프셋(표준시·서머타임)을 해석합니다. 1948~1960·1987~1988 DST 구간의 모호(AMBIGUOUS_CIVIL_TIME)/부재(NONEXISTENT_CIVIL_TIME) 시각은 오류 코드로 반환됩니다.',
      inputSchema: {
        year: yearField,
        month: monthField,
        day: dayField,
        hour: z.number().int().min(0).max(23).describe('시 (0~23)'),
        minute: z.number().int().min(0).max(59).describe('분 (0~59)'),
        second: z.number().int().min(0).max(59).default(0).describe('초 (0~59, 기본 0)'),
      },
      outputSchema: koreanLegalTimeOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        year,
        month,
        day,
        hour,
        minute,
        second,
      }: {
        year: number;
        month: number;
        day: number;
        hour: number;
        minute: number;
        second: number;
      }) => {
        const input = { year, month, day, hour, minute, second };
        const resolution = resolveKoreanLegalTime(input);
        return {
          content: [{ type: 'text' as const, text: summarizeLegalTime(input, resolution) }],
          structuredContent: { meta: { ...ENGINE_META }, input, resolution },
        };
      },
    ),
  );
}
