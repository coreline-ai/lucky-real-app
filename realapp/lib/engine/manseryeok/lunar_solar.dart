/// Port of engine/src/engine/core/lunar-solar.ts (table lookups).
library;

import 'engine_data.dart';
import 'errors.dart';

class LunarDate {
  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    required this.isLeapMonth,
  });

  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;
}

class SolarDate {
  const SolarDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;
}

String _pad(int v) => v.toString().padLeft(2, '0');

LunarDate solarToLunar(EngineData data, int year, int month, int day) {
  final key = '$year-${_pad(month)}-${_pad(day)}';
  final match = data.solarToLunar[key];
  if (match == null) {
    throw ManseryeokException(
      ManseryeokErrorCode.dataError,
      'Unsupported solar date: $key',
    );
  }
  return LunarDate(
    year: match[0],
    month: match[1],
    day: match[2],
    isLeapMonth: match[3] != 0,
  );
}

SolarDate lunarToSolar(
  EngineData data,
  int year,
  int month,
  int day,
  bool isLeapMonth,
) {
  final key = '$year-${_pad(month)}-${_pad(day)}-${isLeapMonth ? 1 : 0}';
  final match = data.lunarToSolar[key];
  if (match == null) {
    throw ManseryeokException(
      ManseryeokErrorCode.dataError,
      'Unsupported lunar date: $key',
    );
  }
  return SolarDate(year: match[0], month: match[1], day: match[2]);
}
