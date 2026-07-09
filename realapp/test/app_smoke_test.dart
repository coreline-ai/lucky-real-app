import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/app/app.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/core/constants/asset_paths.dart';
import 'package:ohaeng_guardians/core/constants/system_ui_styles.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/notifications/application/notification_scheduler.dart';
import 'package:ohaeng_guardians/features/shared/tab_background.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget app({_FakeNotificationPort? notificationPort}) => ProviderScope(
    overrides: [
      engineGatewayProvider.overrideWithValue(const MockEngineGateway()),
      appDatabaseProvider.overrideWithValue(db),
      notificationPortProvider.overrideWithValue(
        notificationPort ?? _FakeNotificationPort(),
      ),
    ],
    child: const OhaengGuardiansApp(),
  );

  Future<void> seedProfile() {
    return ProfileRepository(db).saveProfile(
      nickname: '테스터',
      birthDate: DateTime(1990, 3, 15),
      birthHour: 14,
      birthMinute: 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: GenderMode.male,
      now: DateTime(2026, 7, 7),
    );
  }

  testWidgets('first visit shows onboarding CTA with the 6-tab shell', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('운세'), findsOneWidget);
    expect(find.text('루틴'), findsOneWidget);
    expect(find.text('도감'), findsOneWidget);
    expect(find.text('시장관찰'), findsOneWidget);
    expect(find.text('케미'), findsOneWidget);
    expect(find.text('출생 정보 입력하기'), findsOneWidget);
  });

  testWidgets('app keeps status bar icons readable on light top backgrounds', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnnotatedRegion<SystemUiOverlayStyle> &&
            widget.value == AppSystemUiStyles.lightStatusBar,
      ),
      findsWidgets,
    );
  });

  testWidgets('nickname edit without a profile explains the missing setup', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('닉네임 변경'));
    await tester.pump();

    expect(find.text('닉네임 변경은 출생 정보 입력 후 사용할 수 있어요.'), findsOneWidget);
  });

  testWidgets('onboarding birth info input can leave to home before setup', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('출생 정보 입력하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('출생 정보 입력'), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);
    expect(find.text('나중에 입력하기'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('출생 정보 입력하기'), findsOneWidget);
  });

  testWidgets('onboarding intro backs through pages before leaving', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('출생 정보 입력하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('기록과 도감이 쌓여요'), findsOneWidget);
    expect(find.text('이전'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('나에게 맞는 오행 루틴'), findsOneWidget);

    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 수호신을 만나요'), findsOneWidget);
  });

  testWidgets('first visit tabs keep their own backgrounds before setup', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final expectedBackgrounds = {
      '홈': AssetPaths.homeBackground,
      '운세': AssetPaths.fortuneTabBackground,
      '루틴': AssetPaths.routineTabBackground,
      '도감': AssetPaths.collectionTabBackground,
      '시장관찰': AssetPaths.marketTabBackground,
      '케미': AssetPaths.chemistryResultBackground,
    };
    for (final entry in expectedBackgrounds.entries) {
      await tester.tap(find.text(entry.key).hitTestable());
      await tester.pumpAndSettle();

      final background = tester.widget<TabBackground>(
        find.byType(TabBackground),
      );
      expect(background.imagePath, entry.value, reason: entry.key);
    }
  });

  testWidgets('with a profile, home shows today data from the gateway', (
    tester,
  ) async {
    await seedProfile();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.textContaining('오늘의 일진 '), findsOneWidget);
    expect(find.textContaining('오늘의 수호신'), findsOneWidget);
    expect(find.text('오행 밸런스'), findsOneWidget);
    expect(find.textContaining('보완하면 좋은 포인트'), findsOneWidget);

    // 요약 3종은 첫 화면 아래에 있어 스크롤 후 확인한다.
    await tester.scrollUntilVisible(find.text('행동 조언'), 200);
    expect(find.text('총운'), findsOneWidget);
    expect(find.text('관계운'), findsOneWidget);
    expect(find.text('행동 조언'), findsOneWidget);
  });

  testWidgets('card book frames collection as a free progress record', (
    tester,
  ) async {
    await seedProfile();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('도감').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('수집 현황'), findsOneWidget);
    expect(find.textContaining('천천히 모아요'), findsOneWidget);
    expect(find.textContaining('카드의 기운이 한 겹 더 쌓여요'), findsOneWidget);
  });

  testWidgets('settings birth info edit screen keeps a back affordance', (
    tester,
  ) async {
    await seedProfile();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    expect(find.text('설정'), findsOneWidget);

    await tester.tap(find.text('출생 정보 수정'));
    await tester.pumpAndSettle();

    expect(find.text('출생 정보 수정'), findsOneWidget);
    expect(find.text('테스터'), findsOneWidget);
    expect(find.text('1990년 3월 15일'), findsOneWidget);
    expect(find.text('14시'), findsOneWidget);
    expect(find.text('30분'), findsOneWidget);
    expect(find.text('저장하기'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('settings opens the Coreline-ai license text', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('라이센스'), 300);
    await tester.tap(find.text('라이센스'));
    await tester.pumpAndSettle();

    expect(find.text('Coreline-ai 라이센스'), findsWidgets);
    expect(find.textContaining('MIT License'), findsWidgets);
    expect(find.textContaining('문의: Coreline-ai'), findsOneWidget);
  });

  testWidgets(
    'settings data deletion cancels every scheduled notification id',
    (tester) async {
      final notificationPort = _FakeNotificationPort();
      await seedProfile();
      await tester.pumpWidget(app(notificationPort: notificationPort));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('설정'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('내 데이터 삭제'), 300);
      await tester.tap(find.text('내 데이터 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      expect(notificationPort.cancelled, containsAll([1, 2, 3]));
      expect(notificationPort.cancelled, hasLength(3));
    },
  );

  testWidgets('small screen + large text scale does not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1136); // 320x568 @2x
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await seedProfile();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: app(),
      ),
    );
    await tester.pumpAndSettle();

    // 위젯 테스트는 RenderFlex overflow를 예외로 승격시키므로
    // 여기까지 도달하면 주요 셸 레이아웃이 깨지지 않은 것이다.
    expect(find.text('홈'), findsOneWidget);
  });
}

/// 스모크 테스트용 무동작 알림 포트.
class _FakeNotificationPort implements NotificationPort {
  final List<int> cancelled = [];

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }
}
