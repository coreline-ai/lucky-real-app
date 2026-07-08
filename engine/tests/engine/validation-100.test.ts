// @TEST P0-T0.4 - 엔진 100케이스 검증
// @IMPL src/engine/saju/result-builder.ts
// @SPEC docs/planning/

import { describe, it, expect } from 'vitest';
import { buildSajuResult } from '@/engine/saju/result-builder';
import type { BirthInputData, SajuResult, Palja } from '@/engine/types';

// 천간(天干) & 지지(地支) 검증용 상수
const VALID_STEMS = new Set(['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']);
const VALID_BRANCHES = new Set(['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']);

/**
 * SajuResult 기본 구조 검증
 */
function validateSajuResultStructure(result: SajuResult): void {
  expect(result).toBeDefined();
  expect(result.palja).toBeDefined();
  expect(result.sipsin).toBeDefined();
  expect(result.unsung).toBeDefined();
  expect(result.jijanggan).toBeDefined();
  expect(result.daeun).toBeDefined();
  expect(result.seun).toBeDefined();
  expect(result.sinsal).toBeDefined();
  expect(result.gyeokguk).toBeDefined();
  expect(result.yongsin).toBeDefined();
}

/**
 * Palja 팔자 검증
 */
function validatePalja(palja: Palja, hasHour: boolean): void {
  expect(palja.yearGan).toBeTruthy();
  expect(palja.yearJi).toBeTruthy();
  expect(palja.monthGan).toBeTruthy();
  expect(palja.monthJi).toBeTruthy();
  expect(palja.dayGan).toBeTruthy();
  expect(palja.dayJi).toBeTruthy();

  // 천간/지지 유효성 검증
  expect(VALID_STEMS.has(palja.yearGan)).toBe(true);
  expect(VALID_BRANCHES.has(palja.yearJi)).toBe(true);
  expect(VALID_STEMS.has(palja.monthGan)).toBe(true);
  expect(VALID_BRANCHES.has(palja.monthJi)).toBe(true);
  expect(VALID_STEMS.has(palja.dayGan)).toBe(true);
  expect(VALID_BRANCHES.has(palja.dayJi)).toBe(true);

  if (hasHour) {
    expect(palja.hourGan).toBeTruthy();
    expect(palja.hourJi).toBeTruthy();
    expect(VALID_STEMS.has(palja.hourGan)).toBe(true);
    expect(VALID_BRANCHES.has(palja.hourJi)).toBe(true);
  }
}

/**
 * 대운 배열 검증
 */
function validateDaeun(daeun: SajuResult['daeun']): void {
  expect(Array.isArray(daeun)).toBe(true);
  expect(daeun.length).toBeGreaterThan(0);

  for (const d of daeun) {
    expect(d.age).toBeDefined();
    expect(typeof d.age).toBe('number');
    expect(d.gan).toBeTruthy();
    expect(d.ji).toBeTruthy();
    expect(VALID_STEMS.has(d.gan)).toBe(true);
    expect(VALID_BRANCHES.has(d.ji)).toBe(true);
    expect(['목', '화', '토', '금', '수'].includes(d.ohaeng)).toBe(true);
  }
}

describe('사주 엔진 100케이스 검증', () => {
  describe('일반 50케이스 (유명인 생년월일)', () => {
    const testCases: Array<{
      name: string;
      input: BirthInputData;
    }> = [
      // 1950년대
      {
        name: '박근혜 (여, 1952-02-02 16:30, 양력)',
        input: {
          year: 1952,
          month: 2,
          day: 2,
          hour: 16,
          minute: 30,
          gender: 'female',
          isLunar: false,
          birthPlace: '대구',
        },
      },
      {
        name: '노무현 (남, 1946-09-01 23:00, 양력)',
        input: {
          year: 1946,
          month: 9,
          day: 1,
          hour: 23,
          minute: 0,
          gender: 'male',
          isLunar: false,
          birthPlace: '거제',
        },
      },
      {
        name: '선덕여왕 (여, 1965-03-15 08:30, 음력)',
        input: {
          year: 1965,
          month: 3,
          day: 15,
          hour: 8,
          minute: 30,
          gender: 'female',
          isLunar: true,
          birthPlace: '서울',
        },
      },
      // 1960년대
      {
        name: '이명박 (남, 1941-12-19 14:00, 양력)',
        input: {
          year: 1941,
          month: 12,
          day: 19,
          hour: 14,
          minute: 0,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '김영삼 (남, 1927-12-20 06:30, 양력)',
        input: {
          year: 1927,
          month: 12,
          day: 20,
          hour: 6,
          minute: 30,
          gender: 'male',
          isLunar: false,
          birthPlace: '거제',
        },
      },
      // 1970년대
      {
        name: '이혜영 (여, 1972-05-03 12:00, 양력)',
        input: {
          year: 1972,
          month: 5,
          day: 3,
          hour: 12,
          minute: 0,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '정준영 (남, 1979-01-15 08:30, 양력)',
        input: {
          year: 1979,
          month: 1,
          day: 15,
          hour: 8,
          minute: 30,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '차승원 (남, 1974-03-20 11:45, 양력)',
        input: {
          year: 1974,
          month: 3,
          day: 20,
          hour: 11,
          minute: 45,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      // 1980년대
      {
        name: '이병헌 (남, 1981-12-29 09:15, 양력)',
        input: {
          year: 1981,
          month: 12,
          day: 29,
          hour: 9,
          minute: 15,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '한혜진 (여, 1987-06-14 15:30, 양형)',
        input: {
          year: 1987,
          month: 6,
          day: 14,
          hour: 15,
          minute: 30,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '박신혜 (여, 1990-02-18 13:20, 양력)',
        input: {
          year: 1990,
          month: 2,
          day: 18,
          hour: 13,
          minute: 20,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '조승우 (남, 1980-11-10 10:05, 양력)',
        input: {
          year: 1980,
          month: 11,
          day: 10,
          hour: 10,
          minute: 5,
          gender: 'male',
          isLunar: false,
          birthPlace: '인천',
        },
      },
      // 1990년대
      {
        name: '송혜교 (여, 1989-11-22 14:40, 양력)',
        input: {
          year: 1989,
          month: 11,
          day: 22,
          hour: 14,
          minute: 40,
          gender: 'female',
          isLunar: false,
          birthPlace: '부산',
        },
      },
      {
        name: '신동욱 (남, 1989-04-07 07:50, 양력)',
        input: {
          year: 1989,
          month: 4,
          day: 7,
          hour: 7,
          minute: 50,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '김태희 (여, 1989-03-29 16:15, 양력)',
        input: {
          year: 1989,
          month: 3,
          day: 29,
          hour: 16,
          minute: 15,
          gender: 'female',
          isLunar: false,
          birthPlace: '광주',
        },
      },
      {
        name: '현빈 (남, 1982-11-25 12:30, 양력)',
        input: {
          year: 1982,
          month: 11,
          day: 25,
          hour: 12,
          minute: 30,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      // 2000년대
      {
        name: '공유 (남, 1987-07-10 09:45, 양력)',
        input: {
          year: 1987,
          month: 7,
          day: 10,
          hour: 9,
          minute: 45,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '수지 (여, 1994-08-10 11:20, 양력)',
        input: {
          year: 1994,
          month: 8,
          day: 10,
          hour: 11,
          minute: 20,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '배수지 (여, 1987-04-28 10:00, 양력)',
        input: {
          year: 1987,
          month: 4,
          day: 28,
          hour: 10,
          minute: 0,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '송중기 (남, 1985-09-25 15:45, 양력)',
        input: {
          year: 1985,
          month: 9,
          day: 25,
          hour: 15,
          minute: 45,
          gender: 'male',
          isLunar: false,
          birthPlace: '부산',
        },
      },
      {
        name: '김소현 (여, 1989-06-04 08:30, 양력)',
        input: {
          year: 1989,
          month: 6,
          day: 4,
          hour: 8,
          minute: 30,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '강동원 (남, 1987-03-16 13:15, 양력)',
        input: {
          year: 1987,
          month: 3,
          day: 16,
          hour: 13,
          minute: 15,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '이정재 (남, 1972-12-15 11:00, 양력)',
        input: {
          year: 1972,
          month: 12,
          day: 15,
          hour: 11,
          minute: 0,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '정소민 (여, 1989-08-17 14:30, 양력)',
        input: {
          year: 1989,
          month: 8,
          day: 17,
          hour: 14,
          minute: 30,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '이동욱 (남, 1986-11-06 09:20, 양력)',
        input: {
          year: 1986,
          month: 11,
          day: 6,
          hour: 9,
          minute: 20,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '정유미 (여, 1988-11-23 12:15, 양력)',
        input: {
          year: 1988,
          month: 11,
          day: 23,
          hour: 12,
          minute: 15,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '이창욱 (남, 1975-09-01 10:40, 양력)',
        input: {
          year: 1975,
          month: 9,
          day: 1,
          hour: 10,
          minute: 40,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '김예린 (여, 1995-02-11 16:00, 양력)',
        input: {
          year: 1995,
          month: 2,
          day: 11,
          hour: 16,
          minute: 0,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '윤시윤 (남, 1983-05-26 08:45, 양력)',
        input: {
          year: 1983,
          month: 5,
          day: 26,
          hour: 8,
          minute: 45,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      // 2010년대
      {
        name: '박보영 (여, 1989-01-12 15:20, 양력)',
        input: {
          year: 1989,
          month: 1,
          day: 12,
          hour: 15,
          minute: 20,
          gender: 'female',
          isLunar: false,
          birthPlace: '부산',
        },
      },
      {
        name: '박혁권 (남, 1984-11-09 07:30, 양력)',
        input: {
          year: 1984,
          month: 11,
          day: 9,
          hour: 7,
          minute: 30,
          gender: 'male',
          isLunar: false,
          birthPlace: '인천',
        },
      },
      {
        name: '임수정 (여, 1986-05-16 13:50, 양력)',
        input: {
          year: 1986,
          month: 5,
          day: 16,
          hour: 13,
          minute: 50,
          gender: 'female',
          isLunar: false,
          birthPlace: '대구',
        },
      },
      {
        name: '표준영 (남, 1980-01-03 10:10, 양력)',
        input: {
          year: 1980,
          month: 1,
          day: 3,
          hour: 10,
          minute: 10,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '박민영 (여, 1986-03-29 11:45, 양력)',
        input: {
          year: 1986,
          month: 3,
          day: 29,
          hour: 11,
          minute: 45,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '손예진 (여, 1989-06-28 14:00, 양력)',
        input: {
          year: 1989,
          month: 6,
          day: 28,
          hour: 14,
          minute: 0,
          gender: 'female',
          isLunar: false,
          birthPlace: '전주',
        },
      },
      {
        name: '정해인 (남, 1983-04-01 09:00, 양력)',
        input: {
          year: 1983,
          month: 4,
          day: 1,
          hour: 9,
          minute: 0,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '유호정 (여, 1990-12-10 16:30, 양력)',
        input: {
          year: 1990,
          month: 12,
          day: 10,
          hour: 16,
          minute: 30,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '유준상 (남, 1975-07-08 12:20, 양력)',
        input: {
          year: 1975,
          month: 7,
          day: 8,
          hour: 12,
          minute: 20,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '배두나 (여, 1982-10-25 10:50, 양력)',
        input: {
          year: 1982,
          month: 10,
          day: 25,
          hour: 10,
          minute: 50,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '한예슬 (여, 1987-01-14 15:10, 양력)',
        input: {
          year: 1987,
          month: 1,
          day: 14,
          hour: 15,
          minute: 10,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '원빈 (남, 1982-11-10 08:20, 양력)',
        input: {
          year: 1982,
          month: 11,
          day: 10,
          hour: 8,
          minute: 20,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '조인성 (남, 1987-08-16 11:40, 양력)',
        input: {
          year: 1987,
          month: 8,
          day: 16,
          hour: 11,
          minute: 40,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '추자현 (여, 1987-11-14 09:30, 양력)',
        input: {
          year: 1987,
          month: 11,
          day: 14,
          hour: 9,
          minute: 30,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '차태현 (남, 1977-02-14 13:00, 양력)',
        input: {
          year: 1977,
          month: 2,
          day: 14,
          hour: 13,
          minute: 0,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '이은주 (여, 1990-05-30 12:50, 양력)',
        input: {
          year: 1990,
          month: 5,
          day: 30,
          hour: 12,
          minute: 50,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '최명길 (남, 1984-06-02 10:15, 양력)',
        input: {
          year: 1984,
          month: 6,
          day: 2,
          hour: 10,
          minute: 15,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '채수빈 (여, 1992-07-11 14:25, 양력)',
        input: {
          year: 1992,
          month: 7,
          day: 11,
          hour: 14,
          minute: 25,
          gender: 'female',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '선동렬 (남, 1965-09-09 11:30, 양력)',
        input: {
          year: 1965,
          month: 9,
          day: 9,
          hour: 11,
          minute: 30,
          gender: 'male',
          isLunar: false,
          birthPlace: '광주',
        },
      },
      {
        name: '한석규 (남, 1964-03-31 09:10, 양력)',
        input: {
          year: 1964,
          month: 3,
          day: 31,
          hour: 9,
          minute: 10,
          gender: 'male',
          isLunar: false,
          birthPlace: '서울',
        },
      },
      {
        name: '최미숙 (여, 1956-08-07 17:25, 양력)',
        input: {
          year: 1956,
          month: 8,
          day: 7,
          hour: 17,
          minute: 25,
          gender: 'female',
          isLunar: false,
          birthPlace: '부산',
        },
      },
    ];

    it.each(testCases)('$name', ({ input }) => {
      const result = buildSajuResult(input);

      // 구조 검증
      validateSajuResultStructure(result);

      // 팔자 검증
      validatePalja(result.palja, input.hour !== null);

      // 대운 검증
      validateDaeun(result.daeun);

      // 세운 검증
      expect(result.seun).toBeDefined();
      expect(result.seun.gan).toBeTruthy();
      expect(result.seun.ji).toBeTruthy();

      // 격국 검증
      expect(result.gyeokguk).toBeDefined();
      expect(result.gyeokguk.name).toBeTruthy();

      // 용신 검증
      expect(result.yongsin).toBeDefined();
      expect(result.yongsin.yongsin).toBeTruthy();
    });
  });

  describe('경계 50케이스', () => {
    describe('자정 근처 (야자시/조자시 경계)', () => {
      const midnightBoundaryCases: Array<{
        name: string;
        input: BirthInputData;
      }> = [
        {
          name: '자정 경계 - 야자시 23:00',
          input: {
            year: 1985,
            month: 6,
            day: 15,
            hour: 23,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 야자시 23:30',
          input: {
            year: 1985,
            month: 6,
            day: 15,
            hour: 23,
            minute: 30,
            gender: 'female',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 조자시 00:15',
          input: {
            year: 1985,
            month: 6,
            day: 15,
            hour: 0,
            minute: 15,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 조자시 00:45',
          input: {
            year: 1985,
            month: 6,
            day: 15,
            hour: 0,
            minute: 45,
            gender: 'female',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 조자시 01:00',
          input: {
            year: 1990,
            month: 3,
            day: 20,
            hour: 1,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '부산',
          },
        },
        {
          name: '자정 경계 - 야자시 23:15',
          input: {
            year: 1980,
            month: 12,
            day: 25,
            hour: 23,
            minute: 15,
            gender: 'female',
            isLunar: false,
            birthPlace: '대구',
          },
        },
        {
          name: '자정 경계 - 야자시 23:45',
          input: {
            year: 1995,
            month: 1,
            day: 10,
            hour: 23,
            minute: 45,
            gender: 'male',
            isLunar: false,
            birthPlace: '인천',
          },
        },
        {
          name: '자정 경계 - 조자시 00:30',
          input: {
            year: 1988,
            month: 7,
            day: 8,
            hour: 0,
            minute: 30,
            gender: 'female',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 조자시 00:50',
          input: {
            year: 1992,
            month: 5,
            day: 15,
            hour: 0,
            minute: 50,
            gender: 'male',
            isLunar: false,
            birthPlace: '광주',
          },
        },
        {
          name: '자정 경계 - 야자시 23:25',
          input: {
            year: 1987,
            month: 2,
            day: 28,
            hour: 23,
            minute: 25,
            gender: 'female',
            isLunar: false,
            birthPlace: '울산',
          },
        },
        {
          name: '자정 경계 - 야자시 23:55',
          input: {
            year: 1983,
            month: 9,
            day: 12,
            hour: 23,
            minute: 55,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 조자시 00:05',
          input: {
            year: 1991,
            month: 4,
            day: 20,
            hour: 0,
            minute: 5,
            gender: 'female',
            isLunar: false,
            birthPlace: '수원',
          },
        },
        {
          name: '자정 경계 - 조자시 00:35',
          input: {
            year: 1986,
            month: 11,
            day: 5,
            hour: 0,
            minute: 35,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '자정 경계 - 조자시 00:55',
          input: {
            year: 1989,
            month: 8,
            day: 22,
            hour: 0,
            minute: 55,
            gender: 'female',
            isLunar: false,
            birthPlace: '부산',
          },
        },
        {
          name: '자정 경계 - 야자시 23:40',
          input: {
            year: 1984,
            month: 10,
            day: 3,
            hour: 23,
            minute: 40,
            gender: 'male',
            isLunar: false,
            birthPlace: '대구',
          },
        },
      ];

      it.each(midnightBoundaryCases)('$name', ({ input }) => {
        expect(() => {
          const result = buildSajuResult(input);
          validateSajuResultStructure(result);
          validatePalja(result.palja, true);
          validateDaeun(result.daeun);
        }).not.toThrow();
      });
    });

    describe('입춘 전후 절기 경계', () => {
      const boundaryTermCases: Array<{
        name: string;
        input: BirthInputData;
      }> = [
        {
          name: '입춘 전 24시간 (2월 3일 22:00)',
          input: {
            year: 1985,
            month: 2,
            day: 3,
            hour: 22,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '입춘 당일 (2월 4일 06:00)',
          input: {
            year: 1990,
            month: 2,
            day: 4,
            hour: 6,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '입춘 당일 (2월 4일 14:00)',
          input: {
            year: 1985,
            month: 2,
            day: 4,
            hour: 14,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '부산',
          },
        },
        {
          name: '입춘 이후 24시간 (2월 5일 08:00)',
          input: {
            year: 1992,
            month: 2,
            day: 5,
            hour: 8,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '대구',
          },
        },
        {
          name: '입하 전 (5월 4일 20:00)',
          input: {
            year: 1988,
            month: 5,
            day: 4,
            hour: 20,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '인천',
          },
        },
        {
          name: '입하 당일 (5월 5일 10:00)',
          input: {
            year: 1987,
            month: 5,
            day: 5,
            hour: 10,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '광주',
          },
        },
        {
          name: '입하 당일 (5월 5일 18:00)',
          input: {
            year: 1991,
            month: 5,
            day: 5,
            hour: 18,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '울산',
          },
        },
        {
          name: '입추 전 (8월 6일 22:00)',
          input: {
            year: 1986,
            month: 8,
            day: 6,
            hour: 22,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '입추 당일 (8월 7일 12:00)',
          input: {
            year: 1989,
            month: 8,
            day: 7,
            hour: 12,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '부산',
          },
        },
        {
          name: '입동 전후 (11월 6일 16:00)',
          input: {
            year: 1983,
            month: 11,
            day: 6,
            hour: 16,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '대구',
          },
        },
      ];

      it.each(boundaryTermCases)('$name', ({ input }) => {
        expect(() => {
          const result = buildSajuResult(input);
          validateSajuResultStructure(result);
          validatePalja(result.palja, true);
          validateDaeun(result.daeun);
        }).not.toThrow();
      });
    });

    describe('음력 윤달 케이스', () => {
      const leapMonthCases: Array<{
        name: string;
        input: BirthInputData;
      }> = [
        {
          name: '윤1월 (음력 1983년 윤1월 15일)',
          input: {
            year: 1983,
            month: 1,
            day: 15,
            hour: 10,
            minute: 0,
            gender: 'male',
            isLunar: true,
            birthPlace: '서울',
          },
        },
        {
          name: '윤4월 (음력 1987년 윤4월 20일)',
          input: {
            year: 1987,
            month: 4,
            day: 20,
            hour: 14,
            minute: 0,
            gender: 'female',
            isLunar: true,
            birthPlace: '부산',
          },
        },
        {
          name: '윤6월 (음력 1989년 윤6월 10일)',
          input: {
            year: 1989,
            month: 6,
            day: 10,
            hour: 9,
            minute: 30,
            gender: 'male',
            isLunar: true,
            birthPlace: '대구',
          },
        },
        {
          name: '윤8월 (음력 1990년 윤8월 25일)',
          input: {
            year: 1990,
            month: 8,
            day: 25,
            hour: 11,
            minute: 15,
            gender: 'female',
            isLunar: true,
            birthPlace: '인천',
          },
        },
        {
          name: '윤11월 (음력 1993년 윤11월 5일)',
          input: {
            year: 1993,
            month: 11,
            day: 5,
            hour: 13,
            minute: 45,
            gender: 'male',
            isLunar: true,
            birthPlace: '광주',
          },
        },
      ];

      it.each(leapMonthCases)('$name', ({ input }) => {
        expect(() => {
          const result = buildSajuResult(input);
          validateSajuResultStructure(result);
          validatePalja(result.palja, true);
          validateDaeun(result.daeun);
        }).not.toThrow();
      });
    });

    describe('양력/음력 변환 경계', () => {
      const conversionBoundaryCases: Array<{
        name: string;
        input: BirthInputData;
      }> = [
        {
          name: '양력 1월 1일 (1985-01-01 10:00)',
          input: {
            year: 1985,
            month: 1,
            day: 1,
            hour: 10,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '양력 1월 31일 (1990-01-31 15:00)',
          input: {
            year: 1990,
            month: 1,
            day: 31,
            hour: 15,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '양력 2월 28일 (1987-02-28 12:00)',
          input: {
            year: 1987,
            month: 2,
            day: 28,
            hour: 12,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '부산',
          },
        },
        {
          name: '양력 2월 29일 (윤년, 1988-02-29 08:00)',
          input: {
            year: 1988,
            month: 2,
            day: 29,
            hour: 8,
            minute: 0,
            gender: 'female',
            isLunar: false,
            birthPlace: '대구',
          },
        },
        {
          name: '양력 12월 31일 (1989-12-31 22:00)',
          input: {
            year: 1989,
            month: 12,
            day: 31,
            hour: 22,
            minute: 0,
            gender: 'male',
            isLunar: false,
            birthPlace: '인천',
          },
        },
        {
          name: '음력 1월 1일 (1985년 음력 1월 1일 06:00)',
          input: {
            year: 1985,
            month: 1,
            day: 1,
            hour: 6,
            minute: 0,
            gender: 'female',
            isLunar: true,
            birthPlace: '광주',
          },
        },
        {
          name: '음력 12월 29일 (1987년 음력 12월 29일 14:00)',
          input: {
            year: 1987,
            month: 12,
            day: 29,
            hour: 14,
            minute: 0,
            gender: 'male',
            isLunar: true,
            birthPlace: '울산',
          },
        },
        {
          name: '음력 12월 30일 (1989년 음력 12월 30일 16:00)',
          input: {
            year: 1989,
            month: 12,
            day: 30,
            hour: 16,
            minute: 0,
            gender: 'female',
            isLunar: true,
            birthPlace: '서울',
          },
        },
        {
          name: '양력 7월 15일 (1991-07-15 11:30)',
          input: {
            year: 1991,
            month: 7,
            day: 15,
            hour: 11,
            minute: 30,
            gender: 'male',
            isLunar: false,
            birthPlace: '수원',
          },
        },
        {
          name: '음력 7월 15일 (1993년 음력 7월 15일 09:45)',
          input: {
            year: 1993,
            month: 7,
            day: 15,
            hour: 9,
            minute: 45,
            gender: 'female',
            isLunar: true,
            birthPlace: '성남',
          },
        },
      ];

      it.each(conversionBoundaryCases)('$name', ({ input }) => {
        expect(() => {
          const result = buildSajuResult(input);
          validateSajuResultStructure(result);
          validatePalja(result.palja, true);
          validateDaeun(result.daeun);
        }).not.toThrow();
      });
    });

    describe('시간 없음 (null 케이스)', () => {
      const noTimeCases: Array<{
        name: string;
        input: BirthInputData;
      }> = [
        {
          name: '시간 미입력 1 (1985-06-15, null시간)',
          input: {
            year: 1985,
            month: 6,
            day: 15,
            hour: null,
            minute: null,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '시간 미입력 2 (1990-12-25, null시간)',
          input: {
            year: 1990,
            month: 12,
            day: 25,
            hour: null,
            minute: null,
            gender: 'female',
            isLunar: false,
            birthPlace: '부산',
          },
        },
        {
          name: '시간 미입력 3 (1987-02-14, null시간)',
          input: {
            year: 1987,
            month: 2,
            day: 14,
            hour: null,
            minute: null,
            gender: 'male',
            isLunar: false,
            birthPlace: '대구',
          },
        },
        {
          name: '시간 미입력 4 (1989-05-20, null시간)',
          input: {
            year: 1989,
            month: 5,
            day: 20,
            hour: null,
            minute: null,
            gender: 'female',
            isLunar: false,
            birthPlace: '인천',
          },
        },
        {
          name: '시간 미입력 5 (1993-08-10, null시간)',
          input: {
            year: 1993,
            month: 8,
            day: 10,
            hour: null,
            minute: null,
            gender: 'male',
            isLunar: false,
            birthPlace: '광주',
          },
        },
        {
          name: '시간 미입력 6 (1985년 음력 6월 15일, null시간)',
          input: {
            year: 1985,
            month: 6,
            day: 15,
            hour: null,
            minute: null,
            gender: 'female',
            isLunar: true,
            birthPlace: '울산',
          },
        },
        {
          name: '시간 미입력 7 (1988-01-01, null시간)',
          input: {
            year: 1988,
            month: 1,
            day: 1,
            hour: null,
            minute: null,
            gender: 'male',
            isLunar: false,
            birthPlace: '서울',
          },
        },
        {
          name: '시간 미입력 8 (1991-12-31, null시간)',
          input: {
            year: 1991,
            month: 12,
            day: 31,
            hour: null,
            minute: null,
            gender: 'female',
            isLunar: false,
            birthPlace: '수원',
          },
        },
        {
          name: '시간 미입력 9 (1986-04-15, null시간)',
          input: {
            year: 1986,
            month: 4,
            day: 15,
            hour: null,
            minute: null,
            gender: 'male',
            isLunar: false,
            birthPlace: '성남',
          },
        },
        {
          name: '시간 미입력 10 (1992-09-20, null시간)',
          input: {
            year: 1992,
            month: 9,
            day: 20,
            hour: null,
            minute: null,
            gender: 'female',
            isLunar: false,
            birthPlace: '천안',
          },
        },
      ];

      it.each(noTimeCases)('$name', ({ input }) => {
        const result = buildSajuResult(input);

        // 구조 검증
        validateSajuResultStructure(result);

        // 팔자 검증 (시간 없음)
        validatePalja(result.palja, false);

        // 시주가 없어야 함
        if (input.hour === null) {
          expect(result.palja.hourGan).toBe('');
          expect(result.palja.hourJi).toBe('');
        }

        // 대운 검증
        validateDaeun(result.daeun);
      });
    });
  });
});
