import { describe, expect, it } from 'vitest';
import { runChemi } from '../src/domain/chemi';
import { createFixtureCalendar } from './sharded-calendar-fixture';

const p1 = {
  year: 1990,
  month: 3,
  day: 15,
  gender: 'male' as const,
  isLunar: false,
  hour: null,
  minute: null,
};

const p2 = {
  year: 1992,
  month: 8,
  day: 20,
  gender: 'female' as const,
  isLunar: false,
  hour: null,
  minute: null,
};

describe('runChemi (real engine)', () => {
  it('returns score 0–100, grade, advice; second call matches', async () => {
    const calendar = createFixtureCalendar();
    const a = await runChemi(p1, p2, calendar);
    const b = await runChemi(p1, p2, calendar);
    expect(a.ok).toBe(true);
    expect(b.ok).toBe(true);
    if (!a.ok || !b.ok) return;
    expect(a.result.totalScore).toBeGreaterThanOrEqual(0);
    expect(a.result.totalScore).toBeLessThanOrEqual(100);
    expect(['S', 'A', 'B', 'C', 'D']).toContain(a.result.grade);
    expect(a.result.advice.length).toBeGreaterThan(0);
    expect(a.result.totalScore).toBe(b.result.totalScore);
    expect(a.result.grade).toBe(b.result.grade);
  });
});
