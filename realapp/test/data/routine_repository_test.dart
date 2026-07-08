import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/routine_repository.dart';

void main() {
  late AppDatabase db;
  late RoutineRepository repository;
  const userId = 'user_local';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = RoutineRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('완료 상태는 저장되고 재조회된다 (재실행 유지)', () async {
    final day = DateTime(2026, 7, 7, 9, 30);
    final firstOfDay = await repository.completeRoutine(
      userId: userId,
      templateId: 'routine_water_drink_water',
      date: day,
    );
    expect(firstOfDay, isTrue);

    final logs = await repository.logsOn(userId, day);
    expect(logs, hasLength(1));
    expect(logs.first.completed, isTrue);

    // 두 번째 루틴은 firstOfDay가 아니다.
    final second = await repository.completeRoutine(
      userId: userId,
      templateId: 'routine_wood_plan_three',
      date: day,
    );
    expect(second, isFalse);
    expect(await repository.completedCountOn(userId, day), 2);
  });

  test('연속 완료는 스트릭을 잇고, 건너뛰면 1부터 다시 시작한다', () async {
    Future<void> complete(DateTime day) => repository.completeRoutine(
      userId: userId,
      templateId: 'routine_water_drink_water',
      date: day,
    );

    await complete(DateTime(2026, 7, 7));
    await complete(DateTime(2026, 7, 8));
    var streak = await repository.streakOf(userId);
    expect(streak!.currentStreak, 2);
    expect(streak.longestStreak, 2);

    // 7/9 건너뛰고 7/10 완료 → 다시 1, longest 유지.
    await complete(DateTime(2026, 7, 10));
    streak = await repository.streakOf(userId);
    expect(streak!.currentStreak, 1);
    expect(streak.longestStreak, 2);
  });

  test('기기 시간을 되돌려 과거 날짜를 완료해도 스트릭은 소급 변경되지 않는다', () async {
    Future<void> complete(DateTime day) => repository.completeRoutine(
      userId: userId,
      templateId: 'routine_water_drink_water',
      date: day,
    );

    await complete(DateTime(2026, 7, 8));
    await complete(DateTime(2026, 7, 7)); // 시간 되돌림

    final streak = await repository.streakOf(userId);
    expect(streak!.currentStreak, 1);
    expect(streak.lastCompletedDate, DateTime(2026, 7, 8));
  });

  test('체크 해제하면 완료 기록이 사라진다 (페널티 없음)', () async {
    final day = DateTime(2026, 7, 7);
    await repository.completeRoutine(
      userId: userId,
      templateId: 'routine_water_drink_water',
      date: day,
    );
    await repository.uncompleteRoutine(
      userId: userId,
      templateId: 'routine_water_drink_water',
      date: day,
    );
    expect(await repository.completedCountOn(userId, day), 0);
  });
}
