/// 카드 도감 마스터 카탈로그 (03 Card 모델, 시맨틱 ID).
/// 모든 카드는 무료 활동으로만 해금된다. rarity는 수집 난이도 표현일 뿐이다.
/// Pure Dart.
library;

import '../../../core/domain/five_element.dart';

enum CardRarity { common, rare, special }

class CardDefinition {
  const CardDefinition({
    required this.id,
    required this.name,
    required this.element,
    required this.rarity,
    required this.flavorText,
    required this.isGuardian,
    required this.unlockHint,
    this.isYin = false,
  });

  final String id;
  final String name;
  final FiveElement element;
  final CardRarity rarity;
  final String flavorText;

  /// true면 수호신 카드 아트, false면 오행 카드 아트.
  final bool isGuardian;

  /// 획득 조건 안내 (06 수용 기준: 카드 획득 조건은 숨기지 않는다).
  final String unlockHint;

  /// 음(yin) 카드 — 2차 해금 보상 전용, 수호신 선택 로직 미편입.
  final bool isYin;
}

const String _dailyHint = '일일 확인 보상으로 만나요';
const String _routineHint = '첫 방문 또는 루틴 완료로 만나요';

const List<CardDefinition> cardCatalog = [
  // 오행 기운 카드 (일일 확인 보상 풀)
  CardDefinition(
    id: 'card_element_wood',
    name: '목의 기운',
    element: FiveElement.wood,
    rarity: CardRarity.common,
    flavorText: '작은 싹이 하루를 밀어 올려요.',
    isGuardian: false,
    unlockHint: _dailyHint,
  ),
  CardDefinition(
    id: 'card_element_fire',
    name: '화의 기운',
    element: FiveElement.fire,
    rarity: CardRarity.common,
    flavorText: '따뜻함은 표현할 때 커져요.',
    isGuardian: false,
    unlockHint: _dailyHint,
  ),
  CardDefinition(
    id: 'card_element_earth',
    name: '토의 기운',
    element: FiveElement.earth,
    rarity: CardRarity.common,
    flavorText: '중심이 잡히면 흔들려도 괜찮아요.',
    isGuardian: false,
    unlockHint: _dailyHint,
  ),
  CardDefinition(
    id: 'card_element_metal',
    name: '금의 기운',
    element: FiveElement.metal,
    rarity: CardRarity.common,
    flavorText: '덜어낼수록 또렷해져요.',
    isGuardian: false,
    unlockHint: _dailyHint,
  ),
  CardDefinition(
    id: 'card_element_water',
    name: '수의 기운',
    element: FiveElement.water,
    rarity: CardRarity.common,
    flavorText: '흘려보내는 것도 회복이에요.',
    isGuardian: false,
    unlockHint: _dailyHint,
  ),
  // 양(yang) 수호신 카드 (첫 방문/루틴 완료 보상)
  CardDefinition(
    id: 'card_guardian_wood_yang',
    name: '목의 수호신',
    element: FiveElement.wood,
    rarity: CardRarity.rare,
    flavorText: '성장의 길목마다 함께 걷는 수호신.',
    isGuardian: true,
    unlockHint: _routineHint,
  ),
  CardDefinition(
    id: 'card_guardian_fire_yang',
    name: '화의 수호신',
    element: FiveElement.fire,
    rarity: CardRarity.rare,
    flavorText: '마음의 온도를 지켜주는 수호신.',
    isGuardian: true,
    unlockHint: _routineHint,
  ),
  CardDefinition(
    id: 'card_guardian_earth_yang',
    name: '토의 수호신',
    element: FiveElement.earth,
    rarity: CardRarity.rare,
    flavorText: '단단한 하루의 바닥을 받쳐주는 수호신.',
    isGuardian: true,
    unlockHint: _routineHint,
  ),
  CardDefinition(
    id: 'card_guardian_metal_yang',
    name: '금의 수호신',
    element: FiveElement.metal,
    rarity: CardRarity.rare,
    flavorText: '선택의 순간을 가다듬어주는 수호신.',
    isGuardian: true,
    unlockHint: _routineHint,
  ),
  CardDefinition(
    id: 'card_guardian_water_yang',
    name: '수의 수호신',
    element: FiveElement.water,
    rarity: CardRarity.rare,
    flavorText: '지친 하루를 흘려보내 주는 수호신.',
    isGuardian: true,
    unlockHint: _routineHint,
  ),
  // 음(yin) 수호신 카드 (2차 해금 보상 — 스트릭·케미 공유)
  CardDefinition(
    id: 'card_guardian_wood_yin',
    name: '달빛 목의 수호신',
    element: FiveElement.wood,
    rarity: CardRarity.special,
    flavorText: '밤에도 조용히 자라는 마음을 지켜요.',
    isGuardian: true,
    isYin: true,
    unlockHint: '루틴을 3일 연속 완료하면 만나요',
  ),
  CardDefinition(
    id: 'card_guardian_fire_yin',
    name: '달빛 화의 수호신',
    element: FiveElement.fire,
    rarity: CardRarity.special,
    flavorText: '은은한 불씨로 하루의 끝을 데워요.',
    isGuardian: true,
    isYin: true,
    unlockHint: '루틴을 7일 연속 완료하면 만나요',
  ),
  CardDefinition(
    id: 'card_guardian_earth_yin',
    name: '달빛 토의 수호신',
    element: FiveElement.earth,
    rarity: CardRarity.special,
    flavorText: '고요한 밤의 안정감을 건네요.',
    isGuardian: true,
    isYin: true,
    unlockHint: '케미를 1번 공유하면 만나요',
  ),
  CardDefinition(
    id: 'card_guardian_metal_yin',
    name: '달빛 금의 수호신',
    element: FiveElement.metal,
    rarity: CardRarity.special,
    flavorText: '달빛처럼 차분한 결단을 도와요.',
    isGuardian: true,
    isYin: true,
    unlockHint: '케미를 2번 공유하면 만나요',
  ),
  CardDefinition(
    id: 'card_guardian_water_yin',
    name: '달빛 수의 수호신',
    element: FiveElement.water,
    rarity: CardRarity.special,
    flavorText: '깊은 밤의 물결처럼 마음을 쉬게 해요.',
    isGuardian: true,
    isYin: true,
    unlockHint: '케미를 3번 공유하면 만나요',
  ),
];

CardDefinition? cardById(String id) {
  for (final card in cardCatalog) {
    if (card.id == id) return card;
  }
  return null;
}
