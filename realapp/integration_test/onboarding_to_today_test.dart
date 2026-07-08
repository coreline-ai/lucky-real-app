import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ohaeng_guardians/app/app.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/data/local/open_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/dart_engine_gateway.dart';

/// Phase 6 E2E (06 로드맵): 온보딩 → 첫 수호신 → 홈 → 루틴 완료 → 카드 획득.
/// 실기기에서 실제 Dart 엔진 + 실제 DB로 실행한다.
///
/// 실기기에서는 스피너 등 무한 애니메이션 때문에 pumpAndSettle이
/// 타임아웃되므로, 기대 위젯이 나타날 때까지 pump하는 방식으로 대기한다.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('pumpUntil timeout: $finder');
  }

  /// 라우트 전환 애니메이션 중에는 위젯 지오메트리가 이동 중이라 탭이
  /// 빗나갈 수 있다. 시간을 충분히 진행시켜 전환을 끝낸 뒤 탭한다.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('onboarding to first card E2E', (tester) async {
    final gateway = await DartEngineGateway.load(rootBundle.loadString);
    final database = openAppDatabase();
    // 항상 신규 사용자 상태에서 시작한다.
    await ProfileRepository(database).deleteAllData();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          engineGatewayProvider.overrideWithValue(gateway),
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const OhaengGuardiansApp(),
      ),
    );

    // 1) 첫 방문 홈 → 온보딩 진입
    await pumpUntil(tester, find.text('출생 정보 입력하기'));
    await tester.tap(find.text('출생 정보 입력하기'));

    // 2) 소개 3장 넘기기
    await pumpUntil(tester, find.text('다음'));
    await tester.tap(find.text('다음'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('다음'));
    await pumpUntil(tester, find.text('시작하기'));
    await tester.tap(find.text('시작하기'));

    // 3) 출생정보 입력
    await pumpUntil(tester, find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField).first, '베타테스터');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('생년월일 선택'));
    await pumpUntil(tester, find.text('OK'));
    await tester.tap(find.text('OK'));
    await pumpUntil(tester, find.textContaining('1995년'));

    await tester.ensureVisible(find.text('저장하고 시작하기'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('저장하고 시작하기'));

    // 4) 첫 수호신 공개 (도감에 첫 카드 저장)
    await pumpUntil(tester, find.textContaining('오늘 수호신'));
    await pumpUntil(tester, find.text('첫 카드가 도감에 저장됐어요.'));
    await tester.tap(find.text('오늘의 루틴 보러 가기'));

    // 5) 홈: 오늘 데이터 표시
    await pumpUntil(tester, find.textContaining('오늘의 일진 '));
    expect(find.text('오행 밸런스'), findsOneWidget);

    // 6) 루틴 탭 → 첫 루틴 완료
    await tester.tap(find.text('루틴'));
    await pumpUntil(tester, find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pump(const Duration(seconds: 1));

    // 7) 도감: 카드 + 진행률
    await tester.tap(find.text('도감'));
    await pumpUntil(tester, find.textContaining('/15')); // 2차: 도감 15종
    expect(find.text('???'), findsWidgets); // 아직 못 모은 카드 존재

    // 8) 홈 복귀: 루틴 완료 상태 배지 (ListView 하단이라 스크롤 후 확인)
    await tester.tap(find.text('홈'));
    await pumpUntil(tester, find.textContaining('오늘의 일진 '));
    await tester.scrollUntilVisible(find.textContaining('루틴 1개 완료'), 300);
    expect(find.textContaining('루틴 1개 완료'), findsOneWidget);

    // 9) 케미 (2차): 상대 추가 → 결과 → 공유 미리보기 → 취소 복귀
    // 루틴 보상 스낵바가 하단 탭/FAB를 덮을 수 있어 먼저 소멸을 기다린다.
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.text('케미').hitTestable());
    // IndexedStack의 offstage 사본을 피하기 위해 히트 가능한 FAB만 기다린다.
    await pumpUntil(tester, find.byType(FloatingActionButton).hitTestable());
    await tester.tap(find.byType(FloatingActionButton).hitTestable());
    debugPrint('[E2E] step9: partner form opened');
    await pumpUntil(tester, find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField).first, '단짝');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('생년월일 선택'));
    await pumpUntil(tester, find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pump(const Duration(milliseconds: 300));
    debugPrint('[E2E] step9: birth date picked');
    await tester.ensureVisible(find.text('케미 보러 가기'));
    await tester.tap(find.text('케미 보러 가기'));

    // 결과 화면: 점수 표시 + 참고 콘텐츠 고지
    await pumpUntil(tester, find.textContaining('점'));
    expect(find.textContaining('잘 맞는 점'), findsOneWidget);
    await settle(tester);
    debugPrint('[E2E] step9: result screen shown');

    // 공유 미리보기: 민감정보 미포함 플로우 진입·취소
    await tester.tap(find.byIcon(Icons.ios_share).hitTestable().first);
    await pumpUntil(tester, find.text('공유 미리보기'));
    await settle(tester);
    // 미리보기 body는 lazy ListView라 카드 아래 컨트롤은 스크롤 후 빌드된다.
    await tester.scrollUntilVisible(find.text('이대로 공유하기'), 300);
    expect(find.text('내 닉네임 표시'), findsOneWidget);
    debugPrint('[E2E] step9: share preview shown');
    await tester.pageBack();
    await pumpUntil(tester, find.textContaining('잘 맞는 점').hitTestable());
    await settle(tester);
    debugPrint('[E2E] step9: back to result');
    await tester.pageBack();

    // 케미 목록에 상대 존재
    await pumpUntil(tester, find.text('단짝').hitTestable());
    debugPrint('[E2E] step9: done');

    await database.close();
  });
}
