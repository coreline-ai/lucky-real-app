import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 공유 함수 주입 지점 (테스트에서 페이크로 대체).
typedef ShareFileFn = Future<ShareResult> Function(String path, String text);

Future<ShareResult> _defaultShareFile(String path, String text) {
  return SharePlus.instance.share(
    ShareParams(files: [XFile(path)], text: text),
  );
}

/// RepaintBoundary 캡처 → 임시 PNG → OS 공유 시트 → 임시 파일 정리 (04).
/// 취소/완료와 무관하게 임시 파일은 항상 삭제된다.
class ShareImageService {
  ShareImageService({ShareFileFn? shareFile})
    : _shareFile = shareFile ?? _defaultShareFile;

  final ShareFileFn _shareFile;

  Future<File> writeTempPng(List<int> bytes, {Directory? tempDir}) async {
    final dir = tempDir ?? await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ohaeng_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// 캡처된 PNG 바이트를 공유하고 임시 파일을 정리한다.
  Future<ShareResultStatus> shareBytes(
    List<int> bytes, {
    required String text,
    Directory? tempDir,
  }) async {
    final file = await writeTempPng(bytes, tempDir: tempDir);
    try {
      final result = await _shareFile(file.path, text);
      return result.status;
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// RepaintBoundary(GlobalKey)에서 PNG 바이트 추출.
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
