import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// 하루 대표 기록 (03 DailyRecord: 감정 기록은 운세 점수와 분리).
class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  static String recordId(String userId, DateTime date) =>
      'record_${userId}_'
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> saveMood({
    required String userId,
    required DateTime date,
    required String mood,
    String? guardianId,
    required DateTime now,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    await _db
        .into(_db.dailyRecords)
        .insertOnConflictUpdate(
          DailyRecordsCompanion.insert(
            id: recordId(userId, day),
            userId: userId,
            date: day,
            mood: Value(mood),
            guardianId: Value(guardianId),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<DailyRecord?> recordOn(String userId, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (_db.select(_db.dailyRecords)
          ..where((t) => t.userId.equals(userId) & t.date.equals(day)))
        .getSingleOrNull();
  }

  /// 최근 기록 (기록 캘린더 기본 화면용, 최신순).
  Future<List<DailyRecord>> recent(String userId, {int limit = 30}) {
    return (_db.select(_db.dailyRecords)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .get();
  }
}
