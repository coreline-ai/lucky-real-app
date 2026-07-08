import 'dart:convert';

import 'package:drift/drift.dart';

import '../../engine/gateway/engine_gateway.dart';
import '../../engine/gateway/models.dart';
import '../local/app_database.dart';
import 'profile_repository.dart';

/// 오늘 계산 결과 캐시 (04 캐싱 정책).
/// - 같은 날짜·같은 엔진 버전이면 스냅샷 재사용
/// - 날짜가 바뀌면 새로 계산 (자정 통과 포함 — 호출 시점의 today 기준)
/// - 엔진 버전이 바뀌면 재계산
class DailyFortuneRepository {
  DailyFortuneRepository(this._db, this._gateway);

  final AppDatabase _db;
  final EngineGateway _gateway;

  static String snapshotId(String userId, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'reading_${userId}_$y$m$d';
  }

  /// 해당 날짜 스냅샷에 기록된 수호신 (다양성 보정용).
  Future<String?> guardianIdOn(String userId, DateTime date) async {
    final row = await (_db.select(
      _db.dailySnapshots,
    )..where((t) => t.id.equals(snapshotId(userId, date)))).getSingleOrNull();
    return row?.guardianId;
  }

  Future<void> saveGuardianId(
    String userId,
    DateTime date,
    String guardianId,
  ) async {
    await (_db.update(_db.dailySnapshots)
          ..where((t) => t.id.equals(snapshotId(userId, date))))
        .write(DailySnapshotsCompanion(guardianId: Value(guardianId)));
  }

  Future<DailyAnalysisResult> getOrCreateToday(
    BirthProfile profile,
    DateTime today,
  ) async {
    final date = DateTime(today.year, today.month, today.day);
    final id = snapshotId(profile.userId, date);

    final cached = await (_db.select(
      _db.dailySnapshots,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (cached != null) {
      final analysis = DailyAnalysisResult.fromJson(
        jsonDecode(cached.payloadJson) as Map<String, dynamic>,
      );
      if (analysis.meta.engineVersion == cached.engineVersion) {
        return analysis;
      }
    }

    final analysis = await _gateway.calculateDailyAnalysis(
      birthInputFromProfile(profile),
      date,
    );

    try {
      await _db
          .into(_db.dailySnapshots)
          .insertOnConflictUpdate(
            DailySnapshotsCompanion.insert(
              id: id,
              userId: profile.userId,
              birthProfileId: profile.id,
              date: date,
              payloadJson: jsonEncode(analysis.toJson()),
              engineVersion: analysis.meta.engineVersion,
              ruleVersion: analysis.meta.ruleVersion,
              createdAt: date,
            ),
          );
    } on Exception {
      // 저장 실패해도 계산 결과(임시 결과)는 사용자에게 보여준다
      // (02 오류 상태: 저장 실패 → 임시 결과 유지). 다음 조회 때 재계산된다.
    }

    return analysis;
  }
}
