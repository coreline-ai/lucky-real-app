import { describe, expect, it } from 'vitest';
import { runIljinDay, shiftDate } from '../src/domain/iljin';

describe('runIljinDay (real engine)', () => {
  it('returns non-empty day pillar fields and is deterministic for 2026-07-09', () => {
    const a = runIljinDay(2026, 7, 9);
    const b = runIljinDay(2026, 7, 9);
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
