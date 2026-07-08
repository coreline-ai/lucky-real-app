import '../../core/result/app_failure.dart';
import '../compatibility/chemistry_engine.dart' as chemistry;
import '../manseryeok/engine_data.dart';
import '../manseryeok/errors.dart';
import '../manseryeok/ganji.dart' as ganji;
import '../manseryeok/normalized_context.dart';
import '../manseryeok/sipsin.dart' as sipsin;
import '../manseryeok/solar_terms.dart';
import '../manseryeok/temporal.dart';
import 'engine_gateway.dart';
import 'models.dart';

/// Dart port of the TS reference engine, verified case-by-case against
/// realapp/engine-fixtures/gateway-fixtures.v1.json (Phase 3 merge gate).
class DartEngineGateway implements EngineGateway {
  DartEngineGateway(this._data);

  static Future<DartEngineGateway> load(EngineAssetLoader loader) async {
    return DartEngineGateway(await EngineData.load(loader));
  }

  final EngineData _data;

  static const EngineMeta _meta = EngineMeta(
    engineVersion: '0.1.0-dart',
    ruleVersion: 'krlt-yaja-2026.07',
  );

  static final DateTime _minSupported = DateTime.utc(1908, 4, 1);
  static final DateTime _maxSupported = DateTime.utc(2101, 12, 31);

  /// 09 계약: 게이트웨이는 엔진 호출 전에 날짜 범위를 선검증한다.
  void _validateDate(int year, int month, int day) {
    final DateTime date;
    try {
      date = DateTime.utc(year, month, day);
    } catch (_) {
      throw const AppFailure(AppFailureCode.invalidInput);
    }
    if (date.year != year || date.month != month || date.day != day) {
      throw const AppFailure(AppFailureCode.invalidInput);
    }
    if (date.isBefore(_minSupported) || date.isAfter(_maxSupported)) {
      throw const AppFailure(AppFailureCode.outOfSupportedRange);
    }
  }

  void _validateInput(BirthInput input) {
    if (input.timezone != 'Asia/Seoul') {
      throw const AppFailure(AppFailureCode.invalidInput);
    }
    // 음력 입력은 표 데이터 범위(1899~2101)로 변환 시점에 검증되고,
    // 변환 결과(양력)에 대해 아래 범위 검증이 다시 적용된다.
    if (input.calendarType == CalendarType.solar) {
      _validateDate(input.year, input.month, input.day);
    }
  }

  Never _mapEngineError(ManseryeokException error) {
    switch (error.code) {
      case ManseryeokErrorCode.rangeError:
        throw AppFailure(
          AppFailureCode.outOfSupportedRange,
          debugDetails: error,
        );
      case ManseryeokErrorCode.nonexistentCivilTime:
        throw AppFailure(
          AppFailureCode.nonexistentCivilTime,
          debugDetails: error,
        );
      case ManseryeokErrorCode.ambiguousCivilTime:
        throw AppFailure(
          AppFailureCode.ambiguousCivilTime,
          debugDetails: error,
        );
      case ManseryeokErrorCode.dataError:
        throw AppFailure(AppFailureCode.engineDataError, debugDetails: error);
      case ManseryeokErrorCode.policyError:
        // 하한(1908 이전) 정책 오류는 계약상 범위 오류로 승격한다.
        throw AppFailure(
          error.message.contains('1908')
              ? AppFailureCode.outOfSupportedRange
              : AppFailureCode.enginePolicyError,
          debugDetails: error,
        );
    }
  }

  T _runEngine<T>(T Function() body) {
    try {
      return body();
    } on ManseryeokException catch (error) {
      _mapEngineError(error);
    }
  }

  @override
  Future<FourPillarsResult> calculateFourPillars(BirthInput input) async {
    _validateInput(input);
    return _runEngine(() {
      final context = createNormalizedContext(_data, input);
      final civil = context.solarCivilDateTime;
      _validateDate(civil.year, civil.month, civil.day);

      final result = ganji.getGanji(
        _data,
        ganji.GanjiInput(
          yearMonthDateTime: context.yearMonthContextDateTime,
          dayHourDateTime: context.dayHourContextDateTime,
          sect: context.sect,
          dayHourDateTimeSchoolApplied: context.dayHourSchoolApplied,
        ),
      );

      final includeTime = input.birthTimeKnown;
      final palja = <String, String>{
        'yearGan': result.year.gan,
        'yearJi': result.year.ji,
        'monthGan': result.month.gan,
        'monthJi': result.month.ji,
        'dayGan': result.day.gan,
        'dayJi': result.day.ji,
        'hourGan': includeTime ? result.hour.gan : '',
        'hourJi': includeTime ? result.hour.ji : '',
      };

      return FourPillarsResult(
        meta: _meta,
        year: Pillar(gan: result.year.gan, ji: result.year.ji),
        month: Pillar(gan: result.month.gan, ji: result.month.ji),
        day: Pillar(gan: result.day.gan, ji: result.day.ji),
        hour: includeTime
            ? Pillar(gan: result.hour.gan, ji: result.hour.ji)
            : null,
        dayMaster: result.day.gan,
        sipsin: sipsin.calculateSipsin(palja),
        jijanggan: sipsin.extractJijanggan(palja),
        jijangganSipsin: sipsin.calculateJijangganSipsin(palja),
      );
    });
  }

  @override
  Future<DailyCycleResult> calculateDailyCycle(DateTime date) async {
    _validateDate(date.year, date.month, date.day);
    return _runEngine(() {
      // 일진 기준 시각은 정오(12:00 KST) 고정 (09 계약).
      final noon = DateTimeParts(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: 12,
      );
      final result = ganji.getGanji(_data, ganji.GanjiInput.simple(noon));
      return DailyCycleResult(
        meta: _meta,
        date: DateTime(date.year, date.month, date.day),
        yearPillar: Pillar(gan: result.year.gan, ji: result.year.ji),
        monthPillar: Pillar(gan: result.month.gan, ji: result.month.ji),
        dayPillar: Pillar(gan: result.day.gan, ji: result.day.ji),
        solarTermName: exactSolarTermName(
          _data,
          date.year,
          date.month,
          date.day,
        ),
      );
    });
  }

  /// 케미 계산용 8글자 팔자 (시간 미상이면 시주 빈 문자열 — TS Palja와 동일).
  chemistry.ChemistryPalja _paljaOf(BirthInput input) {
    final context = createNormalizedContext(_data, input);
    final result = ganji.getGanji(
      _data,
      ganji.GanjiInput(
        yearMonthDateTime: context.yearMonthContextDateTime,
        dayHourDateTime: context.dayHourContextDateTime,
        sect: context.sect,
        dayHourDateTimeSchoolApplied: context.dayHourSchoolApplied,
      ),
    );
    final includeTime = input.birthTimeKnown;
    return chemistry.ChemistryPalja(
      yearGan: result.year.gan,
      yearJi: result.year.ji,
      monthGan: result.month.gan,
      monthJi: result.month.ji,
      dayGan: result.day.gan,
      dayJi: result.day.ji,
      hourGan: includeTime ? result.hour.gan : '',
      hourJi: includeTime ? result.hour.ji : '',
    );
  }

  @override
  Future<ChemistryAnalysis> calculateChemistry(
    BirthInput a,
    BirthInput b,
  ) async {
    _validateInput(a);
    _validateInput(b);
    return _runEngine(() {
      return chemistry.calculateChemistry(
        meta: _meta,
        paljaA: _paljaOf(a),
        paljaB: _paljaOf(b),
      );
    });
  }

  @override
  Future<DailyAnalysisResult> calculateDailyAnalysis(
    BirthInput input,
    DateTime date,
  ) async {
    final natal = await calculateFourPillars(input);
    final daily = await calculateDailyCycle(date);
    final seunPillar = ganji.seunForYear(date.year);
    return DailyAnalysisResult(
      meta: _meta,
      natal: natal,
      daily: daily,
      dayStemSipsin: sipsin.determineSipsin(
        natal.dayMaster,
        daily.dayPillar.gan,
      ),
      seun: Pillar(gan: seunPillar.gan, ji: seunPillar.ji),
      wolun: daily.monthPillar,
    );
  }
}
