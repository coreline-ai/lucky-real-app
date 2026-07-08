import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/engine/five_elements/element_balance.dart';
import 'package:ohaeng_guardians/engine/five_elements/guardian_selector.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';

void main() {
  const meta = EngineMeta(engineVersion: 't', ruleVersion: 't');

  DailyCycleResult daily(String dayGan) => DailyCycleResult(
    meta: meta,
    date: DateTime(2026, 7, 7),
    yearPillar: const Pillar(gan: '丙', ji: '午'),
    monthPillar: const Pillar(gan: '乙', ji: '未'),
    dayPillar: Pillar(gan: dayGan, ji: '午'),
  );

  ElementBalance balance(Map<FiveElement, double> scores) =>
      ElementBalance({for (final e in FiveElement.values) e: 0.0, ...scores});

  test('부족 오행을 보완하는 수호신을 고르고 근거 코드를 남긴다', () {
    final match = selectGuardian(
      balance: balance({
        FiveElement.wood: 3,
        FiveElement.fire: 2,
        FiveElement.earth: 2,
        FiveElement.metal: 1,
        FiveElement.water: 0.5,
      }),
      daily: daily('甲'),
    );

    expect(match.element, FiveElement.water);
    expect(match.guardianId, 'guardian_water_yang');
    expect(match.reasonCodes, contains(GuardianReasonCodes.weakElementSupport));
  });

  test('같은 입력은 항상 같은 결과 (결정성)', () {
    GuardianMatch run() => selectGuardian(
      balance: balance({FiveElement.metal: 0.2, FiveElement.wood: 5}),
      daily: daily('庚'),
    );
    final first = run();
    for (var i = 0; i < 10; i++) {
      final again = run();
      expect(again.guardianId, first.guardianId);
      expect(again.reasonCodes, first.reasonCodes);
    }
  });

  test('어제와 같은 수호신이면 다양성 보정으로 교체한다', () {
    final scores = {
      FiveElement.wood: 5.0,
      FiveElement.fire: 4.0,
      FiveElement.earth: 3.0,
      FiveElement.metal: 1.0,
      FiveElement.water: 0.5,
    };
    final withoutHistory = selectGuardian(
      balance: balance(scores),
      daily: daily('甲'),
    );
    expect(withoutHistory.element, FiveElement.water);

    final rotated = selectGuardian(
      balance: balance(scores),
      daily: daily('甲'),
      previousGuardianId: 'guardian_water_yang',
    );
    expect(rotated.element, FiveElement.metal);
    expect(
      rotated.reasonCodes,
      contains(GuardianReasonCodes.collectionRotation),
    );
  });

  test('오늘 일진 오행과 연결되면 daily_tengod_focus 코드를 추가한다', () {
    final match = selectGuardian(
      // 수(water)가 최약, 오늘 일간 癸(수) → 연결.
      balance: balance({
        FiveElement.wood: 3,
        FiveElement.fire: 2,
        FiveElement.earth: 2,
        FiveElement.metal: 1,
        FiveElement.water: 0.1,
      }),
      daily: daily('癸'),
    );
    expect(match.element, FiveElement.water);
    expect(match.reasonCodes, contains(GuardianReasonCodes.dailyTengodFocus));
  });

  test('선택 오행이 과다 오행을 극하면 dominant_element_balance를 추가한다', () {
    final match = selectGuardian(
      // 화(fire) 과다, 수(water) 최약 — 수는 화를 극한다.
      balance: balance({
        FiveElement.wood: 2,
        FiveElement.fire: 6,
        FiveElement.earth: 2,
        FiveElement.metal: 2,
        FiveElement.water: 0.1,
      }),
      daily: daily('甲'),
    );
    expect(match.element, FiveElement.water);
    expect(
      match.reasonCodes,
      contains(GuardianReasonCodes.dominantElementBalance),
    );
  });
}
