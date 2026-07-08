import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// 루틴 완료 기록 + 스트릭 (03 RoutineStreak 규칙).
/// 미완료 페널티 없음. 스트릭 끊김은 0에서 다시 시작하되 longest는 유지.
/// 기기 시간을 되돌려도 이미 지난 날짜의 스트릭은 소급 변경되지 않는다.
class RoutineRepository {
  RoutineRepository(this._db);

  final AppDatabase _db;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  static String logId(String userId, DateTime date, String templateId) =>
      'routinelog_${userId}_${_dateKey(date)}_$templateId';

  Future<List<RoutineLog>> logsOn(String userId, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (_db.select(
      _db.routineLogs,
    )..where((t) => t.userId.equals(userId) & t.date.equals(day))).get();
  }

  Future<int> completedCountOn(String userId, DateTime date) async {
    final logs = await logsOn(userId, date);
    return logs.where((l) => l.completed).length;
  }

  /// 완료 체크. 그날 첫 완료면 true (보상 트리거용).
  Future<bool> completeRoutine({
    required String userId,
    required String templateId,
    required DateTime date,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    final before = await completedCountOn(userId, day);

    await _db
        .into(_db.routineLogs)
        .insertOnConflictUpdate(
          RoutineLogsCompanion.insert(
            id: logId(userId, day, templateId),
            userId: userId,
            date: day,
            routineTemplateId: templateId,
            completed: const Value(true),
            completedAt: Value(date),
          ),
        );

    if (before == 0) {
      await _updateStreak(userId, day);
      return true;
    }
    return false;
  }

  /// 체크 해제. 스트릭은 소급 변경하지 않는다 (부담 없는 규칙).
  Future<void> uncompleteRoutine({
    required String userId,
    required String templateId,
    required DateTime date,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    await (_db.delete(
      _db.routineLogs,
    )..where((t) => t.id.equals(logId(userId, day, templateId)))).go();
  }

  Future<RoutineStreak?> streakOf(String userId) {
    return (_db.select(
      _db.routineStreaks,
    )..where((t) => t.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> _updateStreak(String userId, DateTime day) async {
    final existing = await streakOf(userId);
    final last = existing?.lastCompletedDate;

    // 같은 날 재완료 또는 과거 날짜(시간 되돌림)는 스트릭을 바꾸지 않는다.
    if (last != null && !day.isAfter(last)) return;

    final isConsecutive = last != null && day.difference(last).inDays == 1;
    final current = isConsecutive ? (existing!.currentStreak + 1) : 1;
    final longest = existing == null
        ? current
        : (current > existing.longestStreak ? current : existing.longestStreak);

    await _db
        .into(_db.routineStreaks)
        .insertOnConflictUpdate(
          RoutineStreaksCompanion.insert(
            userId: userId,
            currentStreak: Value(current),
            longestStreak: Value(longest),
            lastCompletedDate: Value(day),
          ),
        );
  }
}
