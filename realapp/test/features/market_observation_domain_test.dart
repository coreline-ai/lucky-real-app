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

      expect(score.score, inInclusiveRange(50, 78));
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

  test('manseryeok element relationship differentiates watch item scores', () {
    const balance = ElementBalance({
      FiveElement.wood: 26,
      FiveElement.fire: 15,
      FiveElement.earth: 37,
      FiveElement.metal: 22,
      FiveElement.water: 0,
    });
    const match = GuardianMatch(
      element: FiveElement.water,
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
      dayStemSipsin: '정관',
      seun: pillar,
      wolun: pillar,
    );

    MarketObservationScore scoreFor(String id, String name) {
      return calculateMarketObservationScore(
        instrumentId: id,
        name: name,
        corpName: name,
        balance: balance,
        match: match,
        analysis: analysis,
        checklistCompleted: 0,
        checklistTotal: 4,
        userTags: const [],
      );
    }

    final scores = {
      '삼성전자': scoreFor('KRX:KOSPI:005930', '삼성전자'),
      '카카오': scoreFor('KRX:KOSPI:035720', '카카오'),
      'SK하이닉스': scoreFor('KRX:KOSPI:000660', 'SK하이닉스'),
      'NAVER': scoreFor('KRX:KOSPI:035420', 'NAVER'),
      '현대자동차': scoreFor('KRX:KOSPI:005380', '현대자동차'),
    };

    expect(scores.values.map((score) => score.score).toSet().length, 5);
    expect(
      scores['삼성전자']!.reasonCodes,
      contains(MarketReasonCodes.supportsGuardianElement),
    );
    expect(
      scores['카카오']!.reasonCodes,
      contains(MarketReasonCodes.dailyElementAligned),
    );
    expect(
      scores['카카오']!.reasonCodes,
      contains(MarketReasonCodes.dominantElementBalanced),
    );
    expect(
      marketEngineRelationSummary(scores['삼성전자']!),
      '만세력 연결 · 이름 금 · 보완 수 · 오늘 목',
    );
  });
}
