/// Port of engine/src/engine/core/ganji.ts (sexagenary pillar calculation).
library;

import 'engine_data.dart';
import 'errors.dart';
import 'solar_terms.dart';
import 'temporal.dart';

const List<String> stems = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

const List<String> branches = [
  '子',
  '丑',
  '寅',
  '卯',
  '辰',
  '巳',
  '午',
  '未',
  '申',
  '酉',
  '戌',
  '亥',
];

const int _monthBranchStartIndex = 2;

const Map<String, int> _majorSolarTermToMonthIndex = {
  '소한': 11,
  '입춘': 0,
  '경칩': 1,
  '청명': 2,
  '입하': 3,
  '망종': 4,
  '소서': 5,
  '입추': 6,
  '백로': 7,
  '한로': 8,
  '입동': 9,
  '대설': 10,
};

const Map<String, int> _tigerMonthStemStart = {
  '甲': 2,
  '己': 2,
  '乙': 4,
  '庚': 4,
  '丙': 6,
  '辛': 6,
  '丁': 8,
  '壬': 8,
  '戊': 0,
  '癸': 0,
};

class GanjiPillar {
  const GanjiPillar({required this.gan, required this.ji});

  final String gan;
  final String ji;

  String get ganji => '$gan$ji';
}

class GanjiResult {
  const GanjiResult({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
  });

  final GanjiPillar year;
  final GanjiPillar month;
  final GanjiPillar day;
  final GanjiPillar hour;
}

class GanjiInput {
  const GanjiInput({
    required this.yearMonthDateTime,
    required this.dayHourDateTime,
    this.sect = 2,
    this.dayHourDateTimeSchoolApplied = false,
  });

  GanjiInput.simple(DateTimeParts dateTime)
    : this(yearMonthDateTime: dateTime, dayHourDateTime: dateTime);

  final DateTimeParts yearMonthDateTime;
  final DateTimeParts dayHourDateTime;

  /// sect 1 = joja(조자시), sect 2 = yaja(야자시).
  final int sect;
  final bool dayHourDateTimeSchoolApplied;
}

int _mod(int value, int divisor) => ((value % divisor) + divisor) % divisor;

GanjiPillar _createPillar(int sexagenaryIndex) {
  final normalized = _mod(sexagenaryIndex, 60);
  return GanjiPillar(
    gan: stems[normalized % 10],
    ji: branches[normalized % 12],
  );
}

double _toJulianDay(int year, int month, int day) {
  final a = ((14 - month) / 12).floor();
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      ((153 * m + 2) / 5).floorToDouble() +
      365.0 * y +
      (y / 4).floorToDouble() -
      (y / 100).floorToDouble() +
      (y / 400).floorToDouble() -
      32045 -
      0.5;
}

int _dayIndex(int year, int month, int day) {
  return _mod((_toJulianDay(year, month, day) + 49.5).floor(), 60);
}

({int year, int month, int day}) _shiftSolarDate(
  int year,
  int month,
  int day,
  int offset,
) {
  final shifted = DateTime.utc(year, month, day).add(Duration(days: offset));
  return (year: shifted.year, month: shifted.month, day: shifted.day);
}

SolarTermInfo _ipchunTerm(EngineData data, int year) {
  for (final term in data.termsForYear(year)) {
    if (term.koreanName == '입춘') return term;
  }
  throw ManseryeokException(
    ManseryeokErrorCode.rangeError,
    'No 입춘 data for $year',
  );
}

int _effectiveYear(EngineData data, GanjiInput input) {
  final context = input.yearMonthDateTime;
  final ipchun = _ipchunTerm(data, context.year);
  final effectiveTs = toKstTimestamp(context);
  return effectiveTs >= ipchun.kstTimestamp ? context.year : context.year - 1;
}

SolarTermInfo _latestMajorSolarTerm(EngineData data, GanjiInput input) {
  final context = input.yearMonthDateTime;
  final effectiveTs = toKstTimestamp(context);
  SolarTermInfo? best;
  for (final term in [
    ...data.termsForYear(context.year - 1),
    ...data.termsForYear(context.year),
  ]) {
    if (!_majorSolarTermToMonthIndex.containsKey(term.koreanName)) continue;
    final ts = term.kstTimestamp;
    if (ts <= effectiveTs && (best == null || ts > best.kstTimestamp)) {
      best = term;
    }
  }
  if (best == null) {
    throw ManseryeokException(
      ManseryeokErrorCode.rangeError,
      'No major solar term found for ${context.year}-${context.month}-${context.day}',
    );
  }
  return best;
}

int _hourBranchIndex(int hour) {
  if (hour == 23 || hour == 0) return 0;
  return ((hour + 1) / 2).floor();
}

int _hourStemIndex(String dayStem, int hourBranchIndex) {
  final dayStemIndex = stems.indexOf(dayStem);
  const offsets = [0, 2, 4, 6, 8];
  return _mod(offsets[dayStemIndex % 5] + hourBranchIndex, 10);
}

GanjiPillar _yearPillar(EngineData data, GanjiInput input) {
  return _createPillar(_effectiveYear(data, input) - 1984);
}

GanjiPillar _monthPillar(EngineData data, GanjiInput input) {
  final latestTerm = _latestMajorSolarTerm(data, input);
  final monthIndex = _majorSolarTermToMonthIndex[latestTerm.koreanName]!;
  final yearPillar = _yearPillar(data, input);
  final stemStart = _tigerMonthStemStart[yearPillar.gan]!;
  return GanjiPillar(
    gan: stems[_mod(stemStart + monthIndex, 10)],
    ji: branches[_mod(_monthBranchStartIndex + monthIndex, 12)],
  );
}

GanjiPillar _dayPillar(GanjiInput input) {
  final c = input.dayHourDateTime;
  final shiftToNextDay =
      input.sect == 1 && c.hour == 23 && !input.dayHourDateTimeSchoolApplied;
  final base = shiftToNextDay
      ? _shiftSolarDate(c.year, c.month, c.day, 1)
      : (year: c.year, month: c.month, day: c.day);
  return _createPillar(_dayIndex(base.year, base.month, base.day));
}

GanjiPillar _hourPillar(GanjiInput input) {
  final c = input.dayHourDateTime;
  final hourBranchIndex = _hourBranchIndex(c.hour);
  final shiftToNextDay = c.hour == 23 && !input.dayHourDateTimeSchoolApplied;
  final base = shiftToNextDay
      ? _shiftSolarDate(c.year, c.month, c.day, 1)
      : (year: c.year, month: c.month, day: c.day);
  final hourBaseDayPillar = _createPillar(
    _dayIndex(base.year, base.month, base.day),
  );
  return GanjiPillar(
    gan: stems[_hourStemIndex(hourBaseDayPillar.gan, hourBranchIndex)],
    ji: branches[hourBranchIndex],
  );
}

GanjiResult getGanji(EngineData data, GanjiInput input) {
  return GanjiResult(
    year: _yearPillar(data, input),
    month: _monthPillar(data, input),
    day: _dayPillar(input),
    hour: _hourPillar(input),
  );
}

/// 세운: (year - 4) mod 60 (saju/daeun.ts calculateSeun).
GanjiPillar seunForYear(int year) => _createPillar(year - 4);
