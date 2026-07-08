import { describe, expect, it } from 'vitest';
import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';
import {
  getSolarTermOnOrBefore,
  getSolarTermOnOrBeforeDateTime,
  getSolarTermsOnDate,
} from '@/engine/core/solar-terms';

describe('timestamp-aware solar term context', () => {
  it('keeps 2024 입춘 same-day context on 대한 before the exact KST timestamp', () => {
    const before = ManseryeokEngine.getSolarContext({
      year: 2024,
      month: 2,
      day: 4,
      hour: 17,
      minute: 20,
    });
    const after = ManseryeokEngine.getSolarContext({
      year: 2024,
      month: 2,
      day: 4,
      hour: 17,
      minute: 35,
    });

    expect(getSolarTermsOnDate(2024, 2, 4).map((term) => term.koreanName)).toContain('입춘');
    expect(before.currentSolarTerm.koreanName).toBe('대한');
    expect(before.exactSolarTerm).toBe('입춘');
    expect(after.currentSolarTerm.koreanName).toBe('입춘');
    expect(after.exactSolarTerm).toBe('입춘');
  });

  it('keeps 2024 경칩 same-day context on 우수 before the exact KST timestamp', () => {
    const before = ManseryeokEngine.getSolarContext({
      year: 2024,
      month: 3,
      day: 5,
      hour: 11,
      minute: 20,
    });
    const after = ManseryeokEngine.getSolarContext({
      year: 2024,
      month: 3,
      day: 5,
      hour: 11,
      minute: 35,
    });

    expect(getSolarTermsOnDate(2024, 3, 5).map((term) => term.koreanName)).toContain('경칩');
    expect(before.currentSolarTerm.koreanName).toBe('우수');
    expect(before.exactSolarTerm).toBe('경칩');
    expect(after.currentSolarTerm.koreanName).toBe('경칩');
    expect(after.exactSolarTerm).toBe('경칩');
  });

  it('preserves date-only wrapper compatibility at the start of a solar-term day', () => {
    expect(getSolarTermOnOrBefore('2024-02-04').koreanName).toBe('대한');
    expect(ManseryeokEngine.getSolarTermOnOrBefore('2024-02-04').koreanName).toBe('대한');
    expect(getSolarTermOnOrBefore('2024-03-05').koreanName).toBe('우수');
    expect(getSolarTermOnOrBeforeDateTime({
      year: 2024,
      month: 2,
      day: 4,
      hour: 17,
      minute: 35,
      second: 0,
    }).koreanName).toBe('입춘');
  });
});
