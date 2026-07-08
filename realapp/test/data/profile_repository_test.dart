import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ProfileRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> save({String nickname = '테스터', int? hour = 14}) {
    return repository.saveProfile(
      nickname: nickname,
      birthDate: DateTime(1990, 3, 15),
      birthHour: hour,
      birthMinute: hour == null ? null : 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: null,
      now: DateTime(2026, 7, 7),
    );
  }

  test('save then read the active birth profile', () async {
    expect(await repository.getActiveBirthProfile(), isNull);

    await save();
    final profile = await repository.getActiveBirthProfile();
    expect(profile, isNotNull);
    expect(profile!.displayName, '테스터');
    expect(profile.birthTimeKnown, isTrue);
    expect(profile.genderMode, isNull);
  });

  test('re-saving updates the same profile (출생정보 수정)', () async {
    await save();
    await save(nickname: '수정됨', hour: null);

    final profile = await repository.getActiveBirthProfile();
    expect(profile!.displayName, '수정됨');
    expect(profile.birthTimeKnown, isFalse);
    expect(profile.birthHour, isNull);
  });

  test('birthInputFromProfile maps the row to the contract input', () async {
    await save(hour: null);
    final profile = await repository.getActiveBirthProfile();
    final input = birthInputFromProfile(profile!);

    expect(input.year, 1990);
    expect(input.hour, isNull);
    expect(input.birthTimeKnown, isFalse);
    expect(input.calendarType, CalendarType.solar);
    expect(input.genderMode, isNull);
  });

  test('deleteAllData clears every table', () async {
    await save();
    await repository.deleteAllData();

    expect(await repository.getActiveBirthProfile(), isNull);
    expect(await repository.getUserProfile(), isNull);
  });
}
