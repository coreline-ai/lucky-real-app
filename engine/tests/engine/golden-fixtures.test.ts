import { describe, expect, it } from 'vitest';
import fixtureData from '../fixtures/manseryeok-golden.json';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import { calculatePalja } from '@/engine/saju/calculator';
import type { BirthInputData, Gender, Palja } from '@/engine/types';

interface GoldenCase {
  id: string;
  input: {
    calendar: 'solar' | 'lunar';
    year: number;
    month: number;
    day: number;
    isLeapMonth?: boolean;
    hour: number | null;
    minute: number | null;
    gender: Gender;
  };
  expected: Partial<{
    solar: string;
    yearPillar: string;
    monthPillar: string;
    dayPillar: string;
    hourPillar: string;
  }>;
}

function formatDate(year: number, month: number, day: number): string {
  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

function toBirthInput(testCase: GoldenCase): BirthInputData {
  return {
    year: testCase.input.year,
    month: testCase.input.month,
    day: testCase.input.day,
    hour: testCase.input.hour,
    minute: testCase.input.minute,
    gender: testCase.input.gender,
    isLunar: testCase.input.calendar === 'lunar',
    isLeapMonth: testCase.input.calendar === 'lunar' ? testCase.input.isLeapMonth ?? false : false,
    birthPlace: null,
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

const cases = fixtureData.cases as GoldenCase[];

describe('만세력 golden fixture 검증', () => {
  it.each(cases)('$id', (testCase) => {
    const palja = calculatePalja(toBirthInput(testCase));
    const actual = toPillarStrings(palja);

    if (testCase.expected.solar) {
      const solar = testCase.input.calendar === 'lunar'
        ? ManseryeokEngine.lunarToSolar({
            year: testCase.input.year,
            month: testCase.input.month,
            day: testCase.input.day,
            isLeapMonth: testCase.input.isLeapMonth ?? false,
          })
        : testCase.input;

      expect(formatDate(solar.year, solar.month, solar.day)).toBe(testCase.expected.solar);
    }

    for (const key of ['yearPillar', 'monthPillar', 'dayPillar', 'hourPillar'] as const) {
      if (testCase.expected[key]) {
        expect(actual[key], `${testCase.id} ${key}`).toBe(testCase.expected[key]);
      }
    }
  });
});
