import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/card_repository.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/cards/application/reward_service.dart';

void main() {
  late AppDatabase db;
  late RewardService service;
  late BirthProfile profile;
  late DailyAnalysisResult analysis;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    service = RewardService(db, CardRepository(db));

    final profiles = ProfileRepository(db);
    await profiles.saveProfile(
      nickname: '테스터',
      birthDate: DateTime(1990, 3, 15),
      birthHour: 14,
      birthMinute: 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: GenderMode.male,
      now: DateTime(2026, 7, 7),
    );
    profile = (await profiles.getActiveBirthProfile())!;
    analysis = await const MockEngineGateway().calculateDailyAnalysis(
      birthInputFromProfile(profile),
      DateTime(2026, 7, 7),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('보상 seed는 재현 가능하다 (같은 입력 → 같은 카드)', () {
    String pick() => RewardService.dailyCardId(
      birthProfileId: 'birth_main',
      date: DateTime(2026, 7, 7),
      todayPillarGanji: '壬午',
      engineVersion: '0.1.0-dart',
    );
    final first = pick();
    for (var i = 0; i < 10; i++) {
      expect(pick(), first);
    }
    expect(first, startsWith('card_element_'));
  });

  test('일일 확인 보상은 날짜당 1회만 지급된다', () async {
    final today = DateTime(2026, 7, 7);
    final first = await service.claimDailyCheckIn(
      profile: profile,
      analysis: analysis,
      today: today,
    );
    final second = await service.claimDailyCheckIn(
      profile: profile,
      analysis: analysis,
      today: today,
    );

    expect(first, isNotNull);
    expect(second, isNull);
  });

  test('기기 시간을 되돌려도 이미 받은 날짜는 중복 지급되지 않는다', () async {
    await service.claimDailyCheckIn(
      profile: profile,
      analysis: analysis,
      today: DateTime(2026, 7, 7),
    );
    await service.claimDailyCheckIn(
      profile: profile,
      analysis: analysis,
      today: DateTime(2026, 7, 8),
    );

    // 시간을 7/7로 되돌린 상황.
    final replay = await service.claimDailyCheckIn(
      profile: profile,
      analysis: analysis,
      today: DateTime(2026, 7, 7),
    );
    expect(replay, isNull);
  });

  test('루틴 완료 보상도 하루 1회, 중복 획득은 count 증가로 처리된다', () async {
    final today = DateTime(2026, 7, 7);
    final first = await service.claimRoutineCompletion(
      profile: profile,
      guardianId: 'guardian_wood_yang',
      today: today,
    );
    expect(first!.cardId, 'card_guardian_wood_yang');
    expect(first.newlyUnlocked, isTrue);

    final sameDay = await service.claimRoutineCompletion(
      profile: profile,
      guardianId: 'guardian_wood_yang',
      today: today,
    );
    expect(sameDay, isNull);

    final nextDay = await service.claimRoutineCompletion(
      profile: profile,
      guardianId: 'guardian_wood_yang',
      today: DateTime(2026, 7, 8),
    );
    expect(nextDay!.newlyUnlocked, isFalse); // 중복 → count 증가
  });

  group('2차 마일스톤 해금 (yin 카드)', () {
    test('스트릭 3일/7일 도달 시 각 1회만 해금 — 재도달·시간 되돌림에도 중복 없음', () async {
      final now = DateTime(2026, 7, 8);

      // 2일: 아무것도 해금 안 됨
      var claims = await service.claimStreakMilestones(
        userId: 'user_local',
        currentStreak: 2,
        now: now,
      );
      expect(claims, isEmpty);

      // 3일: 목 yin 해금
      claims = await service.claimStreakMilestones(
        userId: 'user_local',
        currentStreak: 3,
        now: now,
      );
      expect(claims.single.cardId, 'card_guardian_wood_yin');
      expect(claims.single.newlyUnlocked, isTrue);

      // 같은 3일 재호출(시간 되돌림 가정): 없음
      claims = await service.claimStreakMilestones(
        userId: 'user_local',
        currentStreak: 3,
        now: now,
      );
      expect(claims, isEmpty);

      // 7일: 화 yin만 추가 해금
      claims = await service.claimStreakMilestones(
        userId: 'user_local',
        currentStreak: 7,
        now: now,
      );
      expect(claims.single.cardId, 'card_guardian_fire_yin');
    });

    test('케미 공유 1/2/3회 → 토/금/수 yin 순차 해금', () async {
      final now = DateTime(2026, 7, 8);

      var claims = await service.claimChemistryShareMilestones(
        userId: 'user_local',
        shareCount: 1,
        now: now,
      );
      expect(claims.single.cardId, 'card_guardian_earth_yin');

      claims = await service.claimChemistryShareMilestones(
        userId: 'user_local',
        shareCount: 2,
        now: now,
      );
      expect(claims.single.cardId, 'card_guardian_metal_yin');

      // 3회를 건너뛰고 5회여도 남은 것만 해금
      claims = await service.claimChemistryShareMilestones(
        userId: 'user_local',
        shareCount: 5,
        now: now,
      );
      expect(claims.single.cardId, 'card_guardian_water_yin');

      // 전부 해금 후 재호출: 없음
      claims = await service.claimChemistryShareMilestones(
        userId: 'user_local',
        shareCount: 10,
        now: now,
      );
      expect(claims, isEmpty);
    });
  });
}
