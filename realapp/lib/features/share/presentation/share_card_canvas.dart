import 'package:flutter/material.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/domain/five_element.dart';

/// 공유 카드 캔버스 (9:16, 논리 360×640 고정).
/// 템플릿 이미지 위에 Flutter 텍스트를 합성한다 (07: 이미지에 텍스트 금지).
/// 개인정보 규칙(02/05): 생년월일·출생시간·상세 사주·상대 닉네임은
/// 이 위젯에 아예 전달되지 않는다 — 구조적으로 포함 불가.
class ShareCardData {
  const ShareCardData.guardian({
    required this.title,
    required this.subtitle,
    required FiveElement this.element,
    this.nickname,
  }) : template = AssetPaths.shareTodayGuardianTemplate,
       showGuardian = true;

  const ShareCardData.chemistry({
    required this.title,
    required this.subtitle,
    this.nickname,
  }) : template = AssetPaths.shareChemistryTemplate,
       element = null,
       showGuardian = false;

  final String template;
  final String title;
  final String subtitle;

  /// null이면 카드에 닉네임 미표시.
  final String? nickname;

  final FiveElement? element;
  final bool showGuardian;
}

class ShareCardCanvas extends StatelessWidget {
  const ShareCardCanvas({super.key, required this.data});

  static const Size logicalSize = Size(360, 640);

  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: logicalSize.width,
      height: logicalSize.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(data.template, fit: BoxFit.cover),
          if (data.showGuardian && data.element != null)
            Align(
              alignment: const Alignment(0, -0.15),
              child: Image.asset(
                AssetPaths.guardianIdle(data.element!),
                height: 240,
              ),
            ),
          // 하단 30% 안전 영역 (07 템플릿 규칙)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (data.nickname != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${data.nickname} · 오행가디언즈',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    const Text(
                      '오행가디언즈',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
