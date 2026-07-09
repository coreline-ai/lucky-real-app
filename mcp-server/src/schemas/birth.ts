// 공용 BirthInput 스키마 (dev-plan "공용 스키마 사양").
// realapp 09 계약의 상위집합: 진태양시(trueSolarTime/longitude)까지 노출한다.
// 연도 도메인 범위는 zod에 두지 않는다 — 엔진 오류 코드(1908 정책 등)를 그대로 전달(D8).
import type { BirthInputData, CalculateOptions } from 'manseryeok-engine';
import { z } from 'zod';

export const BirthInputSchema = z
  .object({
    year: z.number().int().describe('출생 연도 (팔자 지원 1908-04-01~2101-12-31, 범위 밖은 엔진 오류 코드 반환)'),
    month: z.number().int().min(1).max(12).describe('출생 월'),
    day: z.number().int().min(1).max(31).describe('출생 일'),
    hour: z
      .number()
      .int()
      .min(0)
      .max(23)
      .nullable()
      .default(null)
      .describe('출생 시 (0~23). null = 출생시 미상 → 시주 생략'),
    minute: z
      .number()
      .int()
      .min(0)
      .max(59)
      .nullable()
      .default(null)
      .describe('출생 분. hour만 지정하면 0으로 보완됨'),
    gender: z.enum(['male', 'female']).describe('성별 — 대운 순행/역행 방향을 결정'),
    calendarType: z.enum(['solar', 'lunar']).default('solar').describe('입력 날짜의 달력 (기본 양력)'),
    isLeapMonth: z.boolean().default(false).describe('음력 윤달 여부 (calendarType=lunar에서만 허용)'),
    midnightMode: z
      .enum(['yaja', 'joja'])
      .default('yaja')
      .describe('자시 경계 규칙 — yaja(야자시, 기본): 23시대 출생은 당일 일주 유지, joja(조자시): 일주가 다음날로 전환'),
    trueSolarTime: z.boolean().default(false).describe('진태양시 보정 활성화'),
    longitude: z
      .number()
      .min(124)
      .max(132)
      .optional()
      .describe('출생지 경도 — trueSolarTime=true일 때만 사용 (기본 127.0 서울)'),
    birthPlace: z.string().nullable().default(null).describe('출생지 표기 (계산에는 미사용)'),
  })
  .superRefine((birth, ctx) => {
    if (birth.calendarType === 'solar' && birth.isLeapMonth) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['isLeapMonth'],
        message: 'isLeapMonth=true는 calendarType=lunar에서만 지정할 수 있습니다.',
      });
    }
    if (birth.hour === null && birth.minute !== null) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['minute'],
        message: 'minute은 hour와 함께 지정해야 합니다 (출생시 미상이면 둘 다 null).',
      });
    }
    if (!birth.trueSolarTime && birth.longitude !== undefined) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['longitude'],
        message: 'longitude는 trueSolarTime=true일 때만 지정할 수 있습니다.',
      });
    }
  });

export type BirthInput = z.infer<typeof BirthInputSchema>;

/** MCP BirthInput → 엔진 BirthInputData (calendarType→isLunar 매핑, minute 보완) */
export function toBirthInputData(birth: BirthInput): BirthInputData {
  return {
    year: birth.year,
    month: birth.month,
    day: birth.day,
    hour: birth.hour,
    minute: birth.hour !== null ? (birth.minute ?? 0) : null,
    gender: birth.gender,
    isLunar: birth.calendarType === 'lunar',
    isLeapMonth: birth.isLeapMonth,
    birthPlace: birth.birthPlace,
  };
}

/** MCP BirthInput → 엔진 CalculateOptions (midnightMode/trueSolarTime/longitude) */
export function toCalculateOptions(birth: BirthInput): CalculateOptions {
  return {
    midnightMode: birth.midnightMode,
    trueSolarTime: birth.trueSolarTime,
    ...(birth.longitude !== undefined ? { longitude: birth.longitude } : {}),
  };
}

/** 시주 산출 여부 — 엔진 calculatePalja의 includeTime 조건과 동일 */
export function isBirthTimeKnown(birth: BirthInput): boolean {
  return birth.hour !== null;
}
