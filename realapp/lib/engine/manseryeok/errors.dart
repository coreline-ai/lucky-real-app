/// Engine error codes. 1:1 with the TS engine's ManseryeokErrorCode
/// (engine/src/engine/core/errors.ts) so fixture error cases map directly.
enum ManseryeokErrorCode {
  rangeError('MANSERYEOK_RANGE_ERROR'),
  dataError('MANSERYEOK_DATA_ERROR'),
  ambiguousCivilTime('AMBIGUOUS_CIVIL_TIME'),
  nonexistentCivilTime('NONEXISTENT_CIVIL_TIME'),
  policyError('MANSERYEOK_POLICY_ERROR');

  const ManseryeokErrorCode(this.wireCode);

  /// Code string used in the TS engine and fixtures.
  final String wireCode;
}

class ManseryeokException implements Exception {
  const ManseryeokException(this.code, this.message);

  final ManseryeokErrorCode code;
  final String message;

  @override
  String toString() => 'ManseryeokException(${code.wireCode}: $message)';
}
