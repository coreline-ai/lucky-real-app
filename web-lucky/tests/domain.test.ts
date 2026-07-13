import { describe, expect, it } from 'vitest';
import { defaultTargetYear, kstNowParts } from '../src/domain/kst';
import { buildShareText, shareTextLooksSafe } from '../src/domain/share';
import { resolveLunarBirth, runTojeongYearly } from '../src/domain/tojeong';
import { solarToLunar } from 'manseryeok-engine/engine/core/lunar-solar';
import { createFixtureCalendar } from './sharded-calendar-fixture';

describe('runTojeongYearly (real engine)', () => {
  it('returns gwae 1..144 and twelve monthly texts for fixed solar birth 1990-03-15 / 2026', async () => {
    const calendar = createFixtureCalendar();
    const first = await runTojeongYearly(
      { year: 1990, month: 3, day: 15, calendarType: 'solar' },
      2026,
      calendar,
    );
    expect(first.ok).toBe(true);
    if (!first.ok) return;

    expect(first.result.gwae.gwaeNumber).toBeGreaterThanOrEqual(1);
    expect(first.result.gwae.gwaeNumber).toBeLessThanOrEqual(144);
    expect(first.result.interpretation.title.length).toBeGreaterThan(0);
    expect(first.result.interpretation.monthly).toHaveLength(12);
    expect(first.lunarBirth.year).toBe(1990);
    expect(first.lunarBirth.month).toBe(2);
    expect(first.lunarBirth.day).toBe(19);
    const syncLunar = solarToLunar({ year: 1990, month: 3, day: 15 });
    expect(first.lunarBirth).toEqual({
      year: syncLunar.year,
      month: syncLunar.month,
      day: syncLunar.day,
      isLeapMonth: syncLunar.isLeapMonth,
    });

    const second = await runTojeongYearly(
      { year: 1990, month: 3, day: 15, calendarType: 'solar' },
      2026,
      calendar,
    );
    expect(second.ok).toBe(true);
    if (!second.ok) return;
    expect(second.result.gwae.gwaeNumber).toBe(first.result.gwae.gwaeNumber);
    expect(second.result.gwae.gwaeCode).toBe(first.result.gwae.gwaeCode);
  });

  it('surfaces converted lunar year for solar January birth when year rolls back', async () => {
    const calendar = createFixtureCalendar();
    const lunar = await resolveLunarBirth(
      { year: 1990, month: 1, day: 15, calendarType: 'solar' },
      calendar,
    );
    expect(lunar.year).toBe(1989);

    const out = await runTojeongYearly(
      { year: 1990, month: 1, day: 15, calendarType: 'solar' },
      2026,
      calendar,
    );
    expect(out.ok).toBe(true);
    if (!out.ok) return;
    expect(out.lunarBirth.year).toBe(1989);
    expect(out.lunarBirth.year).not.toBe(1990);
  });

  it('accepts lunar input without solar conversion path change', async () => {
    const requests: string[] = [];
    const out = await runTojeongYearly(
      {
        year: 1990,
        month: 2,
        day: 19,
        calendarType: 'lunar',
        isLeapMonth: false,
      },
      2026,
      createFixtureCalendar(requests),
    );
    expect(out.ok).toBe(true);
    if (!out.ok) return;
    expect(out.lunarBirth).toEqual({
      year: 1990,
      month: 2,
      day: 19,
      isLeapMonth: false,
    });
    expect(requests).toEqual([]);
  });

  it('supports leap-month lookup and rejects unsupported years', async () => {
    const calendar = createFixtureCalendar();
    await expect(
      calendar.lunarToSolarAsync({
        year: 1990,
        month: 5,
        day: 1,
        isLeapMonth: true,
      }),
    ).resolves.toMatchObject({ year: 1990, month: 6, day: 23 });
    await expect(
      calendar.solarToLunarAsync({ year: 2200, month: 1, day: 1 }),
    ).rejects.toThrow(/Unsupported solar year/);
    await expect(
      calendar.solarToLunarAsync({ year: 2101, month: 12, day: 31 }),
    ).resolves.toMatchObject({ year: 2101 });
  });

  it('memory-caches the manifest and requested year shard', async () => {
    const requests: string[] = [];
    const calendar = createFixtureCalendar(requests);
    await calendar.solarToLunarAsync({ year: 1990, month: 3, day: 15 });
    await calendar.solarToLunarAsync({ year: 1990, month: 3, day: 16 });
    expect(requests.filter((url) => url.endsWith('/manifest.json'))).toHaveLength(1);
    expect(
      requests.filter((url) => url.endsWith('/lunar-solar/1990.json')),
    ).toHaveLength(1);
  });

  it('rejects invalid month', async () => {
    const out = await runTojeongYearly(
      { year: 1990, month: 13, day: 1, calendarType: 'solar' },
      2026,
      createFixtureCalendar(),
    );
    expect(out.ok).toBe(false);
  });
});

describe('buildShareText', () => {
  it('includes year and hexagram but no birth date patterns', async () => {
    const reading = await runTojeongYearly(
      { year: 1990, month: 3, day: 15, calendarType: 'solar' },
      2026,
      createFixtureCalendar(),
    );
    expect(reading.ok).toBe(true);
    if (!reading.ok) return;

    const text = buildShareText({
      targetYear: 2026,
      result: reading.result,
    });
    expect(text).toContain('2026');
    expect(text).toContain(`제${reading.result.gwae.gwaeNumber}괘`);
    expect(text).toContain('오락용');
    expect(shareTextLooksSafe(text)).toBe(true);
    expect(text).not.toMatch(/\d{4}-\d{2}-\d{2}/);
    expect(text).not.toContain('1990-03-15');
    expect(text).not.toContain('음력 1990');
  });
});

describe('kstNowParts', () => {
  it('returns Asia/Seoul calendar parts matching Intl for a fixed instant', () => {
    // 2026-07-09 15:00 UTC → 2026-07-10 00:00 KST
    const instant = new Date('2026-07-09T15:00:00.000Z');
    const parts = kstNowParts(instant);
    expect(parts).toEqual({ year: 2026, month: 7, day: 10 });

    const fmt = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Seoul',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(instant);
    expect(fmt).toBe('2026-07-10');
  });

  it('defaultTargetYear uses next year in December KST', () => {
    // 2026-12-15 03:00 UTC = 2026-12-15 12:00 KST
    const dec = new Date('2026-12-15T03:00:00.000Z');
    expect(defaultTargetYear(dec)).toBe(2027);
    // 2026-06-01 KST
    const jun = new Date('2026-05-31T16:00:00.000Z');
    expect(defaultTargetYear(jun)).toBe(2026);
  });
});
