import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/app/app.dart';
import 'package:ohaeng_guardians/app/app_providers.dart';
import 'package:ohaeng_guardians/core/constants/asset_paths.dart';
import 'package:ohaeng_guardians/core/time/app_clock.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/shared/tab_background.dart';

/// E2E 9단계(케미 결과 → 공유 미리보기) 로컬 재현.
/// 실기기에서 공유 아이콘 탭 후 미리보기가 열리지 않는 문제를 격리한다.
void main() {
  testWidgets('chemistry result share icon opens the preview', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final clock = const SystemClock();
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

    // 케미 탭 → 상대 추가
    await tester.tap(find.text('케미').hitTestable());
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TabBackground &&
            widget.imagePath == AssetPaths.chemistryResultBackground,
      ),
      findsOneWidget,
    );
    await tester.tap(find.byType(FloatingActionButton).hitTestable());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '단짝');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('생년월일 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('케미 보러 가기'));
    await tester.tap(find.text('케미 보러 가기'));
    await tester.pumpAndSettle();

    // 결과 화면 확인 후 공유 아이콘 탭
    expect(find.textContaining('잘 맞는 점'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.ios_share).hitTestable().first);
    await tester.pumpAndSettle();

    // 미리보기 body는 lazy ListView라 카드 아래 컨트롤은 스크롤 후 빌드된다.
    expect(find.text('공유 미리보기'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('이대로 공유하기'), 300);
    expect(find.text('이대로 공유하기'), findsOneWidget);
    expect(find.text('내 닉네임 표시'), findsOneWidget);
  });
}
