import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

typedef ShareFileFn = Future<ShareResult> Function(String path, String text);

/// 웹 공유 서비스.
///
/// 브라우저에서는 파일 시스템 임시 파일 대신 XFile.fromData로 바로 공유한다.
class ShareImageService {
  ShareImageService({ShareFileFn? shareFile});

  Future<ShareResultStatus> shareBytes(
    List<int> bytes, {
    required String text,
    Object? tempDir,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType: 'image/png',
            name: 'ohaeng_share.png',
          ),
        ],
        text: text,
      ),
    );
    return result.status;
  }

  Future<List<int>> captureBoundary(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
