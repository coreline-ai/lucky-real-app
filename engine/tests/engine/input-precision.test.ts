import { describe, expect, it } from 'vitest';
import { correctToTrueSolarTime } from '@/engine/adapter/time-corrector';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import { calculatePalja } from '@/engine/saju/calculator';
import type { BirthInputData } from '@/engine/types';

describe('전문가용 입력 정밀도 회귀 테스트', () => {
  it('음력 윤달과 평달을 서로 다른 양력 날짜로 변환한다', () => {
    expect(ManseryeokEngine.lunarToSolar({
      year: 1900,
      month: 8,
      day: 1,
      isLeapMonth: false,
    })).toMatchObject({ year: 1900, month: 8, day: 25 });

    expect(ManseryeokEngine.lunarToSolar({
      year: 1900,
      month: 8,
      day: 1,
      isLeapMonth: true,
    })).toMatchObject({ year: 1900, month: 9, day: 24 });
  });

  it('사주 계산에 음력 윤달 플래그를 반영한다', () => {
    const base: BirthInputData = {
      year: 1911,
      month: 6,
      day: 8,
      hour: 10,
      minute: 30,
      gender: 'male',
      isLunar: true,
      birthPlace: null,
    };

    const normalMonth = calculatePalja({ ...base, isLeapMonth: false });
    const leapMonth = calculatePalja({ ...base, isLeapMonth: true });

    expect(leapMonth).not.toEqual(normalMonth);
  });

  it('대운 시작 나이 회귀는 1900년 원시 음력 변환값에 고정하지 않는다', () => {
    const normalMonth = ManseryeokEngine.lunarToSolar({
      year: 1900,
      month: 8,
      day: 8,
      isLeapMonth: false,
      hour: 10,
      minute: 30,
    });
    const leapMonth = ManseryeokEngine.lunarToSolar({
      year: 1900,
      month: 8,
      day: 8,
      isLeapMonth: true,
      hour: 10,
      minute: 30,
    });

    expect(normalMonth).not.toMatchObject({
      year: leapMonth.year,
      month: leapMonth.month,
      day: leapMonth.day,
    });
  });

  it('진태양시 보정에서 반올림 후 60분 값을 만들지 않는다', () => {
    const corrected = correctToTrueSolarTime(
      { year: 2024, month: 1, day: 1, hour: 1, minute: 59 },
      136.076294580849,
    );

    expect(corrected.hour).toBe(2);
    expect(corrected.minute).toBe(0);
    expect(corrected.dayOffset).toBe(0);
  });

  it('자시 기준 옵션에 따라 23시대 일주/시주가 달라질 수 있다', () => {
    const base: BirthInputData = {
      year: 2024,
      month: 3,
      day: 10,
      hour: 23,
      minute: 30,
      gender: 'female',
      isLunar: false,
      birthPlace: null,
    };

    const yaja = calculatePalja(base, { midnightMode: 'yaja' });
    const joja = calculatePalja(base, { midnightMode: 'joja' });
    expect(`${yaja.dayGan}${yaja.dayJi}`).toBe('癸酉');
    expect(`${yaja.hourGan}${yaja.hourJi}`).toBe('甲子');
    expect(`${joja.dayGan}${joja.dayJi}`).toBe('甲戌');
    expect(`${joja.hourGan}${joja.hourJi}`).toBe('甲子');
  });

  it('진태양시와 경도 옵션이 절기 경계 월주 계산에 반영된다', () => {
    const base: BirthInputData = {
      year: 2024,
      month: 3,
      day: 5,
      hour: 11,
      minute: 35,
      gender: 'male',
      isLunar: false,
      birthPlace: '서울',
    };

    const civil = calculatePalja(base, { trueSolarTime: false, midnightMode: 'yaja' });
    const trueSolar = calculatePalja(base, {
      trueSolarTime: true,
      longitude: 127.0,
      midnightMode: 'yaja',
    });

    expect(`${civil.monthGan}${civil.monthJi}`).toBe('丁卯');
    expect(`${trueSolar.monthGan}${trueSolar.monthJi}`).toBe('丙寅');
  });
});
