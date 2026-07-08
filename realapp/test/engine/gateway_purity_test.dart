import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 04 아키텍처 규칙: `lib/engine/`은 Flutter를 import하지 않는다.
/// 순수 Dart를 강제해 `dart test` 단독 실행과 엔진 이식성을 보장한다.
void main() {
  test('lib/engine contains no Flutter imports', () {
    final engineDir = Directory('lib/engine');
    expect(engineDir.existsSync(), isTrue);

    final offenders = <String>[];
    for (final entity in engineDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (source.contains("import 'package:flutter") ||
          source.contains('import "package:flutter')) {
        offenders.add(entity.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'engine layer must stay pure Dart: $offenders',
    );
  });
}
