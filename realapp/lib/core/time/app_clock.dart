/// App-wide clock abstraction.
///
/// All "today" decisions go through this so tests can pin the date and the
/// midnight-rollover rule (Asia/Seoul) stays in one place.
abstract interface class AppClock {
  DateTime nowKst();
}

/// KST is UTC+9 with no DST, so a fixed offset is correct for Asia/Seoul.
class SystemClock implements AppClock {
  const SystemClock();

  static const Duration _kstOffset = Duration(hours: 9);

  @override
  DateTime nowKst() => DateTime.now().toUtc().add(_kstOffset);
}

/// Calendar date (no time) used as the app's "today" key.
extension KstDate on AppClock {
  DateTime todayKst() {
    final now = nowKst();
    return DateTime(now.year, now.month, now.day);
  }
}
