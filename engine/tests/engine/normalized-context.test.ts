import { describe, expect, it } from 'vitest';
import { calculateEquationOfTime, correctToTrueSolarTime } from '@/engine/adapter/time-corrector';
import { AmbiguousCivilTimeError, ManseryeokPolicyError, NonexistentCivilTimeError } from '@/engine/core/errors';
import { createNormalizedManseryeokContext } from '@/engine/core/normalized-context';
import type { BirthInputData } from '@/engine/types';

function birthInput(overrides: Partial<BirthInputData>): BirthInputData {
  return {
    year: 2000,
    month: 1,
    day: 1,
    hour: 12,
    minute: 0,
    gender: 'male',
    isLunar: false,
    isLeapMonth: false,
    birthPlace: null,
    ...overrides,
  };
}

describe('NormalizedManseryeokContext', () => {
  it('converts lunar input to solar civil datetime before true-solar correction', () => {
    const context = createNormalizedManseryeokContext(
      birthInput({
        year: 2000,
        month: 2,
        day: 4,
        hour: 12,
        minute: 0,
        isLunar: true,
        isLeapMonth: false,
      }),
      { trueSolarTime: true, longitude: 127.0, midnightMode: 'yaja' },
    );

    expect(context.originalInput).toMatchObject({
      calendar: 'lunar',
      year: 2000,
      month: 2,
      day: 4,
      hour: 12,
      minute: 0,
      isLeapMonth: false,
      longitude: 127.0,
      midnightMode: 'yaja',
      trueSolarTime: true,
    });
    expect(context.solarCivilDateTime).toMatchObject({
      year: 2000,
      month: 3,
      day: 9,
      hour: 12,
      minute: 0,
      second: 0,
      source: 'converted-from-lunar',
    });
    expect(context.schoolResolution.evaluatedDateTimeBasis).toBe('true-solar');
    expect(context.yearMonthContextDateTime.basis).toBe('true-solar');
    expect(context.dayHourContextDateTime.basis).toBe('true-solar');
  });

  it('preserves unknown hour/minute as null while defaulting internal datetimes to midnight', () => {
    const context = createNormalizedManseryeokContext(
      birthInput({ hour: null, minute: null }),
      { trueSolarTime: false },
    );

    expect(context.originalInput.hour).toBeNull();
    expect(context.originalInput.minute).toBeNull();
    expect(context.solarCivilDateTime).toMatchObject({ hour: 0, minute: 0, second: 0 });
    expect(context.yearMonthContextDateTime).toMatchObject({ hour: 0, minute: 0, second: 0 });
  });

  it('resolves 1956 daylight saving time to UTC+09:30 total offset', () => {
    const context = createNormalizedManseryeokContext(
      birthInput({ year: 1956, month: 6, day: 1, hour: 12, minute: 0 }),
    );

    expect(context.legalTime).toMatchObject({
      standardOffsetMinutes: 510,
      daylightOffsetMinutes: 60,
      totalOffsetMinutes: 570,
      standardMeridianDegrees: 127.5,
      transitionStatus: 'daylight',
    });
  });

  it('resolves 1987 daylight saving time to UTC+10:00 total offset', () => {
    const context = createNormalizedManseryeokContext(
      birthInput({ year: 1987, month: 6, day: 1, hour: 12, minute: 0 }),
    );

    expect(context.legalTime).toMatchObject({
      standardOffsetMinutes: 540,
      daylightOffsetMinutes: 60,
      totalOffsetMinutes: 600,
      standardMeridianDegrees: 135,
      transitionStatus: 'daylight',
    });
  });

  it('models standard-time transition boundary labels explicitly', () => {
    expect(() => createNormalizedManseryeokContext(
      birthInput({ year: 1954, month: 3, day: 21, hour: 0, minute: 15 }),
    )).toThrow(AmbiguousCivilTimeError);

    expect(createNormalizedManseryeokContext(
      birthInput({ year: 1954, month: 3, day: 21, hour: 0, minute: 30 }),
    ).legalTime.totalOffsetMinutes).toBe(510);

    expect(() => createNormalizedManseryeokContext(
      birthInput({ year: 1961, month: 8, day: 10, hour: 0, minute: 15 }),
    )).toThrow(NonexistentCivilTimeError);

    expect(createNormalizedManseryeokContext(
      birthInput({ year: 1961, month: 8, day: 10, hour: 0, minute: 30 }),
    ).legalTime.totalOffsetMinutes).toBe(540);
  });

  it('uses the legal standard meridian for true-solar correction', () => {
    const context = createNormalizedManseryeokContext(
      birthInput({ year: 1956, month: 11, day: 1, hour: 12, minute: 0 }),
      { trueSolarTime: true, longitude: 127.5 },
    );
    const expected = correctToTrueSolarTime(
      { year: 1956, month: 11, day: 1, hour: 12, minute: 0 },
      127.5,
      { standardLongitude: 127.5 },
    );
    const legacyKst = correctToTrueSolarTime(
      { year: 1956, month: 11, day: 1, hour: 12, minute: 0 },
      127.5,
      { standardLongitude: 135 },
    );

    expect(context.trueSolar.standardLongitude).toBe(127.5);
    expect(context.trueSolar.dateTime).toMatchObject({
      year: expected.year,
      month: expected.month,
      day: expected.day,
      hour: expected.hour,
      minute: expected.minute,
    });
    expect(context.trueSolar.dateTime.minute).not.toBe(legacyKst.minute);
  });

  it('subtracts daylight-saving offset before true-solar correction', () => {
    const context = createNormalizedManseryeokContext(
      birthInput({ year: 1987, month: 7, day: 15, hour: 14, minute: 0 }),
      { trueSolarTime: true, longitude: 127.0 },
    );
    const expectedStandardClock = correctToTrueSolarTime(
      { year: 1987, month: 7, day: 15, hour: 13, minute: 0 },
      127.0,
      { standardLongitude: 135 },
    );

    expect(context.legalTime).toMatchObject({
      daylightOffsetMinutes: 60,
      totalOffsetMinutes: 600,
    });
    expect(context.trueSolar.dateTime).toMatchObject({
      year: expectedStandardClock.year,
      month: expectedStandardClock.month,
      day: expectedStandardClock.day,
      hour: expectedStandardClock.hour,
      minute: expectedStandardClock.minute,
    });
  });

  it('throws a policy error for unsupported pre-1908 Korean legal time', () => {
    expect(() => createNormalizedManseryeokContext(
      birthInput({ year: 1907, month: 12, day: 31, hour: 23, minute: 59 }),
    )).toThrow(ManseryeokPolicyError);
  });

  it('keeps equation-of-time day-of-year calculation timezone invariant', () => {
    expect(calculateEquationOfTime(2000, 3, 9)).toBeCloseTo(-11.02, 2);
    expect(calculateEquationOfTime(2000, 1, 1)).toBeCloseTo(-3.71, 2);
  });
});
