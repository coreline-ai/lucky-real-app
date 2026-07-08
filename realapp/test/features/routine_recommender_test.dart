import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/features/cards/domain/card_catalog.dart';
import 'package:ohaeng_guardians/features/routine/domain/routine_recommender.dart';
import 'package:ohaeng_guardians/features/routine/domain/routine_templates.dart';

void main() {
  test('추천은 1-3개이고 5분 이내 루틴을 반드시 포함한다 (03 규칙)', () {
    for (final guardian in FiveElement.values) {
      for (final today in FiveElement.values) {
        final picks = recommendRoutines(
          guardianElement: guardian,
          todayElement: today,
        );
        expect(
          picks.length,
          inInclusiveRange(1, 3),
          reason: '$guardian/$today',
        );
        expect(
          picks.any((t) => t.durationMinutes <= 5),
          isTrue,
          reason: '$guardian/$today 5분 이내 루틴 누락',
        );
        // 수호신 오행 루틴이 우선 포함된다.
        expect(picks.first.element, guardian);
      }
    }
  });

  test('추천은 결정적이다', () {
    final first = recommendRoutines(
      guardianElement: FiveElement.metal,
      todayElement: FiveElement.fire,
    );
    for (var i = 0; i < 5; i++) {
      final again = recommendRoutines(
        guardianElement: FiveElement.metal,
        todayElement: FiveElement.fire,
      );
      expect(again.map((t) => t.id), first.map((t) => t.id));
    }
  });

  test('루틴 템플릿 마스터: 오행별 2개씩, 시맨틱 ID, 조회 일관성', () {
    expect(routineTemplates, hasLength(10));
    for (final element in FiveElement.values) {
      expect(routineTemplates.where((t) => t.element == element), hasLength(2));
    }
    for (final template in routineTemplates) {
      expect(template.id, startsWith('routine_'));
      expect(routineTemplateById(template.id), same(template));
    }
  });

  test('카드 카탈로그: 보상 카드 ID가 전부 카탈로그에 존재한다 (진행률 일치 전제)', () {
    expect(cardCatalog, hasLength(15)); // 2차: yin 5종 확장
    for (final element in FiveElement.values) {
      expect(cardById('card_element_${element.name}'), isNotNull);
      expect(cardById('card_guardian_${element.name}_yang'), isNotNull);
      expect(cardById('card_guardian_${element.name}_yin'), isNotNull);
    }
    // 해금 조건은 숨기지 않는다 (06 수용 기준).
    for (final card in cardCatalog) {
      expect(card.unlockHint, isNotEmpty, reason: card.id);
    }
  });
}
