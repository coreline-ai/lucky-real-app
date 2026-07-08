import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/app/app.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/core/time/app_clock.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/data/repositories/routine_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';

/// E2E 8단계(루틴 완료 → 홈 배지) 로컬 재현 (02 상태표 "루틴 완료" 상태).
void main() {
  testWidgets('completing a routine shows the home badge', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final clock = const SystemClock();
    final today = clock.todayKst();

    await ProfileRepository(db).saveProfile(
      nickname: '테스터',
      birthDate: DateTime(1990, 3, 15),
      birthHour: 14,
      birthMinute: 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: GenderMode.male,
      now: clock.nowKst(),
    );
    // E2E와 동일하게 nowKst() 전체 시각으로 완료 기록.
    await RoutineRepository(db).completeRoutine(
      userId: 'user_local',
      templateId: 'routine_water_drink_water',
      date: clock.nowKst(),
    );

    expect(
      await RoutineRepository(db).completedCountOn('user_local', today),
      1,
      reason: '저장/조회 날짜 키 불일치 여부 확인',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          engineGatewayProvider.overrideWithValue(const MockEngineGateway()),
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const OhaengGuardiansApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 배지는 홈 ListView 하단(뷰포트 밖)에 있어 스크롤 후 확인한다.
    await tester.scrollUntilVisible(find.textContaining('루틴 1개 완료'), 200);
    expect(find.textContaining('루틴 1개 완료'), findsOneWidget);
  });
}
