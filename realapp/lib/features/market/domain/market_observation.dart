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
    required this.riskMode,
    required this.reasonCodes,
  });

  final String instrumentId;
  final int score;
  final FiveElement? nameElement;
  final MarketRiskMode riskMode;
  final List<String> reasonCodes;
}

class MarketReasonCodes {
  const MarketReasonCodes._();

  static const String riskModeAligned = 'risk_mode_aligned';
  static const String nameElementAligned = 'name_element_aligned';
  static const String checklistReady = 'checklist_ready';
  static const String tagsPresent = 'tags_present';
  static const String defensiveChecklistRequired =
      'defensive_checklist_required';
}

String marketReasonLabel(String reasonCode) => switch (reasonCode) {
  MarketReasonCodes.riskModeAligned => '오늘 리듬과 관찰 방식이 맞아요',
  MarketReasonCodes.nameElementAligned => '이름 오행이 오늘 키워드와 가까워요',
  MarketReasonCodes.checklistReady => '관찰 전 체크가 충분히 끝났어요',
  MarketReasonCodes.tagsPresent => '관심 키워드가 기록돼 있어요',
  MarketReasonCodes.defensiveChecklistRequired => '방어 모드라 체크리스트 확인이 필요해요',
  _ => '관찰 근거를 확인했어요',
};

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

  const baseScore = 50;
  final riskScore = switch (riskMode) {
    MarketRiskMode.aggressive => 15,
    MarketRiskMode.neutral => 12,
    MarketRiskMode.defensive => 10,
  };
  reasons.add(MarketReasonCodes.riskModeAligned);

  var nameScore = 6;
  if (nameElement != null) {
    if (nameElement == match.element || nameElement == match.todayElement) {
      nameScore = 15;
      reasons.add(MarketReasonCodes.nameElementAligned);
    } else if (saeng[nameElement] == match.element ||
        saeng[match.element] == nameElement) {
      nameScore = 10;
    }
  }

  final safeTotal = checklistTotal <= 0 ? 1 : checklistTotal;
  final safeCompleted = checklistCompleted.clamp(0, safeTotal);
  final checklistScore = (safeCompleted / safeTotal * 12).round();
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
      baseScore + riskScore + nameScore + checklistScore + tagScore;
  final cap = checklistCompleted <= 0
      ? 72
      : riskMode == MarketRiskMode.defensive &&
            checklistCompleted < checklistTotal
      ? 76
      : checklistCompleted < checklistTotal
      ? 82
      : 95;
  final displayScore = rawScore.clamp(50, cap).toInt();

  return MarketObservationScore(
    instrumentId: instrumentId,
    score: displayScore,
    nameElement: nameElement,
    riskMode: riskMode,
    reasonCodes: List.unmodifiable(reasons),
  );
}
