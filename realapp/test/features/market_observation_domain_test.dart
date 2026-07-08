import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/engine/five_elements/element_balance.dart';
import 'package:ohaeng_guardians/engine/five_elements/guardian_selector.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/market/domain/market_observation.dart';

void main() {
  const meta = EngineMeta(engineVersion: 'test', ruleVersion: 'test');
  const pillar = Pillar(gan: '甲', ji: '子');

  test('defensive mode adds checklist required reason before completion', () {
    const balance = ElementBalance({
      FiveElement.wood: 5,
      FiveElement.fire: 1,
      FiveElement.earth: 1,
      FiveElement.metal: 1,
      FiveElement.water: 1,
    });
    const match = GuardianMatch(
      element: FiveElement.metal,
      reasonCodes: [],
      todayElement: FiveElement.wood,
    );
    final analysis = DailyAnalysisResult(
      meta: meta,
      natal: const FourPillarsResult(
        meta: meta,
        year: pillar,
        month: pillar,
        day: pillar,
        hour: null,
        dayMaster: '甲',
        sipsin: {},
        jijanggan: {},
        jijangganSipsin: {},
      ),
      daily: DailyCycleResult(
        meta: meta,
        date: DateTime(2026, 7, 8),
        yearPillar: pillar,
        monthPillar: pillar,
        dayPillar: pillar,
      ),
      dayStemSipsin: '비견',
      seun: pillar,
      wolun: pillar,
    );

    final score = calculateMarketObservationScore(
      instrumentId: 'KRX:KOSPI:005930',
      name: '삼성전자',
      corpName: '삼성전자',
      balance: balance,
      match: match,
      analysis: analysis,
      checklistCompleted: 1,
      checklistTotal: 3,
      userTags: const [],
    );

    expect(score.riskMode, MarketRiskMode.defensive);
    expect(
      score.reasonCodes,
      contains(MarketReasonCodes.defensiveChecklistRequired),
    );
    expect(
      marketReasonLabel(MarketReasonCodes.defensiveChecklistRequired),
      '방어 모드라 체크리스트 확인이 필요해요',
    );
  });
}
