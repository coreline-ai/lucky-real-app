import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('시장관찰 1차 runtime artifacts are present', () {
    expect(File('assets/market/kr_instruments.json').existsSync(), isTrue);
    expect(Directory('lib/features/market').existsSync(), isTrue);
    expect(
      File('lib/data/repositories/market_repository.dart').existsSync(),
      isTrue,
    );
  });

  test('market copy does not include direct investment action language', () {
    final forbidden = RegExp(r'추천|매수|매도|목표가|수익\s*예상|상승\s*예측|하락\s*예측');
    final files = Directory('lib/features/market')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final hits = <String>[];
    for (final file in files) {
      final text = file.readAsStringSync();
      if (forbidden.hasMatch(text)) hits.add(file.path);
    }

    expect(hits, isEmpty);
  });
}
