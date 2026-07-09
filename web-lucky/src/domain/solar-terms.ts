import { listSolarTermsForYear, type SolarTermInfo } from 'manseryeok-engine';
import { kstNowParts } from './kst';

export type SolarTermsOk = {
  ok: true;
  year: number;
  terms: SolarTermInfo[];
  next: SolarTermInfo | null;
  current: SolarTermInfo | null;
};

export type SolarTermsErr = { ok: false; message: string };

export type SolarTermsOutcome = SolarTermsOk | SolarTermsErr;

function termTimestamp(t: SolarTermInfo): number {
  // Approximate KST wall time as local-comparable ms via Date.UTC + +9h offset handling:
  // Engine stores KST calendar fields; build a comparable number yyyymmddhhmmss.
  return (
    t.year * 1e10 +
    t.month * 1e8 +
    t.day * 1e6 +
    t.hour * 1e4 +
    t.minute * 100 +
    t.second
  );
}

function nowTimestamp(now: {
  year: number;
  month: number;
  day: number;
  hour?: number;
  minute?: number;
  second?: number;
}): number {
  return (
    now.year * 1e10 +
    now.month * 1e8 +
    now.day * 1e6 +
    (now.hour ?? 12) * 1e4 +
    (now.minute ?? 0) * 100 +
    (now.second ?? 0)
  );
}

/** First term strictly after `now`; null if none left in list. */
export function findNextTerm(
  terms: readonly SolarTermInfo[],
  now: { year: number; month: number; day: number; hour?: number; minute?: number; second?: number },
): SolarTermInfo | null {
  const n = nowTimestamp(now);
  for (const t of terms) {
    if (termTimestamp(t) > n) return t;
  }
  return null;
}

/** Last term at or before `now` (current season marker). */
export function findCurrentTerm(
  terms: readonly SolarTermInfo[],
  now: { year: number; month: number; day: number; hour?: number; minute?: number; second?: number },
): SolarTermInfo | null {
  const n = nowTimestamp(now);
  let cur: SolarTermInfo | null = null;
  for (const t of terms) {
    if (termTimestamp(t) <= n) cur = t;
    else break;
  }
  return cur;
}

export function runSolarTermsYear(
  year: number,
  now: { year: number; month: number; day: number; hour?: number; minute?: number; second?: number } = kstNowParts(),
): SolarTermsOutcome {
  if (!Number.isInteger(year) || year < 1900 || year > 2101) {
    return { ok: false, message: '연도 범위를 확인해 주세요.' };
  }
  try {
    const terms = listSolarTermsForYear(year);
    if (!terms || terms.length === 0) {
      return { ok: false, message: '해당 연도 절기 데이터가 없습니다.' };
    }
    // Ensure chronological order by timestamp
    const sorted = [...terms].sort(
      (a, b) => termTimestamp(a) - termTimestamp(b),
    );
    return {
      ok: true,
      year,
      terms: sorted,
      next: findNextTerm(sorted, now),
      current: findCurrentTerm(sorted, now),
    };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return { ok: false, message: `절기 조회에 실패했습니다. (${msg})` };
  }
}

export function daysUntilTerm(
  term: SolarTermInfo,
  now: { year: number; month: number; day: number },
): number {
  const a = Date.UTC(now.year, now.month - 1, now.day);
  const b = Date.UTC(term.year, term.month - 1, term.day);
  return Math.round((b - a) / 86400000);
}
