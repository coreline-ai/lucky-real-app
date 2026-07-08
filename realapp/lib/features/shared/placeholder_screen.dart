import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import 'tab_background.dart';

/// Phase 2 골격용 자리 화면. 각 기능 Phase에서 실제 화면으로 교체된다.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.message = '준비 중이에요.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return TabBackground(
      imagePath: AssetPaths.homeBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: Text(title)),
        body: Center(child: Text(message)),
      ),
    );
  }
}
