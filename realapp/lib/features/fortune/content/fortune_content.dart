/// 콘텐츠 레이어: 계산 결과(십신, 오행, 근거 코드) → 사용자 문구.
/// 05 문구 원칙 — 단정 대신 경향, 공포/의료/투자/법률 표현 금지,
/// 회복·정리·조절·선택의 언어 사용. 엔진은 문구를 모른다 (09 계약).
library;

import '../../../core/domain/five_element.dart';
import '../../../engine/five_elements/guardian_selector.dart';
import '../../../engine/gateway/models.dart';

class FortuneContent {
  const FortuneContent({
    required this.oneLiner,
    required this.overall,
    required this.relationship,
    required this.action,
    required this.emotion,
    required this.workStudy,
    required this.condition,
    required this.caution,
    required this.elementKeyword,
    required this.guardianReason,
  });

  final String oneLiner;
  final String overall;
  final String relationship;
  final String action;
  final String emotion;
  final String workStudy;
  final String condition;
  final String caution;
  final String elementKeyword;
  final String guardianReason;
}

/// 십신 10종 → 5그룹.
enum _SipsinGroup { bigeop, siksang, jaesung, gwansung, insung, none }

_SipsinGroup _groupOf(String sipsin) => switch (sipsin) {
  '비견' || '겁재' => _SipsinGroup.bigeop,
  '식신' || '상관' => _SipsinGroup.siksang,
  '편재' || '정재' => _SipsinGroup.jaesung,
  '편관' || '정관' => _SipsinGroup.gwansung,
  '편인' || '정인' => _SipsinGroup.insung,
  _ => _SipsinGroup.none,
};

class _GroupCopy {
  const _GroupCopy({
    required this.oneLiner,
    required this.overall,
    required this.relationship,
    required this.action,
    required this.emotion,
    required this.workStudy,
    required this.condition,
    required this.caution,
  });

  final String oneLiner;
  final String overall;
  final String relationship;
  final String action;
  final String emotion;
  final String workStudy;
  final String condition;
  final String caution;
}

const Map<_SipsinGroup, _GroupCopy> _copyByGroup = {
  _SipsinGroup.bigeop: _GroupCopy(
    oneLiner: '내 페이스를 지키기 좋은 날이에요.',
    overall: '주변에 흔들리기보다 내 기준을 다시 확인하기 좋은 흐름이에요.',
    relationship: '비슷한 입장의 사람과 서로 힘을 나누기 좋아요. 비교보다는 응원에 마음을 두면 편해져요.',
    action: '오늘 할 일 중 하나만 골라 내 방식대로 끝내보세요.',
    emotion: '자기 확신과 고집 사이를 오갈 수 있어요. 잠시 멈춰 호흡하면 균형이 돌아와요.',
    workStudy: '혼자 집중하는 작업이 잘 풀리는 편이에요. 협업은 역할을 나누면 수월해져요.',
    condition: '에너지가 밖으로 쏠리기 쉬워요. 중간중간 쉬는 시간을 챙겨주세요.',
    caution: '경쟁심이 올라올 수 있어요. 이기는 것보다 지키고 싶은 것을 떠올려보세요.',
  ),
  _SipsinGroup.siksang: _GroupCopy(
    oneLiner: '표현하고 만들어내기 좋은 날이에요.',
    overall: '생각을 밖으로 꺼낼수록 기분이 가벼워지는 흐름이에요.',
    relationship: '가벼운 대화와 유머가 관계를 부드럽게 해요. 먼저 말을 건네보세요.',
    action: '떠오른 아이디어를 메모 한 줄로 남겨보세요.',
    emotion: '감정이 풍부해지는 날이에요. 좋았던 순간을 기록하면 오래 남아요.',
    workStudy: '기획, 글쓰기, 아이디어 정리처럼 만들어내는 일에 흐름이 실려요.',
    condition: '말을 많이 하게 될 수 있어요. 물을 자주 마시면 좋아요.',
    caution: '말이 앞서기 쉬운 흐름이에요. 한 번 더 생각하고 전하면 충분해요.',
  ),
  _SipsinGroup.jaesung: _GroupCopy(
    oneLiner: '실속을 챙기기 좋은 날이에요.',
    overall: '눈앞의 작은 것부터 정돈하면 성취감이 쌓이는 흐름이에요.',
    relationship: '실질적인 도움을 주고받기 좋아요. 고마움은 바로 표현해 보세요.',
    action: '미뤄둔 자잘한 일 하나를 오늘 처리해 보세요.',
    emotion: '결과가 눈에 보일 때 마음이 안정되는 날이에요.',
    workStudy: '계획을 숫자나 목록으로 구체화하면 진도가 잘 나가요.',
    condition: '바쁘게 움직이기 쉬운 날이에요. 식사 시간을 지키면 컨디션이 유지돼요.',
    caution: '욕심이 커지기 쉬워요. 오늘 몫만큼만 챙겨도 충분해요.',
  ),
  _SipsinGroup.gwansung: _GroupCopy(
    oneLiner: '차분하게 정돈하기 좋은 날이에요.',
    overall: '규칙과 순서를 따라가면 마음이 편안해지는 흐름이에요.',
    relationship: '약속과 예의를 지키는 것이 신뢰로 돌아와요.',
    action: '오늘의 우선순위를 세 가지만 적어보세요.',
    emotion: '책임감이 커질 수 있는 날이에요. 다 짊어지지 않아도 괜찮아요.',
    workStudy: '마감, 정리, 점검 같은 마무리 작업에 힘이 실려요.',
    condition: '긴장이 몸에 쌓이기 쉬워요. 어깨를 풀어주는 스트레칭이 좋아요.',
    caution: '스스로에게 엄격해지기 쉬운 흐름이에요. 기준을 한 칸 낮춰보세요.',
  ),
  _SipsinGroup.insung: _GroupCopy(
    oneLiner: '배우고 채우기 좋은 날이에요.',
    overall: '새로운 정보나 지혜가 자연스럽게 스며드는 흐름이에요.',
    relationship: '조언을 구하거나 이야기를 들어주는 쪽이 잘 맞아요.',
    action: '궁금했던 주제를 10분만 찾아보세요.',
    emotion: '차분히 안으로 향하는 날이에요. 혼자만의 시간이 회복이 돼요.',
    workStudy: '공부, 자료 조사, 복습처럼 쌓아두는 일이 잘 맞아요.',
    condition: '생각이 많아질 수 있어요. 일찍 쉬면 내일이 가벼워요.',
    caution: '결정을 미루기 쉬운 흐름이에요. 작은 것 하나는 오늘 정해보세요.',
  ),
  _SipsinGroup.none: _GroupCopy(
    oneLiner: '흐름을 관찰하기 좋은 날이에요.',
    overall: '서두르지 않고 오늘의 리듬을 살펴보기 좋은 하루예요.',
    relationship: '무리하지 않는 거리에서 편안한 대화를 나눠보세요.',
    action: '지금 가장 마음 쓰이는 일 하나를 골라보세요.',
    emotion: '감정의 파도가 크지 않은 잔잔한 날이에요.',
    workStudy: '평소 하던 일을 평소 속도로 이어가면 충분해요.',
    condition: '몸의 신호에 귀 기울이며 무리하지 않는 것이 좋아요.',
    caution: '괜한 조바심이 올라오면 잠시 산책을 해보세요.',
  ),
};

const Map<FiveElement, String> _elementKeyword = {
  FiveElement.wood: '성장 — 작게 시작하고 뻗어가는 기운',
  FiveElement.fire: '표현 — 따뜻하게 드러내는 기운',
  FiveElement.earth: '안정 — 중심을 잡고 정돈하는 기운',
  FiveElement.metal: '집중 — 가다듬고 선택하는 기운',
  FiveElement.water: '회복 — 흘려보내고 채우는 기운',
};

String _guardianReason(GuardianMatch match) {
  final element = match.element.korean;
  final parts = <String>[];
  for (final code in match.reasonCodes) {
    switch (code) {
      case GuardianReasonCodes.weakElementSupport:
        parts.add('내 사주에서 아쉬운 $element의 기운을 채워주기 위해 찾아왔어요');
      case GuardianReasonCodes.dominantElementBalance:
        parts.add('넘치는 기운을 부드럽게 눌러 균형을 잡아줘요');
      case GuardianReasonCodes.dailyTengodFocus:
        parts.add('오늘의 일진과도 잘 어울리는 기운이에요');
      case GuardianReasonCodes.collectionRotation:
        parts.add('어제와 다른 시선을 건네주려고 순서를 바꿨어요');
    }
  }
  if (parts.isEmpty) {
    return '오늘의 흐름과 어울리는 $element의 수호신이에요.';
  }
  return '${parts.take(2).join('. ')}.';
}

FortuneContent buildFortuneContent({
  required DailyAnalysisResult analysis,
  required GuardianMatch match,
}) {
  final copy = _copyByGroup[_groupOf(analysis.dayStemSipsin)]!;
  return FortuneContent(
    oneLiner: copy.oneLiner,
    overall: copy.overall,
    relationship: copy.relationship,
    action: copy.action,
    emotion: copy.emotion,
    workStudy: copy.workStudy,
    condition: copy.condition,
    caution: copy.caution,
    elementKeyword: _elementKeyword[match.element]!,
    guardianReason: _guardianReason(match),
  );
}
