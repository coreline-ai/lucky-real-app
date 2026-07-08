/// 오늘의 루틴 추천 (03 추천 규칙).
/// - 하루 1-3개, 5분 이내 루틴 최소 1개 포함
/// - 수호신 오행(보완 대상) 우선, 오늘 일진 오행 1개 보조
/// - 결정적: 같은 입력은 항상 같은 추천
/// Pure Dart.
library;

import '../../../core/domain/five_element.dart';
import 'routine_templates.dart';

List<RoutineTemplate> recommendRoutines({
  required FiveElement guardianElement,
  required FiveElement todayElement,
}) {
  final primary = routineTemplates
      .where((t) => t.element == guardianElement)
      .toList();
  final secondary = routineTemplates
      .where((t) => t.element == todayElement && t.element != guardianElement)
      .toList();

  final picks = <RoutineTemplate>[...primary.take(2)];
  if (secondary.isNotEmpty && picks.length < 3) {
    picks.add(secondary.first);
  }

  // 5분 이내 루틴 보장 (03 규칙).
  if (!picks.any((t) => t.durationMinutes <= 5)) {
    final quick = routineTemplates.firstWhere((t) => t.durationMinutes <= 5);
    picks[picks.length - 1] = quick;
  }

  return List.unmodifiable(picks.take(3));
}
