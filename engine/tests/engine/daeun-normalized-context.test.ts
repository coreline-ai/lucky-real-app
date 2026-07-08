import { describe, expect, it } from 'vitest';
import { calculatePalja } from '@/engine/saju/calculator';
import { calculateDaeun, calculateSeun, calculateWolun, calculateYunStartAge } from '@/engine/saju/daeun';
import type { BirthInputData } from '@/engine/types';

function birth(overrides: Partial<BirthInputData>): BirthInputData {
  return {
    year: 2024,
    month: 3,
    day: 5,
    hour: 5,
    minute: 22,
    gender: 'male',
    isLunar: false,
    birthPlace: null,
    ...overrides,
  };
}

describe('대운 정규화 컨텍스트 정책', () => {
  it('G001 경칩 직전 순행은 1세 클램프 없이 0세 대운을 낸다', () => {
    const input = birth({ hour: 5, minute: 22, gender: 'male' });
    const palja = calculatePalja(input);
    const daeun = calculateDaeun(palja, input, 1);

    expect(calculateYunStartAge(input)).toBe(0);
    expect(daeun[0]).toMatchObject({ age: 0 });
    expect(daeun[0].startAgeMonths).toBeGreaterThan(0);
    expect(daeun[0].startAgeMonths).toBeLessThan(12);
  });

  it('경칩 직후 역행도 1세 클램프 없이 0세 대운을 낸다', () => {
    const input = birth({ hour: 17, minute: 22, gender: 'female' });
    const palja = calculatePalja(input);
    const daeun = calculateDaeun(palja, input, 1);

    expect(calculateYunStartAge(input)).toBe(0);
    expect(daeun[0].age).toBe(0);
    expect(daeun[0].startAgeMonths).toBeGreaterThan(0);
    expect(daeun[0].startAgeMonths).toBeLessThan(12);
  });

  it('절기와 같은 분의 초 단위 차이도 0세 세부개월로 보존한다', () => {
    const input = birth({ hour: 11, minute: 22, gender: 'male' });
    const palja = calculatePalja(input);
    const daeun = calculateDaeun(palja, input, 1);

    expect(calculateYunStartAge(input)).toBe(0);
    expect(daeun[0].age).toBe(0);
    expect(daeun[0].startAgeMonths).toBeGreaterThan(0);
    expect(daeun[0].startAgeMonths).toBeLessThan(0.01);
  });

  it('음력과 진태양시를 함께 써도 음력 라벨을 먼저 보정하지 않고 정규화 컨텍스트를 따른다', () => {
    const input = birth({
      year: 2024,
      month: 1,
      day: 25,
      hour: 11,
      minute: 35,
      isLunar: true,
      gender: 'male',
    });
    const options = { trueSolarTime: true, longitude: 127.0 };
    const palja = calculatePalja(input, options);
    const daeun = calculateDaeun(palja, input, 1, options);

    expect(daeun[0].age).toBe(calculateYunStartAge(input, options));
    expect(daeun[0].startAgeMonths).toBeGreaterThanOrEqual(0);
  });
});

describe('세운/월운 타임스탬프 절기 경계', () => {
  it('세운은 입춘 정확한 시각부터 다음 년주로 바뀐다', () => {
    expect(calculateSeun(new Date('2024-02-04T08:27:06Z'))).toEqual({ gan: '癸', ji: '卯' });
    expect(calculateSeun(new Date('2024-02-04T08:27:07Z'))).toEqual({ gan: '甲', ji: '辰' });
  });

  it('월운은 경칩 정확한 시각부터 묘월로 바뀐다', () => {
    expect(calculateWolun(new Date('2024-03-05T02:22:44Z'))).toEqual({ gan: '丙', ji: '寅' });
    expect(calculateWolun(new Date('2024-03-05T02:22:45Z'))).toEqual({ gan: '丁', ji: '卯' });
  });
});
