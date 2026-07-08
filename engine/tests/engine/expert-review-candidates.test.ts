import { describe, expect, it } from 'vitest';
import candidateData from '../fixtures/expert-review-candidates.json';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import { calculatePalja, type CalculateOptions } from '@/engine/saju/calculator';
import type { BirthInputData, Gender, Palja } from '@/engine/types';

interface ExpertReviewCandidate {
  id: string;
  reviewFocus: string[];
  input: {
    calendar: 'solar' | 'lunar';
    year: number;
    month: number;
    day: number;
    isLeapMonth?: boolean;
    hour: number;
    minute: number;
    gender: Gender;
    birthPlace: string;
  };
  calculateOptions: Required<CalculateOptions>;
  derived: {
    solar: string;
    yearPillar: string;
    monthPillar: string;
    dayPillar: string;
    hourPillar: string;
  };
}

const candidates = candidateData.cases as ExpertReviewCandidate[];
const PILLAR_PATTERN = /^[甲乙丙丁戊己庚辛壬癸][子丑寅卯辰巳午未申酉戌亥]$/;

function formatDate(year: number, month: number, day: number): string {
  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

function toBirthInput(candidate: ExpertReviewCandidate): BirthInputData {
  return {
    year: candidate.input.year,
    month: candidate.input.month,
    day: candidate.input.day,
    hour: candidate.input.hour,
    minute: candidate.input.minute,
    gender: candidate.input.gender,
    isLunar: candidate.input.calendar === 'lunar',
    isLeapMonth: candidate.input.calendar === 'lunar' ? candidate.input.isLeapMonth ?? false : false,
    birthPlace: candidate.input.birthPlace,
  };
}

function toPillarStrings(palja: Palja) {
  return {
    yearPillar: `${palja.yearGan}${palja.yearJi}`,
    monthPillar: `${palja.monthGan}${palja.monthJi}`,
    dayPillar: `${palja.dayGan}${palja.dayJi}`,
    hourPillar: palja.hourGan && palja.hourJi ? `${palja.hourGan}${palja.hourJi}` : '',
  };
}

function toSolarDate(candidate: ExpertReviewCandidate): string {
  if (candidate.input.calendar === 'solar') {
    return formatDate(candidate.input.year, candidate.input.month, candidate.input.day);
  }

  const solar = ManseryeokEngine.lunarToSolar({
    year: candidate.input.year,
    month: candidate.input.month,
    day: candidate.input.day,
    isLeapMonth: candidate.input.isLeapMonth ?? false,
  });

  return formatDate(solar.year, solar.month, solar.day);
}

describe('전문가 검수 후보 fixture', () => {
  it('상용 검수에 필요한 경계 케이스 10건을 제공한다', () => {
    expect(candidateData.status).toBe('candidate-only');
    expect(candidates).toHaveLength(10);
    expect(new Set(candidates.map((candidate) => candidate.id)).size).toBe(candidates.length);

    const focus = new Set(candidates.flatMap((candidate) => candidate.reviewFocus));
    for (const required of [
      'ipchun-boundary',
      'month-solar-term-boundary',
      'yaja',
      'joja',
      'lunar-calendar',
      'leap-month',
      'true-solar-time',
      'longitude',
    ]) {
      expect(focus.has(required), `missing review focus: ${required}`).toBe(true);
    }
  });

  it.each(candidates)('$id - 후보 산출값이 현재 엔진 계산과 일치한다', (candidate) => {
    const palja = calculatePalja(toBirthInput(candidate), candidate.calculateOptions);
    const actual = {
      solar: toSolarDate(candidate),
      ...toPillarStrings(palja),
    };

    expect(actual).toEqual(candidate.derived);

    for (const pillar of [
      candidate.derived.yearPillar,
      candidate.derived.monthPillar,
      candidate.derived.dayPillar,
      candidate.derived.hourPillar,
    ]) {
      expect(pillar).toMatch(PILLAR_PATTERN);
    }
  });
});
