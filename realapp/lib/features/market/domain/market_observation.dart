import '../../../core/domain/five_element.dart';
import '../../../engine/five_elements/element_balance.dart';
import '../../../engine/five_elements/guardian_selector.dart';
import '../../../engine/gateway/models.dart';
import 'phonetic_element.dart';

enum MarketRiskMode {
  aggressive('공격 모드'),
  neutral('중립 모드'),
  defensive('방어 모드');

  const MarketRiskMode(this.label);

  final String label;
}

String marketRiskModeGuide(MarketRiskMode mode) => switch (mode) {
  MarketRiskMode.aggressive => '움직임이 커질 수 있어 기준 확인을 먼저 두세요.',
  MarketRiskMode.neutral => '비교와 기록을 차분히 쌓는 흐름이에요.',
  MarketRiskMode.defensive => '새 판단보다 기록, 제한, 확인에 무게를 두세요.',
};

enum MarketWatchKeyword {
  information('information', '정보'),
  flow('flow', '흐름'),
  growth('growth', '성장'),
  stability('stability', '안정'),
  focus('focus', '집중'),
  wait('wait', '관망');

  const MarketWatchKeyword(this.code, this.label);

  final String code;
  final String label;

  static MarketWatchKeyword? byCode(String code) {
    for (final keyword in values) {
      if (keyword.code == code) return keyword;
    }
    return null;
  }
}

class MarketObservationScore {
  const MarketObservationScore({
    required this.instrumentId,
    required this.score,
    required this.nameElement,
    required this.guardianElement,
    required this.todayElement,
    required this.dominantElement,
    required this.riskMode,
    required this.reasonCodes,
  });

  final String instrumentId;
  final int score;
  final FiveElement? nameElement;
  final FiveElement guardianElement;
  final FiveElement todayElement;
  final FiveElement dominantElement;
  final MarketRiskMode riskMode;
  final List<String> reasonCodes;
}

class MarketReasonCodes {
  const MarketReasonCodes._();

  static const String riskModeAligned = 'risk_mode_aligned';
  static const String nameElementAligned = 'name_element_aligned';
  static const String guardianElementAligned = 'guardian_element_aligned';
  static const String dailyElementAligned = 'daily_element_aligned';
  static const String supportsGuardianElement = 'supports_guardian_element';
  static const String dominantElementBalanced = 'dominant_element_balanced';
  static const String dominantElementCaution = 'dominant_element_caution';
  static const String nameElementUnavailable = 'name_element_unavailable';
  static const String lowElementObserved = 'low_element_observed';
  static const String checklistReady = 'checklist_ready';
  static const String tagsPresent = 'tags_present';
  static const String defensiveChecklistRequired =
      'defensive_checklist_required';
}

String marketReasonLabel(String reasonCode) => switch (reasonCode) {
  MarketReasonCodes.riskModeAligned => '오늘 리듬과 관찰 방식이 맞아요',
  MarketReasonCodes.nameElementAligned => '이름 오행이 오늘 키워드와 가까워요',
  MarketReasonCodes.guardianElementAligned => '이름 오행이 내 보완 오행과 맞아요',
  MarketReasonCodes.dailyElementAligned => '이름 오행이 오늘 일진과 이어져요',
  MarketReasonCodes.supportsGuardianElement => '이름 오행이 보완 오행을 돕는 흐름이에요',
  MarketReasonCodes.dominantElementBalanced => '과한 오행을 완충하는 이름 흐름이에요',
  MarketReasonCodes.dominantElementCaution => '과한 오행이라 기록 중심으로 살펴봐요',
  MarketReasonCodes.nameElementUnavailable => '한글 이름 오행 근거가 적어 기록 중심으로 봐요',
  MarketReasonCodes.lowElementObserved => '내게 적은 오행이라 보완 관찰 포인트예요',
  MarketReasonCodes.checklistReady => '관찰 전 체크가 충분히 끝났어요',
  MarketReasonCodes.tagsPresent => '관심 키워드가 기록돼 있어요',
  MarketReasonCodes.defensiveChecklistRequired => '방어 모드라 체크리스트 확인이 필요해요',
  _ => '관찰 근거를 확인했어요',
};

String marketEngineRelationSummary(MarketObservationScore score) {
  final namePart = score.nameElement == null
      ? '이름 오행 확인 적음'
      : '이름 ${score.nameElement!.korean}';
  return '만세력 연결 · $namePart · 보완 ${score.guardianElement.korean} · 오늘 ${score.todayElement.korean}';
}

String marketObservationBandLabel(int score) {
  if (score >= 90) return '오늘의 핵심 관찰';
  if (score >= 75) return '우선 관찰';
  if (score >= 60) return '체크 후 관찰';
  return '기록부터 시작';
}

MarketRiskMode calculateMarketRiskMode({
  required ElementBalance balance,
  required GuardianMatch match,
  required DailyAnalysisResult analysis,
}) {
  final todayElement = match.todayElement;
  final sipsin = analysis.dayStemSipsin;
  final outputFocused = sipsin == '식신' || sipsin == '상관';
  final practicalFocused = sipsin == '편재' || sipsin == '정재';
  final ruleFocused = sipsin == '편관' || sipsin == '정관';

  if (ruleFocused || todayElement == balance.dominant) {
    return MarketRiskMode.defensive;
  }
  if ((outputFocused || practicalFocused) &&
      (todayElement == match.element || saeng[todayElement] == match.element)) {
    return MarketRiskMode.aggressive;
  }
  return MarketRiskMode.neutral;
}

List<String> observationKeywords(MarketRiskMode mode, FiveElement element) {
  final elementWords = switch (element) {
    FiveElement.wood => ['성장', '계획', '확장'],
    FiveElement.fire => ['표현', '관심', '소통'],
    FiveElement.earth => ['안정', '기반', '정리'],
    FiveElement.metal => ['집중', '선별', '원칙'],
    FiveElement.water => ['흐름', '정보', '네트워크'],
  };
  final modeWord = switch (mode) {
    MarketRiskMode.aggressive => '실행 전 점검',
    MarketRiskMode.neutral => '비교와 관찰',
    MarketRiskMode.defensive => '기록과 제한',
  };
  return [modeWord, ...elementWords];
}

MarketObservationScore calculateMarketObservationScore({
  required String instrumentId,
  required String name,
  required String corpName,
  required ElementBalance balance,
  required GuardianMatch match,
  required DailyAnalysisResult analysis,
  required int checklistCompleted,
  required int checklistTotal,
  required List<String> userTags,
}) {
  final riskMode = calculateMarketRiskMode(
    balance: balance,
    match: match,
    analysis: analysis,
  );
  final nameElement =
      primaryPhoneticElement(name) ?? primaryPhoneticElement(corpName);
  final reasons = <String>[];

  const baseScore = 48;
  final riskScore = switch (riskMode) {
    MarketRiskMode.aggressive => 12,
    MarketRiskMode.neutral => 10,
    MarketRiskMode.defensive => 8,
  };
  reasons.add(MarketReasonCodes.riskModeAligned);

  final engineRelationScore = _engineRelationScore(
    nameElement: nameElement,
    balance: balance,
    match: match,
    reasons: reasons,
  );

  final safeTotal = checklistTotal <= 0 ? 1 : checklistTotal;
  final safeCompleted = checklistCompleted.clamp(0, safeTotal);
  final checklistScore = (safeCompleted / safeTotal * 10).round();
  if (checklistCompleted == checklistTotal && checklistTotal > 0) {
    reasons.add(MarketReasonCodes.checklistReady);
  }

  final tagScore = userTags.isEmpty ? 0 : 5;
  if (userTags.isNotEmpty) reasons.add(MarketReasonCodes.tagsPresent);

  if (riskMode == MarketRiskMode.defensive &&
      checklistCompleted < checklistTotal) {
    reasons.add(MarketReasonCodes.defensiveChecklistRequired);
  }

  final rawScore =
      baseScore + riskScore + engineRelationScore + checklistScore + tagScore;
  final cap = checklistCompleted <= 0
      ? 78
      : riskMode == MarketRiskMode.defensive &&
            checklistCompleted < checklistTotal
      ? 82
      : checklistCompleted < checklistTotal
      ? 86
      : 95;
  final displayScore = rawScore.clamp(50, cap).toInt();

  return MarketObservationScore(
    instrumentId: instrumentId,
    score: displayScore,
    nameElement: nameElement,
    guardianElement: match.element,
    todayElement: match.todayElement,
    dominantElement: balance.dominant,
    riskMode: riskMode,
    reasonCodes: List.unmodifiable(reasons),
  );
}

int _engineRelationScore({
  required FiveElement? nameElement,
  required ElementBalance balance,
  required GuardianMatch match,
  required List<String> reasons,
}) {
  if (nameElement == null) {
    reasons.add(MarketReasonCodes.nameElementUnavailable);
    return 8;
  }

  final percent = balance.percentOf(nameElement);
  var score = (32 - percent).clamp(0, 18).toInt();

  if (nameElement == match.element) {
    score += 6;
    reasons.add(MarketReasonCodes.guardianElementAligned);
  } else if (saeng[nameElement] == match.element) {
    score += 4;
    reasons.add(MarketReasonCodes.supportsGuardianElement);
  }

  if (nameElement == match.todayElement) {
    score += 6;
    reasons.add(MarketReasonCodes.dailyElementAligned);
  } else if (saeng[match.todayElement] == nameElement ||
      saeng[nameElement] == match.todayElement) {
    score += 3;
  }

  final dominantBalancer = _controllingElement(balance.dominant);
  if (nameElement == dominantBalancer && nameElement != balance.dominant) {
    score += 4;
    reasons.add(MarketReasonCodes.dominantElementBalanced);
  }
  if (nameElement == balance.dominant) {
    score -= 3;
    reasons.add(MarketReasonCodes.dominantElementCaution);
  }
  if (percent <= 12 && nameElement != match.element) {
    reasons.add(MarketReasonCodes.lowElementObserved);
  }

  return score.clamp(4, 24).toInt();
}

FiveElement _controllingElement(FiveElement target) {
  for (final entry in geuk.entries) {
    if (entry.value == target) return entry.key;
  }
  return target;
}
