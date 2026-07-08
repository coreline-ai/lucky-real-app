import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/result/app_failure.dart';
import 'package:ohaeng_guardians/engine/gateway/dart_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/engine/manseryeok/engine_data.dart';
import 'package:ohaeng_guardians/engine/manseryeok/lunar_solar.dart' as ls;

/// Phase 3 머지 게이트: TS 엔진 fixture 27케이스 전건 일치.
/// 불일치는 원인 문서화 전까지 머지 금지 (dev-plan 규칙).
void main() {
  late Map<String, dynamic> fixtures;
  late DartEngineGateway gateway;
  late EngineData data;

  setUpAll(() async {
    fixtures =
        jsonDecode(
              File(
                'engine-fixtures/gateway-fixtures.v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    data = await EngineData.load((path) => File(path).readAsString());
    gateway = DartEngineGateway(data);
  });

  BirthInput birthInputFrom(Map<String, dynamic> tsCase) {
    final input = tsCase['input'] as Map<String, dynamic>;
    final options = tsCase['options'] as Map<String, dynamic>?;
    final midnightMode = options?['midnightMode'] as String? ?? 'yaja';
    return BirthInput(
      year: input['year'] as int,
      month: input['month'] as int,
      day: input['day'] as int,
      hour: input['hour'] as int?,
      minute: input['minute'] as int?,
      calendarType: (input['isLunar'] as bool)
          ? CalendarType.lunar
          : CalendarType.solar,
      isLeapMonth: input['isLeapMonth'] as bool? ?? false,
      dayBoundaryRule: midnightMode == 'joja'
          ? DayBoundaryRule.midnight
          : DayBoundaryRule.lateZiHour,
    );
  }

  void expectPillar(Pillar? actual, Map<String, dynamic>? expected, String id) {
    if (expected == null) {
      expect(actual, isNull, reason: '$id: hour pillar should be null');
      return;
    }
    expect(actual, isNotNull, reason: '$id: pillar missing');
    expect(actual!.gan, expected['gan'], reason: '$id gan');
    expect(actual.ji, expected['ji'], reason: '$id ji');
  }

  AppFailureCode expectedFailureFor(String? tsCode) {
    // 09 계약: 범위 위반은 선검증으로 OUT_OF_SUPPORTED_RANGE 단일화.
    switch (tsCode) {
      case 'AMBIGUOUS_CIVIL_TIME':
        return AppFailureCode.ambiguousCivilTime;
      case 'NONEXISTENT_CIVIL_TIME':
        return AppFailureCode.nonexistentCivilTime;
      case 'MANSERYEOK_POLICY_ERROR':
      case null:
        return AppFailureCode.outOfSupportedRange;
      default:
        return AppFailureCode.unknown;
    }
  }

  test('fourPillars cases match the TS fixture exactly', () async {
    final cases = (fixtures['fourPillars'] as List)
        .cast<Map<String, dynamic>>();
    expect(cases, isNotEmpty);

    for (final tsCase in cases) {
      final id = tsCase['id'] as String;
      final input = birthInputFrom(tsCase);

      if (tsCase.containsKey('error')) {
        final tsCode =
            (tsCase['error'] as Map<String, dynamic>)['code'] as String?;
        await expectLater(
          gateway.calculateFourPillars(input),
          throwsA(
            isA<AppFailure>().having(
              (f) => f.code,
              'code',
              expectedFailureFor(tsCode),
            ),
          ),
          reason: id,
        );
        continue;
      }

      final expected = tsCase['expected'] as Map<String, dynamic>;
      final expectedPillars = expected['pillars'] as Map<String, dynamic>;
      final actual = await gateway.calculateFourPillars(input);

      expectPillar(
        actual.year,
        expectedPillars['year'] as Map<String, dynamic>,
        '$id year',
      );
      expectPillar(
        actual.month,
        expectedPillars['month'] as Map<String, dynamic>,
        '$id month',
      );
      expectPillar(
        actual.day,
        expectedPillars['day'] as Map<String, dynamic>,
        '$id day',
      );
      expectPillar(
        actual.hour,
        expectedPillars['hour'] as Map<String, dynamic>?,
        '$id hour',
      );
      expect(actual.dayMaster, expected['dayMaster'], reason: '$id dayMaster');
      expect(actual.sipsin, expected['sipsin'], reason: '$id sipsin');
      expect(actual.jijanggan, expected['jijanggan'], reason: '$id jijanggan');
      expect(
        actual.jijangganSipsin,
        expected['jijangganSipsin'],
        reason: '$id jijangganSipsin',
      );
    }
  });

  test('dailyCycle cases match the TS fixture exactly', () async {
    final cases = (fixtures['dailyCycle'] as List).cast<Map<String, dynamic>>();
    expect(cases, isNotEmpty);

    for (final tsCase in cases) {
      final id = tsCase['id'] as String;
      final date = tsCase['date'] as Map<String, dynamic>;
      final expected = tsCase['expected'] as Map<String, dynamic>;
      final actual = await gateway.calculateDailyCycle(
        DateTime(date['year'] as int, date['month'] as int, date['day'] as int),
      );

      expectPillar(
        actual.yearPillar,
        expected['yearPillar'] as Map<String, dynamic>,
        '$id year',
      );
      expectPillar(
        actual.monthPillar,
        expected['monthPillar'] as Map<String, dynamic>,
        '$id month',
      );
      expectPillar(
        actual.dayPillar,
        expected['dayPillar'] as Map<String, dynamic>,
        '$id day',
      );

      final solarContext = expected['solarContext'] as Map<String, dynamic>;
      expect(
        actual.solarTermName,
        solarContext['exactSolarTerm'],
        reason: '$id exactSolarTerm',
      );
    }
  });

  test('dailyAnalysis cases match the TS fixture exactly', () async {
    final cases = (fixtures['dailyAnalysis'] as List)
        .cast<Map<String, dynamic>>();
    final fourPillarCases = (fixtures['fourPillars'] as List)
        .cast<Map<String, dynamic>>();
    expect(cases, isNotEmpty);

    for (final tsCase in cases) {
      final id = tsCase['id'] as String;
      final natalCase = fourPillarCases.firstWhere(
        (c) => c['id'] == tsCase['natalId'],
      );
      final date = tsCase['date'] as Map<String, dynamic>;
      final expected =
          (tsCase['expected'] as Map<String, dynamic>)['interaction']
              as Map<String, dynamic>;

      final actual = await gateway.calculateDailyAnalysis(
        birthInputFrom(natalCase),
        DateTime(date['year'] as int, date['month'] as int, date['day'] as int),
      );

      expect(
        actual.dayStemSipsin,
        expected['dayStemSipsin'],
        reason: '$id dayStemSipsin',
      );
      expectPillar(
        actual.seun,
        expected['seun'] as Map<String, dynamic>,
        '$id seun',
      );
      expectPillar(
        actual.wolun,
        expected['wolun'] as Map<String, dynamic>,
        '$id wolun',
      );
    }
  });

  test('chemistry cases match the TS fixture exactly', () async {
    final cases = (fixtures['chemistry'] as List).cast<Map<String, dynamic>>();
    expect(cases, isNotEmpty);

    BirthInput personFrom(Map<String, dynamic> raw) => BirthInput(
      year: raw['year'] as int,
      month: raw['month'] as int,
      day: raw['day'] as int,
      hour: raw['hour'] as int?,
      minute: raw['minute'] as int?,
      calendarType: (raw['isLunar'] as bool? ?? false)
          ? CalendarType.lunar
          : CalendarType.solar,
      isLeapMonth: raw['isLeapMonth'] as bool? ?? false,
    );

    for (final tsCase in cases) {
      final id = tsCase['id'] as String;
      final input = tsCase['input'] as Map<String, dynamic>;
      final expected = tsCase['expected'] as Map<String, dynamic>;

      final actual = await gateway.calculateChemistry(
        personFrom(input['personA'] as Map<String, dynamic>),
        personFrom(input['personB'] as Map<String, dynamic>),
      );

      expect(actual.totalScore, expected['totalScore'], reason: '$id total');
      expect(actual.grade, expected['grade'], reason: '$id grade');

      final dayGan = expected['dayGan'] as Map<String, dynamic>;
      expect(actual.dayGanScore, dayGan['score'], reason: '$id dayGan score');
      expect(actual.dayGanType, dayGan['type'], reason: '$id dayGan type');

      final dayJi = expected['dayJi'] as Map<String, dynamic>;
      expect(actual.dayJiScore, dayJi['score'], reason: '$id dayJi score');
      expect(actual.dayJiType, dayJi['type'], reason: '$id dayJi type');

      expect(
        actual.ohaengScore,
        (expected['ohaeng'] as Map<String, dynamic>)['score'],
        reason: '$id ohaeng',
      );

      final guseong = expected['guseong'] as Map<String, dynamic>;
      expect(actual.guseongScore, guseong['score'], reason: '$id guseong');
      expect(
        '${actual.bonmyeongA} × ${actual.bonmyeongB}',
        guseong['pair'],
        reason: '$id bonmyeong pair',
      );
    }
  });

  test('lunarSolar conversion cases match the TS fixture exactly', () {
    final cases = (fixtures['lunarSolar'] as List).cast<Map<String, dynamic>>();
    expect(cases, isNotEmpty);

    for (final tsCase in cases) {
      final id = tsCase['id'] as String;
      final input = tsCase['input'] as Map<String, dynamic>;
      final expected = tsCase['expected'] as Map<String, dynamic>;

      if (tsCase['direction'] == 'solarToLunar') {
        final actual = ls.solarToLunar(
          data,
          input['year'] as int,
          input['month'] as int,
          input['day'] as int,
        );
        expect(actual.year, expected['year'], reason: id);
        expect(actual.month, expected['month'], reason: id);
        expect(actual.day, expected['day'], reason: id);
        expect(actual.isLeapMonth, expected['isLeapMonth'], reason: id);
      } else {
        final actual = ls.lunarToSolar(
          data,
          input['year'] as int,
          input['month'] as int,
          input['day'] as int,
          input['isLeapMonth'] as bool? ?? false,
        );
        expect(actual.year, expected['year'], reason: id);
        expect(actual.month, expected['month'], reason: id);
        expect(actual.day, expected['day'], reason: id);
      }
    }
  });
}
