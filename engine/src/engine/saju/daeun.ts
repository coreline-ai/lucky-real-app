// @TASK P2-R3-T3 - 대운/세운/월운 계산
// @SPEC docs/planning/02-trd.md#대운-세운-월운
// @TEST tests/engine/daeun.test.ts

import type { BirthInputData, Daeun, Ohaeng, Palja } from '../types';
import type { CalculateOptions } from './calculator';
import { CHEONGAN, JIJI, getOhaengForGan } from '../adapter/hanja-mapper';
import { ManseryeokEngine } from '../core/manseryeok-engine';
import { createNormalizedManseryeokContext } from '../core/normalized-context';
import { getGanji } from '../core/ganji';
import type { DateTimeParts } from '../core/temporal';

/** 60갑자(甲子) 순서 배열 - 천간 10 x 지지 12 조합 */
const SEXAGENARY_CYCLE: readonly { gan: string; ji: string }[] = (() => {
  const result: { gan: string; ji: string }[] = [];
  for (let i = 0; i < 60; i++) {
    result.push({
      gan: CHEONGAN[i % 10],
      ji: JIJI[i % 12],
    });
  }
  return result;
})();

function findSexagenaryIndex(gan: string, ji: string): number {
  return SEXAGENARY_CYCLE.findIndex((item) => item.gan === gan && item.ji === ji);
}

function isYangGan(gan: string): boolean {
  const idx = CHEONGAN.indexOf(gan);
  return idx >= 0 && idx % 2 === 0;
}

function isForward(gender: 'male' | 'female', yearGan: string): boolean {
  const yang = isYangGan(yearGan);
  if (gender === 'male') return yang;
  return !yang;
}

interface YunAgeResolution {
  startAge: number;
  startAgeMonths: number;
  birthYear: number;
}

function toKstDateTimeParts(date: Date): DateTimeParts {
  const kst = new Date(date.getTime() + 9 * 60 * 60 * 1000);

  return {
    year: kst.getUTCFullYear(),
    month: kst.getUTCMonth() + 1,
    day: kst.getUTCDate(),
    hour: kst.getUTCHours(),
    minute: kst.getUTCMinutes(),
    second: kst.getUTCSeconds(),
  };
}

export function calculateYunStartAge(
  birthInput: BirthInputData,
  options?: Pick<CalculateOptions, 'trueSolarTime' | 'longitude' | 'midnightMode'>,
): number {
  const context = createNormalizedManseryeokContext(birthInput, options);
  const yearGan = ManseryeokEngine.getGanjiFromContext(context).year.gan;

  return ManseryeokEngine.getYunStartAgeResolutionFromContext(
    context,
    birthInput.gender,
    yearGan,
  ).startAge;
}

export function calculateDaeun(
  palja: Palja,
  birthInput: BirthInputData,
  count = 8,
  options?: Pick<CalculateOptions, 'trueSolarTime' | 'longitude' | 'midnightMode'>,
): Daeun[] {
  const resolution = resolveYunAgeResolution(palja, birthInput, options);
  const forward = isForward(birthInput.gender, palja.yearGan);
  const monthIdx = findSexagenaryIndex(palja.monthGan, palja.monthJi);

  if (monthIdx < 0) {
    throw new Error(`Invalid monthGan/monthJi: ${palja.monthGan}${palja.monthJi}`);
  }

  const currentYear = new Date().getFullYear();
  const currentAge = currentYear - resolution.birthYear;

  const result: Daeun[] = [];
  for (let i = 0; i < count; i++) {
    const age = resolution.startAge + i * 10;
    const offset = forward ? i + 1 : -(i + 1);
    const idx = ((monthIdx + offset) % 60 + 60) % 60;
    const { gan, ji } = SEXAGENARY_CYCLE[idx];
    const ohaeng = getOhaengForGan(gan) as Ohaeng;
    const currentStartAge = resolution.startAge + i * 10;
    const nextAge = currentStartAge + 10;
    const isCurrent = currentAge >= currentStartAge && currentAge < nextAge;

    result.push({
      age,
      gan,
      ji,
      ohaeng,
      isCurrent,
      startAgeMonths: resolution.startAgeMonths + i * 120,
    });
  }

  return result;
}

export function calculateSeun(currentYear: number): { gan: string; ji: string };
export function calculateSeun(targetDateTime: Date): { gan: string; ji: string };
export function calculateSeun(target: number | Date): { gan: string; ji: string } {
  if (typeof target === 'number') {
    const idx = ((target - 4) % 60 + 60) % 60;
    return {
      gan: SEXAGENARY_CYCLE[idx].gan,
      ji: SEXAGENARY_CYCLE[idx].ji,
    };
  }

  const pillar = getGanji(toKstDateTimeParts(target)).year;
  return {
    gan: pillar.gan,
    ji: pillar.ji,
  };
}

export function calculateWolun(
  currentYear: number,
  currentMonth: number
): { gan: string; ji: string };
export function calculateWolun(targetDateTime: Date): { gan: string; ji: string };
export function calculateWolun(
  target: number | Date,
  currentMonth?: number
): { gan: string; ji: string } {
  if (target instanceof Date) {
    const pillar = getGanji(toKstDateTimeParts(target)).month;
    return {
      gan: pillar.gan,
      ji: pillar.ji,
    };
  }

  if (currentMonth === undefined) {
    throw new Error('calculateWolun(currentYear, currentMonth) requires currentMonth');
  }

  const monthPillar = ManseryeokEngine.getLunarMonthGanJi(target, currentMonth, 15);

  return {
    gan: monthPillar.gan,
    ji: monthPillar.ji,
  };
}

function resolveYunAgeResolution(
  palja: Pick<Palja, 'yearGan'>,
  birthInput: BirthInputData,
  options?: Pick<CalculateOptions, 'trueSolarTime' | 'longitude' | 'midnightMode'>,
): YunAgeResolution {
  const context = createNormalizedManseryeokContext(birthInput, options);
  const resolution = ManseryeokEngine.getYunStartAgeResolutionFromContext(
    context,
    birthInput.gender,
    palja.yearGan,
  );

  return {
    startAge: resolution.startAge,
    startAgeMonths: resolution.startAgeMonths,
    birthYear: context.solarCivilDateTime.year,
  };
}
