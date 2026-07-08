import { describe, expect, it } from 'vitest';
import { ManseryeokPolicyError } from '@/engine/core/errors';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import { calculatePalja } from '@/engine/saju/calculator';
import type { BirthInputData, Palja } from '@/engine/types';

function pillarStrings(palja: Palja) {
  return {
    year: `${palja.yearGan}${palja.yearJi}`,
    month: `${palja.monthGan}${palja.monthJi}`,
    day: `${palja.dayGan}${palja.dayJi}`,
    hour: `${palja.hourGan}${palja.hourJi}`,
  };
}

describe('palja normalized manseryeok context', () => {
  it('converts lunar input to solar civil datetime before true-solar correction', () => {
    const input: BirthInputData = {
      year: 2000,
      month: 2,
      day: 4,
      hour: 10,
      minute: 0,
      gender: 'male',
      isLunar: true,
      isLeapMonth: false,
      birthPlace: null,
    };

    expect(pillarStrings(calculatePalja(input, { trueSolarTime: true, longitude: 127.0 }))).toEqual({
      year: '庚辰',
      month: '己卯',
      day: '丙寅',
      hour: '癸巳',
    });
  });

  it('uses timestamp-aware true-solar terms at the 2024-03-05 month boundary', () => {
    const input: BirthInputData = {
      year: 2024,
      month: 3,
      day: 5,
      hour: 11,
      minute: 35,
      gender: 'male',
      isLunar: false,
      birthPlace: null,
    };

    expect(pillarStrings(calculatePalja(input, { trueSolarTime: false })).month).toBe('丁卯');
    expect(pillarStrings(calculatePalja(input, { trueSolarTime: true, longitude: 127.0 })).month).toBe('丙寅');
  });

  it('preserves accepted yaja and joja 23:30 candidate pillars', () => {
    const input: BirthInputData = {
      year: 2024,
      month: 3,
      day: 10,
      hour: 23,
      minute: 30,
      gender: 'female',
      isLunar: false,
      birthPlace: null,
    };

    expect(pillarStrings(calculatePalja(input, { midnightMode: 'yaja' }))).toMatchObject({
      day: '癸酉',
      hour: '甲子',
    });
    expect(pillarStrings(calculatePalja(input, { midnightMode: 'joja' }))).toMatchObject({
      day: '甲戌',
      hour: '甲子',
    });
  });

  it('evaluates joja school from corrected true-solar time when correction leaves zi hour', () => {
    const input: BirthInputData = {
      year: 2024,
      month: 3,
      day: 10,
      hour: 23,
      minute: 30,
      gender: 'female',
      isLunar: false,
      birthPlace: null,
    };

    expect(pillarStrings(calculatePalja(input, { trueSolarTime: false, midnightMode: 'joja' }))).toMatchObject({
      day: '甲戌',
      hour: '甲子',
    });
    expect(pillarStrings(calculatePalja(input, {
      trueSolarTime: true,
      longitude: 120.0,
      midnightMode: 'joja',
    }))).toMatchObject({
      day: '癸酉',
      hour: '癸亥',
    });
  });

  it('routes ManseryeokEngine palja lunar facade through the normalized lunar conversion path', () => {
    const input: BirthInputData = {
      year: 2000,
      month: 2,
      day: 4,
      hour: 10,
      minute: 0,
      gender: 'male',
      isLunar: true,
      isLeapMonth: false,
      birthPlace: null,
    };

    expect(ManseryeokEngine.getPaljaFromLunarInput({
      year: input.year,
      month: input.month,
      day: input.day,
      hour: input.hour ?? undefined,
      minute: input.minute ?? undefined,
      isLeapMonth: input.isLeapMonth,
    })).toEqual(calculatePalja(input, { trueSolarTime: false }));
  });

  it('forwards explicit pre-applied day/hour school context through palja facades', () => {
    const palja = ManseryeokEngine.getPaljaFromSolarInput({
      year: 2024,
      month: 3,
      day: 10,
      hour: 23,
      minute: 30,
      sect: 1,
      dayHourDateTime: {
        year: 2024,
        month: 3,
        day: 11,
        hour: 23,
        minute: 30,
        second: 0,
      },
      dayHourDateTimeSchoolApplied: true,
    });

    expect(pillarStrings(palja)).toMatchObject({
      day: '甲戌',
      hour: '甲子',
    });
  });

  it('applies the legal lower bound after lunar-to-solar normalization', () => {
    expect(() => calculatePalja({
      year: 1908,
      month: 3,
      day: 1,
      hour: 10,
      minute: 0,
      gender: 'male',
      isLunar: true,
      isLeapMonth: false,
      birthPlace: null,
    })).not.toThrow();

    expect(() => calculatePalja({
      year: 1908,
      month: 3,
      day: 31,
      hour: 10,
      minute: 0,
      gender: 'male',
      isLunar: false,
      birthPlace: null,
    })).toThrow(ManseryeokPolicyError);
  });
});
