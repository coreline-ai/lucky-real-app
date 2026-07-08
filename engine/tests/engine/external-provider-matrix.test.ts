import { describe, expect, it } from 'vitest';
import { calculateFourPillars } from 'manseryeok';
import { calculatePalja } from '@/engine/saju/calculator';
import type { BirthInputData, Gender, Palja } from '@/engine/types';

interface MatrixCase {
  id: string;
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  gender?: Gender;
}

const matrixCases: MatrixCase[] = [
  { id: 'lower-bound-1908-04-01', year: 1908, month: 4, day: 1, hour: 0, minute: 0 },
  { id: 'lunar-leap-solar-date-1911-07-26', year: 1911, month: 7, day: 26, hour: 10, minute: 30 },
  { id: 'ipchun-before-1984-02-02', year: 1984, month: 2, day: 2, hour: 2, minute: 0 },
  { id: 'ipchun-day-before-term-1984-02-04-0500', year: 1984, month: 2, day: 4, hour: 5, minute: 0 },
  { id: 'ipchun-before-2024-02-04-0450', year: 2024, month: 2, day: 4, hour: 4, minute: 50 },
  { id: 'ipchun-after-2024-02-04-0510', year: 2024, month: 2, day: 4, hour: 5, minute: 10 },
  { id: 'ipchun-before-2024-02-04-1720', year: 2024, month: 2, day: 4, hour: 17, minute: 20 },
  { id: 'ipchun-after-2024-02-04-1735', year: 2024, month: 2, day: 4, hour: 17, minute: 35 },
  { id: 'gyeongchip-before-2024-03-05-1120', year: 2024, month: 3, day: 5, hour: 11, minute: 20 },
  { id: 'gyeongchip-after-2024-03-05-1135', year: 2024, month: 3, day: 5, hour: 11, minute: 35 },
  { id: 'midnight-2024-03-10-2259', year: 2024, month: 3, day: 10, hour: 22, minute: 59 },
  { id: 'jasi-2024-03-10-2300', year: 2024, month: 3, day: 10, hour: 23, minute: 0 },
  { id: 'jasi-2024-03-10-2330', year: 2024, month: 3, day: 10, hour: 23, minute: 30 },
  { id: 'jasi-2024-03-11-0030', year: 2024, month: 3, day: 11, hour: 0, minute: 30 },
  { id: 'hour-boundary-2024-03-11-0100', year: 2024, month: 3, day: 11, hour: 1, minute: 0 },
  { id: 'leap-day-1988-02-29', year: 1988, month: 2, day: 29, hour: 8, minute: 0 },
  { id: 'year-end-1989-12-31', year: 1989, month: 12, day: 31, hour: 22, minute: 0 },
  { id: 'summer-1990-05-15', year: 1990, month: 5, day: 15, hour: 14, minute: 30 },
  { id: 'readme-1992-10-24', year: 1992, month: 10, day: 24, hour: 5, minute: 30 },
  { id: 'modern-2000-01-01', year: 2000, month: 1, day: 1, hour: 12, minute: 0 },
  { id: 'modern-2002-06-30', year: 2002, month: 6, day: 30, hour: 23, minute: 45 },
  { id: 'modern-2010-02-04', year: 2010, month: 2, day: 4, hour: 7, minute: 0 },
  { id: 'modern-2016-02-29', year: 2016, month: 2, day: 29, hour: 16, minute: 15 },
  { id: 'modern-2020-05-23', year: 2020, month: 5, day: 23, hour: 9, minute: 30 },
  { id: 'current-range-2026-02-17', year: 2026, month: 2, day: 17, hour: 6, minute: 0 },
  { id: 'future-2030-12-31', year: 2030, month: 12, day: 31, hour: 23, minute: 0 },
  { id: 'fullstack-upper-bound-2050-12-31', year: 2050, month: 12, day: 31, hour: 22, minute: 0 },
  { id: 'our-upper-bound-2101-12-31', year: 2101, month: 12, day: 31, hour: 23, minute: 0 },
];

function toPillarStrings(palja: Palja) {
  return {
    yearPillar: `${palja.yearGan}${palja.yearJi}`,
    monthPillar: `${palja.monthGan}${palja.monthJi}`,
    dayPillar: `${palja.dayGan}${palja.dayJi}`,
    hourPillar: `${palja.hourGan}${palja.hourJi}`,
  };
}

function calculateOurs(testCase: MatrixCase) {
  const input: BirthInputData = {
    year: testCase.year,
    month: testCase.month,
    day: testCase.day,
    hour: testCase.hour,
    minute: testCase.minute,
    gender: testCase.gender ?? 'male',
    isLunar: false,
    birthPlace: null,
  };

  return toPillarStrings(calculatePalja(input));
}

function calculateProvider(testCase: MatrixCase) {
  const result = calculateFourPillars({
    year: testCase.year,
    month: testCase.month,
    day: testCase.day,
    hour: testCase.hour,
    minute: testCase.minute,
    gender: testCase.gender ?? 'male',
    dayBoundary: 'splitJasi',
  });
  const hanja = result.toHanjaObject();

  return {
    yearPillar: hanja.year.hanja,
    monthPillar: hanja.month.hanja,
    dayPillar: hanja.day.hanja,
    hourPillar: hanja.hour.hanja,
  };
}

describe('외부 provider 경계값 매트릭스 교차검증', () => {
  it.each(matrixCases)('$id', (testCase) => {
    expect(calculateOurs(testCase)).toEqual(calculateProvider(testCase));
  });
});
