/// Port of engine/src/engine/core/solar-terms.ts (query subset used by the
/// gateway: KST normalization, year listing, on-or-before lookup, exact-day).
library;

import 'engine_data.dart';
import 'temporal.dart';

/// Source data is 1 hour behind KST (solar-terms.ts SOURCE_TO_KST_OFFSET_HOURS).
const int _sourceToKstOffsetMinutes = 60;

/// 월주 전환에 쓰이는 12절 (solar-terms.ts JEOL_SOLAR_TERM_NAMES).
const Set<String> jeolSolarTermNames = {
  '소한',
  '입춘',
  '경칩',
  '청명',
  '입하',
  '망종',
  '소서',
  '입추',
  '백로',
  '한로',
  '입동',
  '대설',
};

class SolarTermInfo {
  const SolarTermInfo({
    required this.koreanName,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
  });

  factory SolarTermInfo.fromSourceJson(Map<String, dynamic> json) {
    return SolarTermInfo(
      koreanName: json['koreanName'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      day: json['day'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      second: json['second'] as int,
    );
  }

  final String koreanName;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;

  DateTimeParts get parts => DateTimeParts(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: second,
  );

  int get kstTimestamp => toKstTimestamp(parts);

  bool get isJeol => jeolSolarTermNames.contains(koreanName);

  SolarTermInfo normalizedToKst() {
    final shifted = shiftDateTimeUtc(parts, _sourceToKstOffsetMinutes);
    return SolarTermInfo(
      koreanName: koreanName,
      year: shifted.year,
      month: shifted.month,
      day: shifted.day,
      hour: shifted.hour,
      minute: shifted.minute,
      second: shifted.second,
    );
  }
}

SolarTermInfo? solarTermOnOrBefore(EngineData data, DateTimeParts dateTime) {
  final target = toKstTimestamp(dateTime);
  SolarTermInfo? best;
  for (final term in [
    ...data.termsForYear(dateTime.year - 1),
    ...data.termsForYear(dateTime.year),
    ...data.termsForYear(dateTime.year + 1),
  ]) {
    final ts = term.kstTimestamp;
    if (ts <= target && (best == null || ts > best.kstTimestamp)) {
      best = term;
    }
  }
  return best;
}

/// Term whose (KST-normalized) calendar date equals the given date, if any.
/// Mirrors manseryeok-engine.ts getExactSolarTerm.
String? exactSolarTermName(EngineData data, int year, int month, int day) {
  for (final term in data.termsForYear(year)) {
    if (term.year == year && term.month == month && term.day == day) {
      return term.koreanName;
    }
  }
  return null;
}
