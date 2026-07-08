import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/core/time/app_clock.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/data/repositories/routine_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/home/application/today_fortune_provider.dart';
import 'package:ohaeng_guardians/features/routine/presentation/routine_screen.dart';

void main() {
  late AppDatabase db;
  late _MutableClock clock;
  late ProviderContainer container;

  Widget harness() {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: RoutineScreen()),
    );
  }

  Future<void> saveProfile({DateTime? birthDate}) {
    return ProfileRepository(db).saveProfile(
      nickname: '테스터',
      birthDate: birthDate ?? DateTime(1990, 3, 15),
      birthHour: 14,
      birthMinute: 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: GenderMode.male,
      now: clock.nowKst(),
    );
  }

  CheckboxListTile waterRoutineTile(WidgetTester tester) {
    return tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, '물 한 잔 마시기'),
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = _MutableClock(DateTime(2026, 7, 8, 9));
    container = ProviderContainer(
      overrides: [
        engineGatewayProvider.overrideWithValue(
          const _ProfileSensitiveGateway(),
        ),
        appDatabaseProvider.overrideWithValue(db),
        appClockProvider.overrideWithValue(clock),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('routine state reloads when the KST date changes', (
    tester,
  ) async {
    await saveProfile();
    await RoutineRepository(db).completeRoutine(
      userId: localUserId,
      templateId: 'routine_water_drink_water',
      date: clock.nowKst(),
    );

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(waterRoutineTile(tester).value, isTrue);

    clock.now = DateTime(2026, 7, 9, 9);
    container.invalidate(todayFortuneProvider);
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(waterRoutineTile(tester).value, isFalse);
  });

  testWidgets('routine state reloads after the active birth profile changes', (
    tester,
  ) async {
    await saveProfile();
    await RoutineRepository(db).completeRoutine(
      userId: localUserId,
      templateId: 'routine_water_drink_water',
      date: clock.nowKst(),
    );

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(waterRoutineTile(tester).value, isTrue);

    await saveProfile(birthDate: DateTime(1991, 4, 16));
    await ProfileRepository(db).invalidateSnapshotsFrom(clock.todayKst());
    await RoutineRepository(db).completeRoutine(
      userId: localUserId,
      templateId: 'routine_wood_plan_three',
      date: clock.nowKst(),
    );
    container.invalidate(activeBirthProfileProvider);
    container.invalidate(todayFortuneProvider);
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    final woodRoutine = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, '오늘 할 일 3개 적기'),
    );
    expect(woodRoutine.value, isTrue);
  });
}

class _MutableClock implements AppClock {
  _MutableClock(this.now);

  DateTime now;

  @override
  DateTime nowKst() => now;
}

class _ProfileSensitiveGateway extends MockEngineGateway {
  const _ProfileSensitiveGateway();

  static const _gans = {
    FiveElement.wood: '甲',
    FiveElement.fire: '丙',
    FiveElement.earth: '戊',
    FiveElement.metal: '庚',
    FiveElement.water: '壬',
  };

  @override
  Future<FourPillarsResult> calculateFourPillars(BirthInput input) async {
    final base = await super.calculateFourPillars(input);
    final target = input.year == 1991 ? FiveElement.wood : FiveElement.water;
    final others = FiveElement.values
        .where((e) => e != target)
        .map((e) => _gans[e]!)
        .toList();
    return FourPillarsResult(
      meta: base.meta,
      year: Pillar(gan: others[0], ji: '午'),
      month: Pillar(gan: others[1], ji: '未'),
      day: Pillar(gan: others[2], ji: '申'),
      hour: Pillar(gan: others[3], ji: '酉'),
      dayMaster: others[2],
      sipsin: base.sipsin,
      jijanggan: {
        'yearJi': [others[0]],
        'monthJi': [others[1]],
        'dayJi': [others[2]],
        'hourJi': [others[3]],
      },
      jijangganSipsin: base.jijangganSipsin,
    );
  }
}
