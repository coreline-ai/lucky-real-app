/// Failure codes shared across the app.
///
/// Engine-related codes follow the EngineGateway contract
/// (realapp/docs/09-engine-gateway-contract.md). User-facing copy for each
/// code lives in the content layer, never here.
enum AppFailureCode {
  outOfSupportedRange,
  nonexistentCivilTime,
  ambiguousCivilTime,
  engineDataError,
  enginePolicyError,
  invalidInput,
  storageError,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(this.code, {this.debugDetails});

  final AppFailureCode code;

  /// Internal diagnostics only. Never shown to the user (05 QA rule).
  final Object? debugDetails;

  @override
  String toString() => 'AppFailure(${code.name})';
}
