import { describe, expect, it } from 'vitest';
import { runIljinDay, shiftDate } from '../src/domain/iljin';
import { createFixtureCalendar } from './sharded-calendar-fixture';

describe('runIljinDay (real engine)', () => {
  it('returns non-empty day pillar fields and is deterministic for 2026-07-09', async () => {
    const calendar = createFixtureCalendar();
    const a = await runIljinDay(2026, 7, 9, calendar);
    const b = await runIljinDay(2026, 7, 9, calendar);
    expect(a.ok).toBe(true);
    expect(b.ok).toBe(true);
    if (!a.ok || !b.ok) return;
    expect(a.dayInfo.dayGanJi.length).toBeGreaterThan(0);
    expect(a.dayInfo.ohaeng.length).toBeGreaterThan(0);
    expect(a.dayInfo.dayGanJi).toBe(b.dayInfo.dayGanJi);
    expect(a.dayInfo.gilhyung).toBe(b.dayInfo.gilhyung);
  });

  it('shiftDate moves calendar day', () => {
    expect(shiftDate(2026, 7, 9, 1)).toEqual({
      year: 2026,
      month: 7,
      day: 10,
    });
    expect(shiftDate(2026, 7, 1, -1)).toEqual({
      year: 2026,
      month: 6,
      day: 30,
    });
  });
});
