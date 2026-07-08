import 'package:drift/drift.dart';

import '../../engine/gateway/models.dart';
import '../local/app_database.dart';

/// MVP는 기기당 사용자 1명이므로 고정 로컬 ID를 사용한다
/// (서버/계정 도입 시 UUID로 마이그레이션).
const String localUserId = 'user_local';
const String localBirthProfileId = 'birth_main';

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Future<BirthProfile?> getActiveBirthProfile() {
    return (_db.select(
      _db.birthProfiles,
    )..where((t) => t.id.equals(localBirthProfileId))).getSingleOrNull();
  }

  Future<UserProfile?> getUserProfile() {
    return (_db.select(
      _db.userProfiles,
    )..where((t) => t.id.equals(localUserId))).getSingleOrNull();
  }

  Future<void> saveProfile({
    required String nickname,
    required DateTime birthDate,
    required int? birthHour,
    required int? birthMinute,
    required CalendarType calendarType,
    required bool isLeapMonth,
    required GenderMode? genderMode,
    required DateTime now,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.userProfiles)
          .insertOnConflictUpdate(
            UserProfilesCompanion.insert(
              id: localUserId,
              nickname: nickname,
              birthProfileId: localBirthProfileId,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db
          .into(_db.birthProfiles)
          .insertOnConflictUpdate(
            BirthProfilesCompanion.insert(
              id: localBirthProfileId,
              userId: localUserId,
              displayName: nickname,
              birthDate: birthDate,
              birthHour: Value(birthHour),
              birthMinute: Value(birthMinute),
              birthTimeKnown: birthHour != null && birthMinute != null,
              calendarType: calendarType.name,
              isLeapMonth: Value(isLeapMonth),
              genderMode: Value(genderMode?.name),
              createdAt: now,
            ),
          );
    });
  }

  Future<void> updateNickname(String nickname) async {
    await _db.transaction(() async {
      await (_db.update(_db.userProfiles)
            ..where((t) => t.id.equals(localUserId)))
          .write(UserProfilesCompanion(nickname: Value(nickname)));
      await (_db.update(_db.birthProfiles)
            ..where((t) => t.id.equals(localBirthProfileId)))
          .write(BirthProfilesCompanion(displayName: Value(nickname)));
    });
  }

  /// 출생정보 수정 시 오늘 스냅샷만 무효화한다.
  /// 과거 기록은 계산 당시 버전 기준으로 보존한다 (03 데이터 무결성).
  Future<void> invalidateSnapshotsFrom(DateTime date) async {
    await (_db.delete(
      _db.dailySnapshots,
    )..where((t) => t.date.isBiggerOrEqualValue(date))).go();
  }

  /// 설정 > 데이터 삭제.
  Future<void> deleteAllData() async {
    await _db.transaction(() async {
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
    });
  }
}

/// drift row → 엔진 계약 입력.
BirthInput birthInputFromProfile(BirthProfile profile) {
  return BirthInput(
    year: profile.birthDate.year,
    month: profile.birthDate.month,
    day: profile.birthDate.day,
    hour: profile.birthHour,
    minute: profile.birthMinute,
    calendarType: profile.calendarType == 'lunar'
        ? CalendarType.lunar
        : CalendarType.solar,
    isLeapMonth: profile.isLeapMonth,
    genderMode: switch (profile.genderMode) {
      'male' => GenderMode.male,
      'female' => GenderMode.female,
      _ => null,
    },
  );
}
