/**
 * Asia/Seoul calendar parts for "today" / current month UI.
 * Avoids relying on the host local timezone for demo consistency (D5).
 */
export type KstParts = {
  year: number;
  month: number;
  day: number;
};

export function kstNowParts(now: Date = new Date()): KstParts {
  const fmt = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Seoul',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  // en-CA → YYYY-MM-DD
  const parts = fmt.formatToParts(now);
  const year = Number(parts.find((p) => p.type === 'year')?.value);
  const month = Number(parts.find((p) => p.type === 'month')?.value);
  const day = Number(parts.find((p) => p.type === 'day')?.value);
  if (!year || !month || !day) {
    throw new Error('KST date parts could not be resolved');
  }
  return { year, month, day };
}

/** Default target year: in December (KST), prefer next year for new-year season (D6). */
export function defaultTargetYear(now: Date = new Date()): number {
  const { year, month } = kstNowParts(now);
  return month === 12 ? year + 1 : year;
}

export function yearPresetList(now: Date = new Date()): number[] {
  const { year } = kstNowParts(now);
  return [year - 1, year, year + 1];
}
