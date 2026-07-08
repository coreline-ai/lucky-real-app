import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/daily_fortune_repository.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';

class _CountingGateway implements EngineGateway {
  _CountingGateway(this.inner);

  final EngineGateway inner;
  int analysisCalls = 0;

  @override
  Future<FourPillarsResult> calculateFourPillars(BirthInput input) =>
      inner.calculateFourPillars(input);

  @override
  Future<DailyCycleResult> calculateDailyCycle(DateTime date) =>
      inner.calculateDailyCycle(date);

  @override
  Future<ChemistryAnalysis> calculateChemistry(BirthInput a, BirthInput b) =>
      inner.calculateChemistry(a, b);

  @override
  Future<DailyAnalysisResult> calculateDailyAnalysis(
    BirthInput input,
    DateTime date,
  ) {
    analysisCalls += 1;
    return inner.calculateDailyAnalysis(input, date);
  }
}

void main() {
  late AppDatabase db;
  late _CountingGateway gateway;
  late DailyFortuneRepository repository;
  late BirthProfile profile;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    gateway = _CountingGateway(const MockEngineGateway());
    repository = DailyFortuneRepository(db, gateway);

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
  });

  tearDown(() async {
    await db.close();
  });

  test('same day reuses the cached snapshot (04 캐싱 정책)', () async {
    final today = DateTime(2026, 7, 7);
    final first = await repository.getOrCreateToday(profile, today);
    final second = await repository.getOrCreateToday(profile, today);

    expect(gateway.analysisCalls, 1);
    expect(second.daily.dayPillar.ganji, first.daily.dayPillar.ganji);
  });

  test('date change triggers a fresh calculation (자정 통과)', () async {
    await repository.getOrCreateToday(profile, DateTime(2026, 7, 7));
    await repository.getOrCreateToday(profile, DateTime(2026, 7, 8));

    expect(gateway.analysisCalls, 2);
  });

  test('snapshot ids are deterministic per user per day', () {
    expect(
      DailyFortuneRepository.snapshotId('user_local', DateTime(2026, 7, 7)),
      'reading_user_local_20260707',
    );
  });
}
