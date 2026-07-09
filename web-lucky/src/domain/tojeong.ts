import { Tojeong, solarToLunar } from 'manseryeok-engine';
import type { TojeongResult } from 'manseryeok-engine';

export type CalendarType = 'solar' | 'lunar';

export type BirthInput = {
  year: number;
  month: number;
  day: number;
  calendarType: CalendarType;
  isLeapMonth?: boolean;
};

export type LunarBirth = {
  year: number;
  month: number;
  day: number;
  isLeapMonth: boolean;
};

export type TojeongYearlyOk = {
  ok: true;
  lunarBirth: LunarBirth;
  targetYear: number;
  result: TojeongResult;
};

export type TojeongYearlyErr = {
  ok: false;
  message: string;
};

export type TojeongYearlyOutcome = TojeongYearlyOk | TojeongYearlyErr;

function validateBirth(birth: BirthInput): string | null {
  if (!Number.isInteger(birth.year) || birth.year < 1900 || birth.year > 2101) {
    return '지원 연도 범위를 확인해 주세요 (대략 1900~2101).';
  }
  if (!Number.isInteger(birth.month) || birth.month < 1 || birth.month > 12) {
    return '월은 1~12 사이여야 합니다.';
  }
  if (!Number.isInteger(birth.day) || birth.day < 1 || birth.day > 31) {
    return '일은 1~31 사이여야 합니다.';
  }
  if (birth.calendarType === 'solar' && birth.isLeapMonth) {
    return '윤달은 음력에서만 선택할 수 있습니다.';
  }
  return null;
}

export function resolveLunarBirth(birth: BirthInput): LunarBirth {
  if (birth.calendarType === 'lunar') {
    return {
      year: birth.year,
      month: birth.month,
      day: birth.day,
      isLeapMonth: Boolean(birth.isLeapMonth),
    };
  }
  const converted = solarToLunar({
    year: birth.year,
    month: birth.month,
    day: birth.day,
  });
  return {
    year: converted.year,
    month: converted.month,
    day: converted.day,
    isLeapMonth: Boolean(converted.isLeapMonth),
  };
}

/**
 * Pure yearly Tojeong path: solar→lunar when needed, then analyzeTojeong.
 * Does not use birth time or gender.
 */
export function runTojeongYearly(
  birth: BirthInput,
  targetYear: number,
): TojeongYearlyOutcome {
  const birthError = validateBirth(birth);
  if (birthError) {
    return { ok: false, message: birthError };
  }
  if (!Number.isInteger(targetYear) || targetYear < 1900 || targetYear > 2101) {
    return { ok: false, message: '대상 연도 범위를 확인해 주세요.' };
  }
  if (targetYear < birth.year - 1) {
    // Soft allow but warn via message only when clearly before plausible birth era
    // Still compute if engine accepts; we only hard-block absurd gaps below.
  }

  try {
    const lunarBirth = resolveLunarBirth(birth);
    const result = Tojeong.analyzeTojeong(
      lunarBirth.year,
      lunarBirth.month,
      lunarBirth.day,
      targetYear,
    );
    if (
      !result?.interpretation?.monthly ||
      result.interpretation.monthly.length !== 12
    ) {
      return { ok: false, message: '월별 운세 데이터가 올바르지 않습니다.' };
    }
    return { ok: true, lunarBirth, targetYear, result };
  } catch (err) {
    const msg =
      err instanceof Error ? err.message : '계산 중 오류가 발생했습니다.';
    return {
      ok: false,
      message: `계산에 실패했습니다. 날짜 지원 범위를 확인해 주세요. (${msg})`,
    };
  }
}
