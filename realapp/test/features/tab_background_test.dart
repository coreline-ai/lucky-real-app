import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/constants/asset_paths.dart';
import 'package:ohaeng_guardians/core/constants/system_ui_styles.dart';
import 'package:ohaeng_guardians/features/shared/tab_background.dart';

/// 배경 B안 Phase 1: 배경 위에서 자식 콘텐츠가 렌더·접근 가능해야 한다.
void main() {
  testWidgets('child text renders on top of the background', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TabBackground(
            imagePath: AssetPaths.historyBackground,
            child: Center(child: Text('본문 텍스트')),
          ),
        ),
      ),
    );

    expect(find.text('본문 텍스트'), findsOneWidget);
    // 스크림이 자식보다 아래(스택 앞 순서)에 있어 탭을 가로채지 않는다.
    await tester.tap(find.text('본문 텍스트'));
  });

  testWidgets('background image is excluded from semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TabBackground(
            imagePath: AssetPaths.settingsBackground,
            scrim: TabBackgroundScrim.strong,
            child: Center(child: Text('설정')),
          ),
        ),
      ),
    );

    // 자식 텍스트 시맨틱은 유지된다.
    expect(find.text('설정'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.excludeFromSemantics, isTrue);
    // cacheWidth는 ResizeImage 프로바이더로 감싸는 방식으로 적용된다.
    final provider = image.image;
    expect(provider, isA<ResizeImage>());
    expect((provider as ResizeImage).width, TabBackground.cacheWidth);
    handle.dispose();
  });

  testWidgets('transparent app bar sits on the full screen tab background', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TabBackground(
          imagePath: AssetPaths.historyBackground,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBarPlaceholder(),
            body: Align(alignment: Alignment.topLeft, child: Text('본문 시작')),
          ),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.systemOverlayStyle, AppSystemUiStyles.lightStatusBar);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.byType(Image)),
      findsNothing,
    );
    expect(find.byType(TabBackground), findsOneWidget);
    expect(tester.getTopLeft(find.text('본문 시작')).dy, kToolbarHeight);
  });
}

class AppBarPlaceholder extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBackground.appBar(title: const Text('상단'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
