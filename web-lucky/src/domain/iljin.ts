import { Calendar } from 'manseryeok-engine';

export type IljinDayOk = {
  ok: true;
  year: number;
  month: number;
  day: number;
  dayInfo: ReturnType<typeof Calendar.getCalendarDay>;
};

export type IljinDayErr = { ok: false; message: string };

export type IljinDayOutcome = IljinDayOk | IljinDayErr;

export function runIljinDay(
  year: number,
  month: number,
  day: number,
): IljinDayOutcome {
  if (!Number.isInteger(year) || year < 1900 || year > 2101) {
    return { ok: false, message: '연도 범위를 확인해 주세요.' };
  }
  if (!Number.isInteger(month) || month < 1 || month > 12) {
    return { ok: false, message: '월은 1~12여야 합니다.' };
  }
  if (!Number.isInteger(day) || day < 1 || day > 31) {
    return { ok: false, message: '일이 올바르지 않습니다.' };
  }
  try {
    const dayInfo = Calendar.getCalendarDay(year, month, day);
    if (!dayInfo?.dayGanJi) {
      return { ok: false, message: '일진 데이터를 가져오지 못했습니다.' };
    }
    return { ok: true, year, month, day, dayInfo };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
      ok: false,
      message: `일진 계산에 실패했습니다. 날짜를 확인해 주세요. (${msg})`,
    };
  }
}

export function shiftDate(
  year: number,
  month: number,
  day: number,
  deltaDays: number,
): { year: number; month: number; day: number } {
  const dt = new Date(Date.UTC(year, month - 1, day));
  dt.setUTCDate(dt.getUTCDate() + deltaDays);
  return {
    year: dt.getUTCFullYear(),
    month: dt.getUTCMonth() + 1,
    day: dt.getUTCDate(),
  };
}
