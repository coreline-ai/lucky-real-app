import '../../core/result/app_failure.dart';
import 'models.dart';

/// Boundary between the app and manseryeok calculation
/// (realapp/docs/09-engine-gateway-contract.md).
///
/// Implementations must:
/// - validate the supported date range (1908-04-01 ~ 2101-12-31) BEFORE
///   calling engine code and throw [AppFailure] with
///   [AppFailureCode.outOfSupportedRange]; engine error mapping is only a
///   defense line,
/// - reject non-Asia/Seoul timezones with [AppFailureCode.invalidInput],
/// - return calculation data and reason codes only — never user-facing copy.
abstract interface class EngineGateway {
  Future<FourPillarsResult> calculateFourPillars(BirthInput input);

  Future<DailyCycleResult> calculateDailyCycle(DateTime date);

  Future<DailyAnalysisResult> calculateDailyAnalysis(
    BirthInput input,
    DateTime date,
  );

  /// 두 사람의 케미 (09 계약 4번, 2차). TS Compatibility 산식이 정본.
  Future<ChemistryAnalysis> calculateChemistry(BirthInput a, BirthInput b);
}
