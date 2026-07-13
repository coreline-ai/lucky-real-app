import { describe, expect, it } from 'vitest';
import {
  findNextTerm,
  runSolarTermsYear,
} from '../src/domain/solar-terms';
import { listSolarTermsForYear } from 'manseryeok-engine/engine/core/solar-terms';
import { createFixtureCalendar } from './sharded-calendar-fixture';

describe('solar-terms domain (real engine)', () => {
  it('lists 2026 terms non-empty and ordered', async () => {
    const out = await runSolarTermsYear(
      2026,
      { year: 2026, month: 1, day: 1, hour: 0, minute: 0 },
      createFixtureCalendar(),
    );
    expect(out.ok).toBe(true);
    if (!out.ok) return;
    expect(out.terms.length).toBeGreaterThanOrEqual(20);
    expect(out.terms).toEqual(listSolarTermsForYear(2026));
    for (let i = 1; i < out.terms.length; i++) {
      const prev = out.terms[i - 1];
      const cur = out.terms[i];
      const prevKey = prev.month * 100 + prev.day;
      const curKey = cur.month * 100 + cur.day;
      expect(curKey).toBeGreaterThanOrEqual(prevKey);
    }
  });

  it('next-term is deterministic for a fixed now', async () => {
    const out = await runSolarTermsYear(
      2026,
      { year: 2026, month: 7, day: 9, hour: 12, minute: 0 },
      createFixtureCalendar(),
    );
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

  it('loads only the selected year and then uses memory cache', async () => {
    const requests: string[] = [];
    const calendar = createFixtureCalendar(requests);
    await runSolarTermsYear(2026, undefined, calendar);
    await runSolarTermsYear(2026, undefined, calendar);
    expect(requests.filter((url) => url.endsWith('/manifest.json'))).toHaveLength(1);
    expect(
      requests.filter((url) => url.endsWith('/solar-terms/2026.json')),
    ).toHaveLength(1);
    expect(requests.some((url) => url.includes('/solar-terms/2025.json'))).toBe(false);
  });
});
