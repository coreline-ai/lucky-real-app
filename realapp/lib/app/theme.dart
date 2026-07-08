import 'package:flutter/material.dart';

import '../core/constants/element_colors.dart';
import '../core/constants/system_ui_styles.dart';

/// 1차 개발은 기본 테마 1종만 제공한다 (테마 변경은 2차).
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: ElementColors.water);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      centerTitle: true,
      systemOverlayStyle: AppSystemUiStyles.lightStatusBar,
    ),
  );
}
