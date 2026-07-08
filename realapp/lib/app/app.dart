import 'package:flutter/material.dart';

import '../core/constants/system_ui_styles.dart';
import 'router.dart';
import 'theme.dart';

class OhaengGuardiansApp extends StatelessWidget {
  const OhaengGuardiansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppSystemUiStyles.lightStatusBar,
      child: MaterialApp.router(
        title: '오행가디언즈',
        theme: buildAppTheme(),
        routerConfig: buildRouter(),
      ),
    );
  }
}
