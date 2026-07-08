import '../../core/result/app_failure.dart';
import 'engine_gateway.dart';
import 'models.dart';

/// Development stand-in until the Dart engine port lands (Phase 3).
///
/// Returned values are copied from the TS engine fixture
/// `realapp/engine-fixtures/gateway-fixtures.v1.json`
/// (case `rep-1990-0315-1430-male` and `daily-2026-07-07`), so UI built
/// against this mock renders realistic data.
class MockEngineGateway implements EngineGateway {
  const MockEngineGateway();

  static const EngineMeta _meta = EngineMeta(
    engineVersion: '0.1.0-mock',
    ruleVersion: 'krlt-yaja-2026.07',
  );

  static final DateTime _minSupported = DateTime(1908, 4, 1);
  static final DateTime _maxSupported = DateTime(2101, 12, 31);

  void _validate(BirthInput input) {
    if (input.timezone != 'Asia/Seoul') {
      throw const AppFailure(AppFailureCode.invalidInput);
    }
    final date = DateTime(input.year, input.month, input.day);
    if (date.isBefore(_minSupported) || date.isAfter(_maxSupported)) {
      throw const AppFailure(AppFailureCode.outOfSupportedRange);
    }
  }

  @override
  Future<FourPillarsResult> calculateFourPillars(BirthInput input) async {
    _validate(input);
    return FourPillarsResult(
      meta: _meta,
      year: const Pillar(gan: '庚', ji: '午'),
      month: const Pillar(gan: '己', ji: '卯'),
      day: const Pillar(gan: '己', ji: '卯'),
      hour: input.birthTimeKnown ? const Pillar(gan: '辛', ji: '未') : null,
      dayMaster: '己',
      sipsin: const {
        'yearGan': '상관',
        'monthGan': '비견',
        'dayGan': '',
        'hourGan': '식신',
        'yearJi': '편인',
        'monthJi': '편관',
        'dayJi': '편관',
        'hourJi': '비견',
      },
      jijanggan: const {
        'yearJi': ['丁', '己'],
        'monthJi': ['乙'],
        'dayJi': ['乙'],
        'hourJi': ['己', '丁', '乙'],
      },
      jijangganSipsin: const {
        'yearJi': {'bongi': '편인', 'junggi': '비견'},
        'monthJi': {'bongi': '편관'},
        'dayJi': {'bongi': '편관'},
        'hourJi': {'bongi': '비견', 'junggi': '편인', 'yeogi': '편관'},
      },
    );
  }

  @override
  Future<DailyCycleResult> calculateDailyCycle(DateTime date) async {
    return DailyCycleResult(
      meta: _meta,
      date: DateTime(date.year, date.month, date.day),
      yearPillar: const Pillar(gan: '丙', ji: '午'),
      monthPillar: const Pillar(gan: '乙', ji: '未'),
      dayPillar: const Pillar(gan: '壬', ji: '午'),
      solarTermName: '소서',
    );
  }

  @override
  Future<ChemistryAnalysis> calculateChemistry(
    BirthInput a,
    BirthInput b,
  ) async {
    _validate(a);
    _validate(b);
    // fixture chem-rep-1990x1992 값 (총 78 A).
    return const ChemistryAnalysis(
      meta: _meta,
      totalScore: 78,
      grade: 'A',
      dayGanScore: 15,
      dayGanType: '비화',
      dayJiScore: 25,
      dayJiType: '육합',
      ohaengScore: 18,
      missingElements: [],
      guseongScore: 20,
      bonmyeongA: '팔백토성(八白土星)',
      bonmyeongB: '육백금성(六白金星)',
    );
  }

  @override
  Future<DailyAnalysisResult> calculateDailyAnalysis(
    BirthInput input,
    DateTime date,
  ) async {
    final natal = await calculateFourPillars(input);
    final daily = await calculateDailyCycle(date);
    return DailyAnalysisResult(
      meta: _meta,
      natal: natal,
      daily: daily,
      dayStemSipsin: '정재',
      seun: const Pillar(gan: '丙', ji: '午'),
      wolun: const Pillar(gan: '乙', ji: '未'),
    );
  }
}
