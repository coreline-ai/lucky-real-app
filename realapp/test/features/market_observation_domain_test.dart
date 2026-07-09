import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/engine/five_elements/element_balance.dart';
import 'package:ohaeng_guardians/engine/five_elements/guardian_selector.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/market/domain/market_observation.dart';

void main() {
  const meta = EngineMeta(engineVersion: 'test', ruleVersion: 'test');
  const pillar = Pillar(gan: '甲', ji: '子');
  const defensiveBalance = ElementBalance({
    FiveElement.wood: 5,
    FiveElement.fire: 1,
    FiveElement.earth: 1,
    FiveElement.metal: 1,
    FiveElement.water: 1,
  });
  const defensiveMatch = GuardianMatch(
    element: FiveElement.metal,
    reasonCodes: [],
    todayElement: FiveElement.wood,
  );
  final defensiveAnalysis = DailyAnalysisResult(
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

  test('defensive mode adds checklist required reason before completion', () {
    final score = calculateMarketObservationScore(
      instrumentId: 'KRX:KOSPI:005930',
      name: '삼성전자',
      corpName: '삼성전자',
      balance: defensiveBalance,
      match: defensiveMatch,
      analysis: defensiveAnalysis,
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

  test(
    'watch item readiness starts from a non-negative observation baseline',
    () {
      final score = calculateMarketObservationScore(
        instrumentId: 'KRX:KOSPI:005930',
        name: '삼성전자',
        corpName: '삼성전자',
        balance: defensiveBalance,
        match: defensiveMatch,
        analysis: defensiveAnalysis,
        checklistCompleted: 0,
        checklistTotal: 4,
        userTags: const [],
      );

      expect(score.score, inInclusiveRange(50, 72));
      expect(marketObservationBandLabel(score.score), isNotEmpty);
      expect(
        score.reasonCodes,
        contains(MarketReasonCodes.defensiveChecklistRequired),
      );
    },
  );

  test('checklist and tags lift readiness without exceeding safety caps', () {
    final before = calculateMarketObservationScore(
      instrumentId: 'KRX:KOSPI:005930',
      name: '삼성전자',
      corpName: '삼성전자',
      balance: defensiveBalance,
      match: defensiveMatch,
      analysis: defensiveAnalysis,
      checklistCompleted: 0,
      checklistTotal: 4,
      userTags: const [],
    );
    final after = calculateMarketObservationScore(
      instrumentId: 'KRX:KOSPI:005930',
      name: '삼성전자',
      corpName: '삼성전자',
      balance: defensiveBalance,
      match: defensiveMatch,
      analysis: defensiveAnalysis,
      checklistCompleted: 4,
      checklistTotal: 4,
      userTags: const ['information'],
    );

    expect(after.score, greaterThan(before.score));
    expect(after.score, lessThanOrEqualTo(95));
    expect(after.reasonCodes, contains(MarketReasonCodes.checklistReady));
    expect(after.reasonCodes, contains(MarketReasonCodes.tagsPresent));
  });

  test('observation band labels stay in the self-check vocabulary', () {
    expect(marketObservationBandLabel(95), '오늘의 핵심 관찰');
    expect(marketObservationBandLabel(80), '우선 관찰');
    expect(marketObservationBandLabel(65), '체크 후 관찰');
    expect(marketObservationBandLabel(50), '기록부터 시작');
  });
}
