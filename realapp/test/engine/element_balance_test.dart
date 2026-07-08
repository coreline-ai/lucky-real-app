import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/engine/five_elements/element_balance.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';

void main() {
  const meta = EngineMeta(engineVersion: 't', ruleVersion: 't');

  test('천간 1.0, 지지 본기 1.0, 나머지 지장간 0.3 가중치로 집계한다', () {
    // 甲子 · 丙寅 · 甲子 · 시주 미상 가정의 축소 케이스.
    final natal = FourPillarsResult(
      meta: meta,
      year: const Pillar(gan: '甲', ji: '子'),
      month: const Pillar(gan: '丙', ji: '寅'),
      day: const Pillar(gan: '甲', ji: '子'),
      hour: null,
      dayMaster: '甲',
      sipsin: const {},
      jijanggan: const {
        'yearJi': ['癸', '壬'], // 수 1.0 + 수 0.3
        'monthJi': ['甲', '丙', '戊'], // 목 1.0 + 화 0.3 + 토 0.3
        'dayJi': ['癸', '壬'], // 수 1.0 + 수 0.3
        'hourJi': [],
      },
      jijangganSipsin: const {},
    );

    final balance = calculateElementBalance(natal);

    expect(balance.scores[FiveElement.wood], closeTo(3.0, 1e-9)); // 甲+甲+甲(본기)
    expect(balance.scores[FiveElement.fire], closeTo(1.3, 1e-9)); // 丙+丙(0.3)
    expect(balance.scores[FiveElement.earth], closeTo(0.3, 1e-9));
    expect(balance.scores[FiveElement.metal], closeTo(0.0, 1e-9));
    expect(balance.scores[FiveElement.water], closeTo(2.6, 1e-9));

    expect(balance.dominant, FiveElement.wood);
    expect(balance.weakest, FiveElement.metal);
    expect(balance.weakestExcluding(FiveElement.metal), FiveElement.earth);
  });

  test('백분율 합은 100 근처로 정규화된다', () {
    final balance = ElementBalance({
      for (final e in FiveElement.values) e: 2.0,
    });
    for (final e in FiveElement.values) {
      expect(balance.percentOf(e), 20);
    }
  });
}
