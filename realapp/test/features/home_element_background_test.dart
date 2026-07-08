import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/app/app.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/core/constants/asset_paths.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/shared/tab_background.dart';

/// 배경 B안 QA: 오행 5종 각각으로 홈이 렌더되고, 해당 오행 배경이 적용된다
/// (특정 오행에서만 깨지는 케이스 방지).
void main() {
  for (final element in FiveElement.values) {
    testWidgets('home renders with the ${element.name} background', (
      tester,
    ) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await ProfileRepository(db).saveProfile(
        nickname: '테스터',
        birthDate: DateTime(1990, 3, 15),
        birthHour: 14,
        birthMinute: 30,
        calendarType: CalendarType.solar,
        isLeapMonth: false,
        genderMode: GenderMode.male,
        now: DateTime(2026, 7, 8),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            engineGatewayProvider.overrideWithValue(
              _ElementTargetGateway(element),
            ),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const OhaengGuardiansApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('오늘의 수호신 · ${element.korean}'), findsOneWidget);
      final background = tester.widget<TabBackground>(
        find.byType(TabBackground),
      );
      expect(background.imagePath, AssetPaths.elementBackground(element));
    });
  }

  testWidgets('first visit home uses the default background', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

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

    expect(find.text('출생 정보 입력하기'), findsOneWidget);
    final background = tester.widget<TabBackground>(find.byType(TabBackground));
    expect(background.imagePath, AssetPaths.homeBackground);
  });
}

/// 대상 오행이 원국에서 0점(유일 최약)이 되도록 조작한 게이트웨이.
/// 밸런스는 천간 4자 + 지장간만 읽으므로 (element_balance 규칙),
/// 나머지 4개 오행의 대표 천간만 배치하면 수호신 = 대상 오행이 보장된다.
class _ElementTargetGateway extends MockEngineGateway {
  const _ElementTargetGateway(this.target);

  final FiveElement target;

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
