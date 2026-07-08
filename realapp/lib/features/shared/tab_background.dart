import 'package:flutter/material.dart';

import '../../core/constants/system_ui_styles.dart';

/// 스크림 강도 2단계 (배경 B안 결정: 옵션 최소화).
/// [standard]는 본문 텍스트가 배경 위에 바로 놓이는 화면(홈·기록·설정),
/// [strong]은 카드·그리드가 주인공이라 배경이 뒤로 빠지는 화면(루틴·도감).
enum TabBackgroundScrim { standard, strong }

/// 탭 화면 공통 배경: 풀스크린 이미지 + 상→하 화이트 스크림.
///
/// 가독성은 위젯 구조로 보장한다 — 스크림 없이 이미지를 직접 깔지 않는다
/// (05 접근성: 명암비). 이미지는 [cacheWidth]로 디코드 크기를 제한한다.
class TabBackground extends StatelessWidget {
  const TabBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.scrim = TabBackgroundScrim.standard,
    this.reserveAppBarSpace = false,
  });

  final String imagePath;
  final Widget child;
  final TabBackgroundScrim scrim;
  final bool reserveAppBarSpace;

  /// 배경 디코드 폭 상한 (논리 1080px 원본을 기기 폭 수준으로 축소).
  static const int cacheWidth = 720;

  static PreferredSizeWidget appBar({
    required Widget title,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: AppSystemUiStyles.lightStatusBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (topOpacity, bottomOpacity) = switch (scrim) {
      TabBackgroundScrim.standard => (0.55, 0.75),
      TabBackgroundScrim.strong => (0.78, 0.90),
    };
    final topPadding = reserveAppBarSpace
        ? MediaQuery.paddingOf(context).top + kToolbarHeight
        : 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          excludeFromSemantics: true,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: topOpacity),
                Colors.white.withValues(alpha: bottomOpacity),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: child,
        ),
      ],
    );
  }
}
