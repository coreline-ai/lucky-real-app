import 'dart:convert';

import 'package:drift/drift.dart';

import '../../engine/gateway/models.dart';
import '../local/app_database.dart';

/// 케미 상대 프로필 + 결과 캐시 (03 ChemistryProfile/Result).
/// 상대 프로필 삭제 시 연결된 결과도 함께 삭제한다 (03 무결성 규칙).
class ChemistryRepository {
  ChemistryRepository(this._db);

  final AppDatabase _db;

  Future<List<ChemistryProfile>> partners(String ownerUserId) {
    return (_db.select(_db.chemistryProfiles)
          ..where((t) => t.ownerUserId.equals(ownerUserId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<ChemistryProfile?> partnerById(String id) {
    return (_db.select(
      _db.chemistryProfiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> addPartner({
    required String ownerUserId,
    required String label,
    required String relationType,
    required DateTime birthDate,
    required int? birthHour,
    required int? birthMinute,
    required CalendarType calendarType,
    required bool isLeapMonth,
    required DateTime now,
  }) async {
    final id = 'chemistry_${now.microsecondsSinceEpoch}';
    await _db
        .into(_db.chemistryProfiles)
        .insert(
          ChemistryProfilesCompanion.insert(
            id: id,
            ownerUserId: ownerUserId,
            label: label,
            relationType: relationType,
            birthDate: birthDate,
            birthHour: Value(birthHour),
            birthMinute: Value(birthMinute),
            calendarType: calendarType.name,
            isLeapMonth: Value(isLeapMonth),
            createdAt: now,
          ),
        );
    return id;
  }

  /// 상대 삭제 + 연결 결과 정리 (03 무결성).
  Future<void> deletePartner(String partnerId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.chemistryResults,
      )..where((t) => t.partnerProfileId.equals(partnerId))).go();
      await (_db.delete(
        _db.chemistryProfiles,
      )..where((t) => t.id.equals(partnerId))).go();
    });
  }

  Future<ChemistryAnalysis?> cachedResult(
    String ownerUserId,
    String partnerId,
    String engineVersion,
  ) async {
    final row =
        await (_db.select(_db.chemistryResults)..where(
              (t) => t.id.equals('chemresult_${ownerUserId}_$partnerId'),
            ))
            .getSingleOrNull();
    if (row == null || row.engineVersion != engineVersion) return null;
    return ChemistryAnalysis.fromJson(
      jsonDecode(row.payloadJson) as Map<String, dynamic>,
    );
  }

  Future<void> saveResult({
    required String ownerUserId,
    required String partnerId,
    required ChemistryAnalysis analysis,
    required DateTime now,
  }) async {
    await _db
        .into(_db.chemistryResults)
        .insertOnConflictUpdate(
          ChemistryResultsCompanion.insert(
            id: 'chemresult_${ownerUserId}_$partnerId',
            ownerUserId: ownerUserId,
            partnerProfileId: partnerId,
            payloadJson: jsonEncode(analysis.toJson()),
            engineVersion: analysis.meta.engineVersion,
            calculatedAt: now,
          ),
        );
  }
}

/// drift row → 엔진 계약 입력.
BirthInput birthInputFromPartner(ChemistryProfile partner) {
  return BirthInput(
    year: partner.birthDate.year,
    month: partner.birthDate.month,
    day: partner.birthDate.day,
    hour: partner.birthHour,
    minute: partner.birthMinute,
    calendarType: partner.calendarType == 'lunar'
        ? CalendarType.lunar
        : CalendarType.solar,
    isLeapMonth: partner.isLeapMonth,
  );
}
