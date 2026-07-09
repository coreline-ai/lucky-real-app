import { describe, expect, it } from 'vitest';
import {
  findNextTerm,
  runSolarTermsYear,
} from '../src/domain/solar-terms';

describe('solar-terms domain (real engine)', () => {
  it('lists 2026 terms non-empty and ordered', () => {
    const out = runSolarTermsYear(2026, {
      year: 2026,
      month: 1,
      day: 1,
      hour: 0,
      minute: 0,
    });
    expect(out.ok).toBe(true);
    if (!out.ok) return;
    expect(out.terms.length).toBeGreaterThanOrEqual(20);
    for (let i = 1; i < out.terms.length; i++) {
      const prev = out.terms[i - 1];
      const cur = out.terms[i];
      const prevKey = prev.month * 100 + prev.day;
      const curKey = cur.month * 100 + cur.day;
      expect(curKey).toBeGreaterThanOrEqual(prevKey);
    }
  });

  it('next-term is deterministic for a fixed now', () => {
    const out = runSolarTermsYear(2026, {
      year: 2026,
      month: 7,
      day: 9,
      hour: 12,
      minute: 0,
    });
    expect(out.ok).toBe(true);
    if (!out.ok) return;
    const again = findNextTerm(out.terms, {
      year: 2026,
      month: 7,
      day: 9,
      hour: 12,
      minute: 0,
    });
    expect(out.next?.koreanName).toBe(again?.koreanName);
    expect(out.next).not.toBeNull();
  });
});
