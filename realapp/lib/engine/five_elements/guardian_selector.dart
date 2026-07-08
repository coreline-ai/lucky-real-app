/// 오늘의 수호신 매칭 (03 매칭 규칙 6단계).
/// 결정적이다: 같은 입력(원국 분포, 오늘 일진, 직전 수호신)은 항상 같은 결과.
/// Pure Dart — Flutter import 금지 레이어.
library;

import '../../core/domain/five_element.dart';
import '../gateway/models.dart';
import 'element_balance.dart';

/// 03 근거 코드.
class GuardianReasonCodes {
  const GuardianReasonCodes._();

  static const String weakElementSupport = 'weak_element_support';
  static const String dominantElementBalance = 'dominant_element_balance';
  static const String dailyTengodFocus = 'daily_tengod_focus';
  static const String collectionRotation = 'collection_rotation';
}

class GuardianMatch {
  const GuardianMatch({
    required this.element,
    required this.reasonCodes,
    required this.todayElement,
  });

  final FiveElement element;
  final List<String> reasonCodes;
  final FiveElement todayElement;

  /// 1차 개발은 오행별 양(yang) 수호신 5종만 사용한다 (결정 기록).
  String get guardianId => 'guardian_${element.name}_yang';
}

/// 03 매칭 규칙:
/// 1) 원국 오행 분포 → 2) 오늘 일진 오행 반영 → 3) 과다 오행은 완충 →
/// 4) 부족 오행 보충 후보 → 5) 연속 중복 시 다양성 보정 → 6) 근거 코드 기록.
GuardianMatch selectGuardian({
  required ElementBalance balance,
  required DailyCycleResult daily,
  String? previousGuardianId,
}) {
  final todayElement = ganElement[daily.dayPillar.gan] ?? FiveElement.earth;

  var selected = balance.weakest;
  final codes = <String>[GuardianReasonCodes.weakElementSupport];

  // 다양성 보정: 어제와 같은 수호신이면 그다음 부족 오행으로.
  final candidate = GuardianMatch(
    element: selected,
    reasonCodes: codes,
    todayElement: todayElement,
  );
  if (previousGuardianId != null &&
      candidate.guardianId == previousGuardianId) {
    selected = balance.weakestExcluding(selected);
    codes.insert(0, GuardianReasonCodes.collectionRotation);
  }

  // 오늘 일진과의 연결.
  if (selected == todayElement || saeng[todayElement] == selected) {
    codes.add(GuardianReasonCodes.dailyTengodFocus);
  }

  // 선택 오행이 과다 오행을 극해 완충하는 경우.
  if (geuk[selected] == balance.dominant && balance.dominant != selected) {
    codes.add(GuardianReasonCodes.dominantElementBalance);
  }

  return GuardianMatch(
    element: selected,
    reasonCodes: List.unmodifiable(codes),
    todayElement: todayElement,
  );
}
