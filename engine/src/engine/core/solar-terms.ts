import solarTermsByYear from './data/solar-terms.generated.json';
import {
  normalizeSolarTermToKst,
  type SolarTermInfo,
} from './solar-term-normalization';
import type { DateTimeParts } from './temporal';
import { toKstTimestamp } from './temporal';

export {
  normalizeSolarTermName,
  normalizeSolarTermToKst,
  type SolarTermInfo,
} from './solar-term-normalization';

const SOLAR_TERMS = solarTermsByYear as Record<string, SolarTermInfo[]>;
const normalizedSolarTermsByYear = new Map<number, readonly Readonly<SolarTermInfo>[]>();

export const JEOL_SOLAR_TERM_NAMES = [
  '소한',
  '입춘',
  '경칩',
  '청명',
  '입하',
  '망종',
  '소서',
  '입추',
  '백로',
  '한로',
  '입동',
  '대설',
] as const;

export type JeolSolarTermName = typeof JEOL_SOLAR_TERM_NAMES[number];

const INTERNAL_JEOL_SOLAR_TERM_NAME_SET = new Set<string>(JEOL_SOLAR_TERM_NAMES);

export const JEOL_SOLAR_TERM_NAME_SET: ReadonlySet<string> = new Set(INTERNAL_JEOL_SOLAR_TERM_NAME_SET);

function toJulianDay(year: number, month: number, day: number): number {
  const a = Math.floor((14 - month) / 12);
  const y = year + 4800 - a;
  const m = month + 12 * a - 3;

  return (
    day +
    Math.floor((153 * m + 2) / 5) +
    365 * y +
    Math.floor(y / 4) -
    Math.floor(y / 100) +
    Math.floor(y / 400) -
    32045 -
    0.5
  );
}

function cloneSolarTerm(term: Readonly<SolarTermInfo>): SolarTermInfo {
  return { ...term };
}

function getCachedSolarTermsForYear(year: number): readonly Readonly<SolarTermInfo>[] {
  const cached = normalizedSolarTermsByYear.get(year);
  if (cached) {
    return cached;
  }

  const normalized = (SOLAR_TERMS[String(year)] ?? [])
    .map(normalizeSolarTermToKst)
    .map((term) => Object.freeze(term));
  normalizedSolarTermsByYear.set(year, normalized);
  return normalized;
}

function solarTermTimestamp(term: Readonly<SolarTermInfo>): number {
  return toKstTimestamp({
    year: term.year,
    month: term.month,
    day: term.day,
    hour: term.hour,
    minute: term.minute,
    second: term.second,
  });
}

export function isJeolSolarTerm(term: Pick<SolarTermInfo, 'koreanName'> | string): boolean {
  return INTERNAL_JEOL_SOLAR_TERM_NAME_SET.has(typeof term === 'string' ? term : term.koreanName);
}

export function listSolarTermsForYear(year: number): SolarTermInfo[] {
  return getCachedSolarTermsForYear(year).map(cloneSolarTerm);
}

export function getSolarTermsOnDate(year: number, month: number, day: number): SolarTermInfo[] {
  return [
    ...getCachedSolarTermsForYear(year - 1),
    ...getCachedSolarTermsForYear(year),
    ...getCachedSolarTermsForYear(year + 1),
  ]
    .filter((term) => term.year === year && term.month === month && term.day === day)
    .map(cloneSolarTerm);
}

export function getSolarTermOnOrBeforeDateTime(dateTime: DateTimeParts): SolarTermInfo {
  const target = toKstTimestamp(dateTime);
  const candidates = [
    ...getCachedSolarTermsForYear(dateTime.year - 1),
    ...getCachedSolarTermsForYear(dateTime.year),
    ...getCachedSolarTermsForYear(dateTime.year + 1),
  ];

  let best: Readonly<SolarTermInfo> | null = null;
  for (const term of candidates) {
    const termTimestamp = solarTermTimestamp(term);
    if (termTimestamp <= target && (!best || termTimestamp > solarTermTimestamp(best))) {
      best = term;
    }
  }

  if (!best) {
    throw new Error(`No solar term found for ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}`);
  }

  return cloneSolarTerm(best);
}

export function getJeolOnOrBeforeDateTime(dateTime: DateTimeParts): SolarTermInfo {
  const target = toKstTimestamp(dateTime);
  const candidates = [
    ...getCachedSolarTermsForYear(dateTime.year - 1),
    ...getCachedSolarTermsForYear(dateTime.year),
    ...getCachedSolarTermsForYear(dateTime.year + 1),
  ].filter(isJeolSolarTerm);

  let best: Readonly<SolarTermInfo> | null = null;
  for (const term of candidates) {
    const termTimestamp = solarTermTimestamp(term);
    if (termTimestamp <= target && (!best || termTimestamp > solarTermTimestamp(best))) {
      best = term;
    }
  }

  if (!best) {
    throw new Error(`No jeol solar term found for ${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}`);
  }

  return cloneSolarTerm(best);
}

export function getSolarTermOnOrBefore(date: string): SolarTermInfo {
  const [year, month, day] = date.split('-').map(Number);
  const target = toJulianDay(year, month, day);
  const candidates = [...listSolarTermsForYear(year - 1), ...listSolarTermsForYear(year)];

  let best: SolarTermInfo | null = null;
  for (const term of candidates) {
    if (term.julianDay <= target && (!best || term.julianDay > best.julianDay)) {
      best = term;
    }
  }

  if (!best) {
    throw new Error(`No solar term found for ${date}`);
  }

  return best;
}
