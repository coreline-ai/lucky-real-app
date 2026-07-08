/// Port of engine/src/engine/core/normalized-context.ts and
/// adapter/school-resolver.ts, limited to the MVP scope
/// (legal-civil basis only; true-solar-time correction is a v2 option).
library;

import '../gateway/models.dart';
import 'engine_data.dart';
import 'korean_legal_time.dart';
import 'lunar_solar.dart';
import 'temporal.dart';

class SchoolResolution {
  const SchoolResolution({required this.sect, required this.useCurrentDay});

  /// sect 1 = joja(조자시), sect 2 = yaja(야자시).
  final int sect;
  final bool useCurrentDay;
}

/// adapter/school-resolver.ts resolveSchool.
SchoolResolution resolveSchool(DayBoundaryRule mode, int hour) {
  final isZiHour = hour >= 23 || hour < 1;
  if (!isZiHour) {
    return SchoolResolution(
      sect: mode == DayBoundaryRule.midnight ? 1 : 2,
      useCurrentDay: true,
    );
  }
  if (mode == DayBoundaryRule.lateZiHour) {
    return const SchoolResolution(sect: 2, useCurrentDay: true);
  }
  if (hour >= 23) {
    return const SchoolResolution(sect: 1, useCurrentDay: false);
  }
  return const SchoolResolution(sect: 1, useCurrentDay: true);
}

class NormalizedContext {
  const NormalizedContext({
    required this.solarCivilDateTime,
    required this.legalTime,
    required this.sect,
    required this.yearMonthContextDateTime,
    required this.dayHourContextDateTime,
    required this.dayHourSchoolApplied,
  });

  final DateTimeParts solarCivilDateTime;
  final KoreanLegalTimeResolution legalTime;
  final int sect;
  final DateTimeParts yearMonthContextDateTime;
  final DateTimeParts dayHourContextDateTime;
  final bool dayHourSchoolApplied;
}

NormalizedContext createNormalizedContext(EngineData data, BirthInput input) {
  final internal = DateTimeParts(
    year: input.year,
    month: input.month,
    day: input.day,
    hour: input.hour ?? 0,
    minute: input.minute ?? 0,
  );

  final DateTimeParts solarCivil;
  if (input.calendarType == CalendarType.lunar) {
    final solar = lunarToSolar(
      data,
      input.year,
      input.month,
      input.day,
      input.isLeapMonth,
    );
    solarCivil = DateTimeParts(
      year: solar.year,
      month: solar.month,
      day: solar.day,
      hour: internal.hour,
      minute: internal.minute,
    );
  } else {
    solarCivil = internal;
  }

  final legalTime = resolveKoreanLegalTime(solarCivil);
  final school = resolveSchool(input.dayBoundaryRule, solarCivil.hour);
  final dayHour = school.useCurrentDay
      ? solarCivil
      : shiftDateTimeUtc(solarCivil, 24 * 60);

  return NormalizedContext(
    solarCivilDateTime: solarCivil,
    legalTime: legalTime,
    sect: school.sect,
    yearMonthContextDateTime: solarCivil,
    dayHourContextDateTime: dayHour,
    dayHourSchoolApplied: !school.useCurrentDay,
  );
}
