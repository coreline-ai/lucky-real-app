/// Port of engine/src/engine/core/korean-legal-time.ts.
///
/// Standard-time and DST rules are source-cited in
/// engine/docs/engine/korean-legal-time-policy.md. Intervals are local civil
/// labels, [start, end).
library;

import 'errors.dart';
import 'temporal.dart';

class KoreanLegalTimeResolution {
  const KoreanLegalTimeResolution({
    required this.standardOffsetMinutes,
    required this.daylightOffsetMinutes,
  });

  final int standardOffsetMinutes;
  final int daylightOffsetMinutes;

  int get totalOffsetMinutes => standardOffsetMinutes + daylightOffsetMinutes;
  double get standardMeridianDegrees => standardOffsetMinutes / 4;
  bool get isDaylight => daylightOffsetMinutes != 0;
}

class _StandardRule {
  const _StandardRule(this.start, this.end, this.offsetMinutes);
  final DateTimeParts start;
  final DateTimeParts? end;
  final int offsetMinutes;
}

class _DstRule {
  const _DstRule(this.start, this.end, this.offsetMinutes);
  final DateTimeParts start;
  final DateTimeParts end;
  final int offsetMinutes;
}

DateTimeParts _p(int y, int m, int d, [int h = 0, int min = 0]) =>
    DateTimeParts(year: y, month: m, day: d, hour: h, minute: min);

final List<_StandardRule> _standardRules = [
  _StandardRule(_p(1908, 4, 1), _p(1912, 1, 1), 510),
  _StandardRule(_p(1912, 1, 1), _p(1954, 3, 21), 540),
  _StandardRule(_p(1954, 3, 21), _p(1961, 8, 10), 510),
  _StandardRule(_p(1961, 8, 10, 0, 30), _p(1987, 1, 1), 540),
  _StandardRule(_p(1987, 1, 1), _p(1989, 1, 1), 540),
  _StandardRule(_p(1989, 1, 1), null, 540),
];

final List<_DstRule> _dstRules = [
  _DstRule(_p(1948, 6, 1), _p(1948, 9, 13), 60),
  _DstRule(_p(1949, 4, 3), _p(1949, 9, 11), 60),
  _DstRule(_p(1950, 4, 1), _p(1950, 9, 10), 60),
  _DstRule(_p(1951, 5, 6), _p(1951, 9, 9), 60),
  _DstRule(_p(1955, 5, 5), _p(1955, 9, 9), 60),
  _DstRule(_p(1956, 5, 20), _p(1956, 9, 30), 60),
  _DstRule(_p(1957, 5, 5), _p(1957, 9, 22), 60),
  _DstRule(_p(1958, 5, 4), _p(1958, 9, 21), 60),
  _DstRule(_p(1959, 5, 3), _p(1959, 9, 20), 60),
  _DstRule(_p(1960, 5, 1), _p(1960, 9, 18), 60),
  _DstRule(_p(1987, 5, 10, 2), _p(1987, 10, 11, 3), 60),
  _DstRule(_p(1988, 5, 8, 2), _p(1988, 10, 9, 3), 60),
];

bool _isInInterval(DateTimeParts t, DateTimeParts start, DateTimeParts? end) {
  return compareDateTime(t, start) >= 0 &&
      (end == null || compareDateTime(t, end) < 0);
}

void _assertSupportedStandardTransitionLabel(DateTimeParts t) {
  if (_isInInterval(t, _p(1954, 3, 21), _p(1954, 3, 21, 0, 30))) {
    throw const ManseryeokException(
      ManseryeokErrorCode.ambiguousCivilTime,
      'Korean civil time label is repeated by the 1954 standard-time transition',
    );
  }
  if (_isInInterval(t, _p(1961, 8, 10), _p(1961, 8, 10, 0, 30))) {
    throw const ManseryeokException(
      ManseryeokErrorCode.nonexistentCivilTime,
      'Korean civil time label is skipped by the 1961 standard-time transition',
    );
  }
}

_StandardRule _findStandardRule(DateTimeParts t) {
  for (final rule in _standardRules) {
    if (_isInInterval(t, rule.start, rule.end)) return rule;
  }
  throw const ManseryeokException(
    ManseryeokErrorCode.policyError,
    'Korean legal time is not defined before the 1908 standard-time policy interval',
  );
}

_DstRule? _findDstRule(DateTimeParts t) {
  for (final rule in _dstRules) {
    final nonexistentEnd = shiftDateTimeUtc(rule.start, rule.offsetMinutes);
    final ambiguousStart = shiftDateTimeUtc(rule.end, -rule.offsetMinutes);
    if (_isInInterval(t, rule.start, nonexistentEnd) ||
        _isInInterval(t, ambiguousStart, rule.end) ||
        _isInInterval(t, nonexistentEnd, ambiguousStart)) {
      return rule;
    }
  }
  return null;
}

void _assertSupportedDstLabel(DateTimeParts t, _DstRule rule) {
  final nonexistentEnd = shiftDateTimeUtc(rule.start, rule.offsetMinutes);
  if (_isInInterval(t, rule.start, nonexistentEnd)) {
    throw const ManseryeokException(
      ManseryeokErrorCode.nonexistentCivilTime,
      'Korean civil time label is skipped by a daylight-saving transition',
    );
  }
  final ambiguousStart = shiftDateTimeUtc(rule.end, -rule.offsetMinutes);
  if (_isInInterval(t, ambiguousStart, rule.end)) {
    throw const ManseryeokException(
      ManseryeokErrorCode.ambiguousCivilTime,
      'Korean civil time label is repeated by a daylight-saving transition',
    );
  }
}

KoreanLegalTimeResolution resolveKoreanLegalTime(DateTimeParts dateTime) {
  _assertSupportedStandardTransitionLabel(dateTime);
  final standardRule = _findStandardRule(dateTime);
  final dstRule = _findDstRule(dateTime);
  if (dstRule != null) {
    _assertSupportedDstLabel(dateTime, dstRule);
  }
  return KoreanLegalTimeResolution(
    standardOffsetMinutes: standardRule.offsetMinutes,
    daylightOffsetMinutes: dstRule?.offsetMinutes ?? 0,
  );
}
