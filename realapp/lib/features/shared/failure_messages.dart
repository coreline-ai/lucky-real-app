import '../../core/result/app_failure.dart';

/// 콘텐츠 레이어: 오류 코드 → 사용자 문구.
/// 05 QA 규칙 — 스택트레이스/내부 오류 원문을 노출하지 않고,
/// 불안을 조성하지 않는 안내 문구만 사용한다.
String failureMessage(AppFailureCode code) {
  switch (code) {
    case AppFailureCode.outOfSupportedRange:
      return '지원하는 날짜 범위(1908년 4월 1일 ~ 2101년)를 벗어났어요. 날짜를 확인해 주세요.';
    case AppFailureCode.nonexistentCivilTime:
      return '입력한 시각은 표준시 개편으로 실제로 존재하지 않았던 시간이에요. 앞뒤 시간으로 조정해 주세요.';
    case AppFailureCode.ambiguousCivilTime:
      return '입력한 시각은 표준시 개편으로 두 번 존재했던 시간이에요. 앞뒤 시간으로 조정해 주세요.';
    case AppFailureCode.invalidInput:
      return '입력한 정보를 다시 확인해 주세요.';
    case AppFailureCode.engineDataError:
    case AppFailureCode.enginePolicyError:
    case AppFailureCode.storageError:
    case AppFailureCode.unknown:
      return '계산 중 문제가 생겼어요. 잠시 후 다시 시도해 주세요.';
  }
}
