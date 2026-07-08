/// 오행별 루틴 템플릿 마스터 데이터 (02 루틴 예시 표 기반).
/// 마스터 데이터는 시맨틱 ID를 사용하고 앱 버전에 포함된다 (03 규칙).
/// Pure Dart.
library;

import '../../../core/domain/five_element.dart';

class RoutineTemplate {
  const RoutineTemplate({
    required this.id,
    required this.title,
    required this.element,
    required this.durationMinutes,
    required this.description,
  });

  final String id;
  final String title;
  final FiveElement element;
  final int durationMinutes;
  final String description;
}

const List<RoutineTemplate> routineTemplates = [
  // 목: 성장, 계획
  RoutineTemplate(
    id: 'routine_wood_plan_three',
    title: '오늘 할 일 3개 적기',
    element: FiveElement.wood,
    durationMinutes: 5,
    description: '작게 시작해요. 오늘 하고 싶은 일 세 가지만 적어보세요.',
  ),
  RoutineTemplate(
    id: 'routine_wood_walk_ten',
    title: '10분 산책',
    element: FiveElement.wood,
    durationMinutes: 10,
    description: '몸을 움직이면 생각도 자라나요.',
  ),
  // 화: 표현, 활력
  RoutineTemplate(
    id: 'routine_fire_gratitude_message',
    title: '감사 메시지 보내기',
    element: FiveElement.fire,
    durationMinutes: 3,
    description: '고마운 사람에게 짧은 한마디를 전해보세요.',
  ),
  RoutineTemplate(
    id: 'routine_fire_light_stretch',
    title: '가벼운 스트레칭',
    element: FiveElement.fire,
    durationMinutes: 5,
    description: '굳은 몸을 풀면 기분도 켜져요.',
  ),
  // 토: 안정, 정리
  RoutineTemplate(
    id: 'routine_earth_desk_tidy',
    title: '책상 정리 5분',
    element: FiveElement.earth,
    durationMinutes: 5,
    description: '눈앞이 정돈되면 마음도 자리를 잡아요.',
  ),
  RoutineTemplate(
    id: 'routine_earth_slow_meal',
    title: '식사 천천히 하기',
    element: FiveElement.earth,
    durationMinutes: 20,
    description: '오늘 한 끼는 천천히, 맛에 집중해 보세요.',
  ),
  // 금: 판단, 집중
  RoutineTemplate(
    id: 'routine_metal_notification_tidy',
    title: '알림 정리',
    element: FiveElement.metal,
    durationMinutes: 5,
    description: '불필요한 알림을 꺼서 집중할 자리를 만들어요.',
  ),
  RoutineTemplate(
    id: 'routine_metal_one_decision',
    title: '미룬 결정 하나 처리',
    element: FiveElement.metal,
    durationMinutes: 10,
    description: '작은 것 하나면 충분해요. 오늘 하나만 정해보세요.',
  ),
  // 수: 회복, 흐름
  RoutineTemplate(
    id: 'routine_water_drink_water',
    title: '물 한 잔 마시기',
    element: FiveElement.water,
    durationMinutes: 1,
    description: '몸에 흐름을 만들어주는 가장 쉬운 회복이에요.',
  ),
  RoutineTemplate(
    id: 'routine_water_quiet_breathing',
    title: '조용히 호흡하기',
    element: FiveElement.water,
    durationMinutes: 3,
    description: '눈을 감고 숨을 세 번, 천천히 골라보세요.',
  ),
];

RoutineTemplate? routineTemplateById(String id) {
  for (final template in routineTemplates) {
    if (template.id == id) return template;
  }
  return null;
}
