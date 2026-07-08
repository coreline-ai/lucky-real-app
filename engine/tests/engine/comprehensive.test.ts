import { describe, expect, it } from 'vitest';
import { analyzeTojeong } from '@/engine/tojeong';
import { calculateZiwei, calculateZiweiByLunar } from '@/engine/ziwei';
import { analyzeName, analyzeNameExtended } from '@/engine/naming';
import { calculateCompatibility } from '@/engine/compatibility';
import { calculateGuseong } from '@/engine/guseong';
import { divineByTime, divineByNumber, divineByName } from '@/engine/maehwa';
import { calculateDaeyukim } from '@/engine/daeyukim';
import { calculateHarak } from '@/engine/harak';
import { calculateDaejeong } from '@/engine/daejeong';
import { analyzeHongyeon } from '@/engine/hongyeon';
import { getCalendarDay, getMonthlyCalendar } from '@/engine/calendar';

describe('Comprehensive Divination Engine Verification', () => {
  it('verifies Tojeongbigyeol (토정비결) calculations and output schema', () => {
    const result = analyzeTojeong(1990, 3, 15, 2026);
    expect(result).toBeDefined();
    expect(result.gwae.gwaeNumber).toBeGreaterThanOrEqual(1);
    expect(result.gwae.gwaeNumber).toBeLessThanOrEqual(144);
    expect(result.gwae.gwaeCode).toBeDefined();
    expect(result.interpretation.overall).toBeDefined();
    expect(result.interpretation.monthly).toHaveLength(12);
  });

  it('verifies Ziweidushu (자미두수) solar and lunar entry points', () => {
    const solarResult = calculateZiwei('1990-03-15', 14, 'male');
    expect(solarResult).toBeDefined();
    expect(solarResult.palaces).toHaveLength(12);
    expect(solarResult.chineseDate).toBeDefined();

    const lunarResult = calculateZiweiByLunar('1990-02-19', 14, 'female');
    expect(lunarResult).toBeDefined();
    expect(lunarResult.palaces).toHaveLength(12);
  });

  it('verifies Naming (작명/성명학) basic and extended engines', () => {
    const basicResult = analyzeName('김', '철수');
    expect(basicResult).toBeDefined();
    expect(basicResult.strokes).toHaveLength(3); // 성포함 3글자
    expect(basicResult.suri81.won).toBeDefined();
    expect(basicResult.ohaengRelation).toBeDefined();

    const extendedResult = analyzeNameExtended('김', '철수', {
      hanjaChars: ['金', '哲', '秀'],
      school: 'kangxi',
    });
    expect(extendedResult).toBeDefined();
    expect(extendedResult.totalScore).toBeGreaterThanOrEqual(0);
    expect(extendedResult.totalScore).toBeLessThanOrEqual(100);
  });

  it('verifies Relationship Compatibility (궁합) engine scoring and advice', () => {
    const result = calculateCompatibility({
      person1: {
        year: 1990,
        month: 3,
        day: 15,
        hour: 12,
        minute: 0,
        gender: 'male',
      },
      person2: {
        year: 1992,
        month: 8,
        day: 20,
        hour: 18,
        minute: 30,
        gender: 'female',
      },
    });

    expect(result).toBeDefined();
    expect(result.totalScore).toBeGreaterThanOrEqual(0);
    expect(result.totalScore).toBeLessThanOrEqual(100);
    expect(['S', 'A', 'B', 'C', 'D']).toContain(result.grade);
    expect(result.advice).toBeInstanceOf(Array);
  });

  it('verifies Guseonggihak (구성기학) 3x3 grids and star relations', () => {
    const result = calculateGuseong(1990, 'male', 2026, 7, 7);
    expect(result).toBeDefined();
    expect(result.bonmyeongseong.number).toBe(1); // (11 - (1990 % 9)) % 9 = 2? Wait: 1990 % 9 = 1. 11 - 1 = 10 % 9 = 1. Yes, 1.
    expect(result.yearChart.positions).toHaveLength(9);
    expect(result.monthChart.positions).toHaveLength(9);
    expect(result.dailyChart.positions).toHaveLength(9);
    expect(result.interpretation).toContain('본명성');
  });

  it('verifies Maehwayeoksu (매화역수) divination methods', () => {
    const timeResult = divineByTime(2026, 7, 7, 12);
    expect(timeResult).toBeDefined();
    expect(timeResult.method).toBe('time');
    expect(timeResult.hexagramNumber).toBeGreaterThanOrEqual(1);
    expect(timeResult.hexagramNumber).toBeLessThanOrEqual(64);

    const numberResult = divineByNumber(1234, 5678);
    expect(numberResult).toBeDefined();
    expect(numberResult.method).toBe('number');

    const nameResult = divineByName(15, 12);
    expect(nameResult).toBeDefined();
    expect(nameResult.method).toBe('name');
  });

  it('verifies Daeyukim (대육임) 4Gwa and 3Jeon layout', () => {
    const result = calculateDaeyukim('2026-07-07', 12);
    expect(result).toBeDefined();
    expect(result.saGwa).toHaveLength(4);
    expect(result.samJeon).toHaveLength(3);
    expect(result.cheonJangList).toHaveLength(12);
    expect(result.cheonJiBan).toHaveLength(12);
  });

  it('verifies Harakisu (하락이수) Hado and Nakseo mapping', () => {
    const result = calculateHarak(1990, 3, 15);
    expect(result).toBeDefined();
    expect(result.hadosu).toBeGreaterThanOrEqual(1);
    expect(result.hadosu).toBeLessThanOrEqual(10);
    expect(result.nakseosu).toBeGreaterThanOrEqual(1);
    expect(result.nakseosu).toBeLessThanOrEqual(9);
    expect(result.hexagramNumber).toBeGreaterThanOrEqual(1);
    expect(result.hexagramNumber).toBeLessThanOrEqual(64);
  });

  it('verifies Daejeongsu (대정수) Seoncheon and Hucheon numbers', () => {
    const palja = {
      yearGan: '庚', yearJi: '午',
      monthGan: '己', monthJi: '卯',
      dayGan: '丙', dayJi: '戌',
      hourGan: '癸', hourJi: '巳',
    };
    const result = calculateDaejeong(palja);
    expect(result).toBeDefined();
    expect(result.seoncheonsuTotal).toBeGreaterThanOrEqual(16);
    expect(result.hucheonsuTotal).toBeGreaterThanOrEqual(16);
    expect(result.changingLine).toBeGreaterThanOrEqual(1);
    expect(result.changingLine).toBeLessThanOrEqual(6);
  });

  it('verifies Hongyeon Gimen (홍연기문) Gugung configuration', () => {
    const palja = {
      yearGan: '庚', yearJi: '午',
      monthGan: '己', monthJi: '卯',
      dayGan: '丙', dayJi: '戌',
      hourGan: '癸', hourJi: '巳',
    };
    const result = analyzeHongyeon(palja);
    expect(result).toBeDefined();
    expect(result.hongguksu).toBeGreaterThanOrEqual(1);
    expect(result.hongguksu).toBeLessThanOrEqual(9);
    expect(result.gugung).toHaveLength(9);
    expect(result.tonggido).toBeDefined();
  });

  it('verifies Calendar (역학달력) day and month builders', () => {
    const dayResult = getCalendarDay(2026, 7, 7);
    expect(dayResult).toBeDefined();
    expect(dayResult.solarDate).toBe('2026-07-07');
    expect(dayResult.dayGanJi).toBeDefined();
    expect(dayResult.sinsal12).toBeDefined();

    const monthResult = getMonthlyCalendar(2026, 7);
    expect(monthResult).toBeDefined();
    expect(monthResult.days.length).toBe(31);
    expect(monthResult.monthGanJi).toBeDefined();
  });
});
