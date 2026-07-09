import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/core/time/app_clock.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/market_repository.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/market/application/market_providers.dart';
import 'package:ohaeng_guardians/features/market/presentation/market_observation_screen.dart';

void main() {
  Future<void> pumpAsyncWork(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
  }

  Finder searchField() => find.byKey(const Key('market-search-field')).last;

  Future<void> showSearchField(WidgetTester tester) async {
    await tester.tap(find.byTooltip('종목 검색'));
    await tester.pumpAndSettle();
  }

  Future<void> closeSearchSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip('검색 닫기'));
    await tester.pumpAndSettle();
  }

  Future<void> addSamsung(WidgetTester tester) async {
    await showSearchField(tester);
    await tester.enterText(searchField(), '삼성전자');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpAsyncWork(tester);
    await tester.tap(find.byTooltip('관심종목 추가').first);
    await pumpAsyncWork(tester);
    await closeSearchSheet(tester);
  }

  Widget app(AppDatabase db) => ProviderScope(
    overrides: [
      engineGatewayProvider.overrideWithValue(const MockEngineGateway()),
      appDatabaseProvider.overrideWithValue(db),
      appClockProvider.overrideWithValue(_FixedClock(DateTime(2026, 7, 8, 9))),
      marketMasterImportProvider.overrideWith(
        (ref) async => const MarketImportSummary(
          sourceName: 'test',
          baseDate: '2026-07-08',
          count: 3,
        ),
      ),
    ],
    child: const MaterialApp(home: MarketObservationScreen()),
  );

  String fixtureJson() => '''
{
  "schemaVersion": 1,
  "source": {
    "name": "test",
    "url": "fixture",
    "baseDate": "2026-07-08",
    "generatedAt": "2026-07-08"
  },
  "instruments": [
    {
      "baseDate": "2026-07-08",
      "corpName": "삼성전자",
      "id": "KRX:KOSPI:005930",
      "isin": "KR7005930003",
      "market": "KOSPI",
      "name": "삼성전자",
      "normalizedName": "삼성전자",
      "source": "test",
      "symbol": "005930",
      "updatedAt": "2026-07-08"
    },
    {
      "baseDate": "2026-07-08",
      "corpName": "삼성SDI",
      "id": "KRX:KOSPI:006400",
      "isin": "KR7006400006",
      "market": "KOSPI",
      "name": "삼성SDI",
      "normalizedName": "삼성SDI",
      "source": "test",
      "symbol": "006400",
      "updatedAt": "2026-07-08"
    },
    {
      "baseDate": "2026-07-08",
      "corpName": "NAVER",
      "id": "KRX:KOSPI:035420",
      "isin": "KR7035420009",
      "market": "KOSPI",
      "name": "NAVER",
      "normalizedName": "NAVER",
      "source": "test",
      "symbol": "035420",
      "updatedAt": "2026-07-08"
    }
  ]
}
''';

  Future<void> seedProfile(AppDatabase db) {
    return ProfileRepository(db).saveProfile(
      nickname: '테스터',
      birthDate: DateTime(1990, 3, 15),
      birthHour: 14,
      birthMinute: 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: GenderMode.male,
      now: DateTime(2026, 7, 8),
    );
  }

  testWidgets('market tab asks for birth info before setup', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();

    expect(find.text('출생 정보 입력하기'), findsOneWidget);
    expect(find.textContaining('관찰 리듬'), findsOneWidget);
    expect(find.text('오락과 자기점검용 참고 정보예요.'), findsOneWidget);
  });

  testWidgets('searching 삼 can add 삼성전자 as an observation item', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedProfile(db);
    await MarketRepository(db).importFromAssetJson(fixtureJson());

    await tester.pumpWidget(app(db));
    await pumpAsyncWork(tester);

    await showSearchField(tester);
    await tester.enterText(searchField(), '삼성전자');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpAsyncWork(tester);
    await tester.tap(find.byTooltip('관심종목 추가').first);
    await pumpAsyncWork(tester);

    expect(find.text('추가됨'), findsWidgets);

    await closeSearchSheet(tester);

    expect(find.text('내 관심종목'), findsOneWidget);
    expect(find.text('삼성전자'), findsWidgets);
    expect(find.textContaining('이름 오행'), findsNothing);
    expect(find.textContaining('관찰 준비도'), findsOneWidget);
    expect(
      find.textContaining(RegExp('기록부터 시작|체크 후 관찰|우선 관찰|오늘의 핵심 관찰')),
      findsOneWidget,
    );
  });

  testWidgets('checklist changes the displayed observation readiness', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedProfile(db);
    await MarketRepository(db).importFromAssetJson(fixtureJson());

    await tester.pumpWidget(app(db));
    await pumpAsyncWork(tester);
    await addSamsung(tester);

    final before = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).last,
        )
        .value;
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckboxListTile).first);
    await tester.pump();
    await tester.tap(find.byType(CheckboxListTile).first);
    await pumpAsyncWork(tester);
    final after = tester
        .widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).last,
        )
        .value;

    expect(before, isNot(after));
    expect(find.text('관찰 전 점검 1/4'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(4));
  });

  testWidgets('today checklist is restored after reopening the screen', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedProfile(db);
    await MarketRepository(db).importFromAssetJson(fixtureJson());

    await tester.pumpWidget(app(db));
    await pumpAsyncWork(tester);
    await addSamsung(tester);

    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).first);
    await pumpAsyncWork(tester);

    await tester.pumpWidget(app(db));
    await pumpAsyncWork(tester);
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    final restored = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile).first,
    );
    expect(restored.value, isTrue);
  });

  testWidgets('example chips fill the search field and clear can reset it', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedProfile(db);
    await MarketRepository(db).importFromAssetJson(fixtureJson());

    await tester.pumpWidget(app(db));
    await pumpAsyncWork(tester);

    await showSearchField(tester);
    final codeChip = find.byKey(const Key('market-example-chip-005930')).last;
    await tester.tap(codeChip);
    await pumpAsyncWork(tester);

    expect(find.text('삼성전자'), findsWidgets);

    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pump();

    expect(find.text('한 글자부터 종목명이나 코드를 찾아볼 수 있어요.'), findsOneWidget);
  });

  testWidgets('watch item memo and keywords can be edited from the card', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await seedProfile(db);
    await MarketRepository(db).importFromAssetJson(fixtureJson());

    await tester.pumpWidget(app(db));
    await pumpAsyncWork(tester);
    await addSamsung(tester);

    await tester.ensureVisible(find.textContaining('관찰 준비도'));
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();
    final editButton = find.widgetWithText(OutlinedButton, '메모/키워드');
    await tester.ensureVisible(editButton);
    await tester.pumpAndSettle();
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('market-watch-keyword-information')));
    await tester.enterText(
      find.byKey(const Key('market-watch-memo-field')),
      '내 기준 기록',
    );
    await tester.tap(find.byKey(const Key('market-watch-save')));
    await pumpAsyncWork(tester);

    if (find.text('메모: 내 기준 기록').evaluate().isEmpty) {
      await tester.ensureVisible(find.byType(ExpansionTile).first);
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
    }

    expect(find.text('메모: 내 기준 기록'), findsOneWidget);
    expect(find.widgetWithText(InputChip, '정보'), findsOneWidget);
  });

  testWidgets(
    'delete button asks for confirmation before removing a watch item',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await seedProfile(db);
      await MarketRepository(db).importFromAssetJson(fixtureJson());

      await tester.pumpWidget(app(db));
      await pumpAsyncWork(tester);
      await addSamsung(tester);

      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('삭제'));
      await tester.tap(find.byTooltip('삭제'));
      await tester.pumpAndSettle();

      expect(find.text('삭제할까요?'), findsOneWidget);
      expect(find.text('관심종목에서 삼성전자 삭제를 진행할까요?'), findsOneWidget);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(find.text('삼성전자'), findsWidgets);

      await tester.ensureVisible(find.byTooltip('삭제'));
      await tester.tap(find.byTooltip('삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '삭제'));
      await pumpAsyncWork(tester);

      expect(find.text('아직 관심종목이 없어요.'), findsOneWidget);
    },
  );
}

class _FixedClock implements AppClock {
  const _FixedClock(this.now);

  final DateTime now;

  @override
  DateTime nowKst() => now;
}
