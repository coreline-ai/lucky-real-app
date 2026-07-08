/// 케미 콘텐츠 레이어: 계산 결과(점수·관계 type) → 사용자 문구.
/// 03/05 규칙 — 관계 단정 금지, 낮은 점수도 보완 관점, 불안 조장 금지.
/// 엔진은 문구를 모른다 (09 계약).
library;

import '../../../engine/gateway/models.dart';

enum RelationType { friend, love, family, work, custom }

extension RelationTypeLabel on RelationType {
  String get korean => switch (this) {
    RelationType.friend => '친구',
    RelationType.love => '연인',
    RelationType.family => '가족',
    RelationType.work => '동료',
    RelationType.custom => '소중한 사람',
  };

  static RelationType fromName(String name) => RelationType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => RelationType.custom,
  );
}

class ChemistryContent {
  const ChemistryContent({
    required this.headline,
    required this.strengths,
    required this.communication,
    required this.togetherTip,
    required this.balanceNote,
  });

  /// 등급 한 줄 (단정 없는 경향 표현).
  final String headline;

  /// 잘 맞는 점 (일간 관계 기반).
  final String strengths;

  /// 조심하면 좋은 소통 방식 (일지 관계 기반).
  final String communication;

  /// 함께 하면 좋은 것 (관계 타입 반영).
  final String togetherTip;

  /// 오행 보완 안내 (부족 오행 기반).
  final String balanceNote;
}

String _headline(String grade, String relation) => switch (grade) {
  'S' => '서로를 자연스럽게 끌어당기는 흐름이에요.',
  'A' => '함께할수록 서로를 채워주는 흐름이에요.',
  'B' => '편안하게 오래 갈 수 있는 무난한 흐름이에요.',
  'C' => '서로 다른 점이 많지만, 그만큼 배울 것도 많은 흐름이에요.',
  _ => '속도는 다르지만, 이해하려는 만큼 가까워지는 흐름이에요.',
};

String _strengths(String dayGanType) => switch (dayGanType) {
  '천간합' => '기질이 서로 끌리는 조합이에요. 함께 있을 때 자연스럽게 편안해져요.',
  '상생' => '한쪽의 기운이 다른 쪽을 살려주는 조합이에요. 서로의 시작을 응원하게 돼요.',
  '비화' => '비슷한 기질이라 말하지 않아도 통하는 부분이 많아요.',
  '천간충' => '서로 다른 에너지가 부딪히며 자극을 주는 조합이에요. 지루할 틈이 없어요.',
  '상극' => '접근 방식이 달라서, 서로에게 없는 관점을 보여줄 수 있어요.',
  _ => '서로의 기질을 천천히 알아가기 좋은 조합이에요.',
};

String _communication(String dayJiType) => switch (dayJiType) {
  '육합' => '감정이 잘 통하는 편이에요. 고마움을 표현하면 더 깊어져요.',
  '상생' => '대화가 자연스럽게 이어지는 편이에요. 들어주는 역할을 번갈아 해보세요.',
  '비화' => '비슷해서 편하지만, 당연하게 여기지 않도록 가끔 물어봐 주세요.',
  '충' => '감정이 부딪힐 때는 잠시 쉬었다가 이야기하면 훨씬 부드러워져요.',
  '형' => '서로 예민해지는 주제가 있을 수 있어요. 농담의 온도를 살펴주세요.',
  '상극' => '표현 방식이 달라 오해가 생길 수 있어요. 결론보다 마음을 먼저 물어보세요.',
  _ => '서두르지 않는 대화가 잘 맞아요.',
};

String _togetherTip(RelationType relation) => switch (relation) {
  RelationType.friend => '가벼운 산책이나 새로운 카페 탐방처럼 부담 없는 시간을 함께해 보세요.',
  RelationType.love => '하루의 좋았던 순간 하나를 서로 나누는 짧은 대화를 루틴으로 만들어 보세요.',
  RelationType.family => '함께 식사하는 시간을 천천히 갖는 것만으로 기운이 정돈돼요.',
  RelationType.work => '작은 일의 마무리를 서로 확인해 주는 습관이 신뢰를 쌓아요.',
  RelationType.custom => '함께 있는 시간에 각자의 속도를 존중해 주세요.',
};

String _balanceNote(List<String> missingElements) {
  if (missingElements.isEmpty) {
    return '두 사람의 오행이 서로를 잘 보완하고 있어요.';
  }
  final joined = missingElements.join(', ');
  return '둘이 합쳐도 $joined의 기운은 옅은 편이에요. '
      '$joined 기운의 루틴을 함께해 보면 균형에 도움이 돼요.';
}

ChemistryContent buildChemistryContent({
  required ChemistryAnalysis analysis,
  required RelationType relation,
}) {
  return ChemistryContent(
    headline: _headline(analysis.grade, relation.korean),
    strengths: _strengths(analysis.dayGanType),
    communication: _communication(analysis.dayJiType),
    togetherTip: _togetherTip(relation),
    balanceNote: _balanceNote(analysis.missingElements),
  );
}
