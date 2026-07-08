/// Port of engine/src/engine/core/temporal.ts.
library;

import 'errors.dart';

const int _msPerMinute = 60000;
const int kstOffsetMinutes = 9 * 60;

class DateTimeParts {
  const DateTimeParts({
    required this.year,
    required this.month,
    required this.day,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;

  DateTimeParts copyWith({int? hour, int? minute, int? second}) =>
      DateTimeParts(
        year: year,
        month: month,
        day: day,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        second: second ?? this.second,
      );

  @override
  String toString() => '$year-$month-$day $hour:$minute:$second';
}

int timestampFromUtcParts(DateTimeParts p) {
  final date = DateTime.utc(p.year, p.month, p.day, p.hour, p.minute, p.second);
  final normalized = partsFromUtcTimestamp(date.millisecondsSinceEpoch);
  if (compareDateTime(normalized, p) != 0) {
    throw const ManseryeokException(
      ManseryeokErrorCode.rangeError,
      'Date-time contains invalid UTC calendar fields',
    );
  }
  return date.millisecondsSinceEpoch;
}

DateTimeParts partsFromUtcTimestamp(int timestamp) {
  final d = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
  return DateTimeParts(
    year: d.year,
    month: d.month,
    day: d.day,
    hour: d.hour,
    minute: d.minute,
    second: d.second,
  );
}

DateTimeParts shiftDateTimeUtc(DateTimeParts dateTime, int minutes) {
  return partsFromUtcTimestamp(
    timestampFromUtcParts(dateTime) + minutes * _msPerMinute,
  );
}

int toKstTimestamp(DateTimeParts dateTime) {
  return timestampFromUtcParts(dateTime) - kstOffsetMinutes * _msPerMinute;
}

int compareDateTime(DateTimeParts left, DateTimeParts right) {
  final pairs = [
    (left.year, right.year),
    (left.month, right.month),
    (left.day, right.day),
    (left.hour, right.hour),
    (left.minute, right.minute),
    (left.second, right.second),
  ];
  for (final (l, r) in pairs) {
    if (l < r) return -1;
    if (l > r) return 1;
  }
  return 0;
}

String formatDateKey(DateTimeParts dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
