/// EngineGateway data models.
///
/// Mirrors realapp/docs/09-engine-gateway-contract.md. Pure Dart only —
/// this layer must never import Flutter. No user-facing copy fields here;
/// copy is assembled by the content layer from reason codes.
library;

enum CalendarType { solar, lunar }

enum GenderMode { male, female }

/// late_zi_hour = TS engine `yaja` (default), midnight = `joja`.
enum DayBoundaryRule { lateZiHour, midnight }

class BirthInput {
  const BirthInput({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.calendarType,
    this.isLeapMonth = false,
    this.genderMode,
    this.timezone = 'Asia/Seoul',
    this.dayBoundaryRule = DayBoundaryRule.lateZiHour,
  });

  final int year;
  final int month;
  final int day;

  /// null = birth time unknown (hour pillar omitted).
  final int? hour;
  final int? minute;

  final CalendarType calendarType;
  final bool isLeapMonth;

  /// Required only for daeun calculation; null skips daeun (09 contract).
  final GenderMode? genderMode;

  /// MVP: Asia/Seoul only. Other values are rejected with invalidInput.
  final String timezone;

  final DayBoundaryRule dayBoundaryRule;

  bool get birthTimeKnown => hour != null && minute != null;
}

class Pillar {
  const Pillar({required this.gan, required this.ji});

  factory Pillar.fromJson(Map<String, dynamic> json) =>
      Pillar(gan: json['gan'] as String, ji: json['ji'] as String);

  final String gan;
  final String ji;

  String get ganji => '$gan$ji';

  Map<String, dynamic> toJson() => {'gan': gan, 'ji': ji};

  @override
  bool operator ==(Object other) =>
      other is Pillar && other.gan == gan && other.ji == ji;

  @override
  int get hashCode => Object.hash(gan, ji);

  @override
  String toString() => ganji;
}

class EngineMeta {
  const EngineMeta({required this.engineVersion, required this.ruleVersion});

  factory EngineMeta.fromJson(Map<String, dynamic> json) => EngineMeta(
    engineVersion: json['engineVersion'] as String,
    ruleVersion: json['ruleVersion'] as String,
  );

  final String engineVersion;
  final String ruleVersion;

  Map<String, dynamic> toJson() => {
    'engineVersion': engineVersion,
    'ruleVersion': ruleVersion,
  };
}

class FourPillarsResult {
  const FourPillarsResult({
    required this.meta,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.dayMaster,
    required this.sipsin,
    required this.jijanggan,
    required this.jijangganSipsin,
  });

  final EngineMeta meta;
  final Pillar year;
  final Pillar month;
  final Pillar day;

  /// null when birth time is unknown.
  final Pillar? hour;

  final String dayMaster;

  /// Position key (e.g. yearGan) -> sipsin name, as produced by the engine.
  final Map<String, String> sipsin;

  /// Position key (e.g. yearJi) -> hidden stems.
  final Map<String, List<String>> jijanggan;

  /// Position key -> {bongi, junggi?, yeogi?} sipsin names.
  final Map<String, Map<String, String>> jijangganSipsin;

  factory FourPillarsResult.fromJson(Map<String, dynamic> json) {
    Pillar? pillarOrNull(dynamic raw) =>
        raw == null ? null : Pillar.fromJson(raw as Map<String, dynamic>);
    return FourPillarsResult(
      meta: EngineMeta.fromJson(json['meta'] as Map<String, dynamic>),
      year: Pillar.fromJson(json['year'] as Map<String, dynamic>),
      month: Pillar.fromJson(json['month'] as Map<String, dynamic>),
      day: Pillar.fromJson(json['day'] as Map<String, dynamic>),
      hour: pillarOrNull(json['hour']),
      dayMaster: json['dayMaster'] as String,
      sipsin: (json['sipsin'] as Map<String, dynamic>).cast<String, String>(),
      jijanggan: (json['jijanggan'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List).cast<String>()),
      ),
      jijangganSipsin: (json['jijangganSipsin'] as Map<String, dynamic>).map(
        (k, v) =>
            MapEntry(k, (v as Map<String, dynamic>).cast<String, String>()),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'year': year.toJson(),
    'month': month.toJson(),
    'day': day.toJson(),
    'hour': hour?.toJson(),
    'dayMaster': dayMaster,
    'sipsin': sipsin,
    'jijanggan': jijanggan,
    'jijangganSipsin': jijangganSipsin,
  };
}

class DailyCycleResult {
  const DailyCycleResult({
    required this.meta,
    required this.date,
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    this.solarTermName,
  });

  final EngineMeta meta;
  final DateTime date;
  final Pillar yearPillar;
  final Pillar monthPillar;
  final Pillar dayPillar;

  /// Set when [date] is a solar-term entry day.
  final String? solarTermName;

  factory DailyCycleResult.fromJson(Map<String, dynamic> json) =>
      DailyCycleResult(
        meta: EngineMeta.fromJson(json['meta'] as Map<String, dynamic>),
        date: DateTime.parse(json['date'] as String),
        yearPillar: Pillar.fromJson(json['yearPillar'] as Map<String, dynamic>),
        monthPillar: Pillar.fromJson(
          json['monthPillar'] as Map<String, dynamic>,
        ),
        dayPillar: Pillar.fromJson(json['dayPillar'] as Map<String, dynamic>),
        solarTermName: json['solarTermName'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'date': date.toIso8601String(),
    'yearPillar': yearPillar.toJson(),
    'monthPillar': monthPillar.toJson(),
    'dayPillar': dayPillar.toJson(),
    'solarTermName': solarTermName,
  };
}

class DailyAnalysisResult {
  const DailyAnalysisResult({
    required this.meta,
    required this.natal,
    required this.daily,
    required this.dayStemSipsin,
    required this.seun,
    required this.wolun,
  });

  final EngineMeta meta;
  final FourPillarsResult natal;
  final DailyCycleResult daily;

  /// Sipsin of today's day stem, seen from the natal day master.
  final String dayStemSipsin;

  final Pillar seun;
  final Pillar wolun;

  factory DailyAnalysisResult.fromJson(Map<String, dynamic> json) =>
      DailyAnalysisResult(
        meta: EngineMeta.fromJson(json['meta'] as Map<String, dynamic>),
        natal: FourPillarsResult.fromJson(
          json['natal'] as Map<String, dynamic>,
        ),
        daily: DailyCycleResult.fromJson(json['daily'] as Map<String, dynamic>),
        dayStemSipsin: json['dayStemSipsin'] as String,
        seun: Pillar.fromJson(json['seun'] as Map<String, dynamic>),
        wolun: Pillar.fromJson(json['wolun'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'natal': natal.toJson(),
    'daily': daily.toJson(),
    'dayStemSipsin': dayStemSipsin,
    'seun': seun.toJson(),
    'wolun': wolun.toJson(),
  };
}

/// 케미 계산 결과 (09 계약 4번 — 문구 필드 없음, TS 점수 산식이 정본).
class ChemistryAnalysis {
  const ChemistryAnalysis({
    required this.meta,
    required this.totalScore,
    required this.grade,
    required this.dayGanScore,
    required this.dayGanType,
    required this.dayJiScore,
    required this.dayJiType,
    required this.ohaengScore,
    required this.missingElements,
    required this.guseongScore,
    required this.bonmyeongA,
    required this.bonmyeongB,
  });

  final EngineMeta meta;
  final int totalScore;

  /// S/A/B/C/D (S≥85, A≥70, B≥55, C≥40).
  final String grade;

  final int dayGanScore;

  /// TS 원문 관계 문자열: 천간합/천간충/비화/상생/상극/보통.
  final String dayGanType;

  final int dayJiScore;

  /// 육합/충/형/비화/상생/상극/보통.
  final String dayJiType;

  final int ohaengScore;

  /// 두 사람을 합쳐도 0개인 오행 (한글: 목/화/토/금/수).
  final List<String> missingElements;

  final int guseongScore;
  final String bonmyeongA;
  final String bonmyeongB;

  factory ChemistryAnalysis.fromJson(Map<String, dynamic> json) =>
      ChemistryAnalysis(
        meta: EngineMeta.fromJson(json['meta'] as Map<String, dynamic>),
        totalScore: json['totalScore'] as int,
        grade: json['grade'] as String,
        dayGanScore: json['dayGanScore'] as int,
        dayGanType: json['dayGanType'] as String,
        dayJiScore: json['dayJiScore'] as int,
        dayJiType: json['dayJiType'] as String,
        ohaengScore: json['ohaengScore'] as int,
        missingElements: (json['missingElements'] as List).cast<String>(),
        guseongScore: json['guseongScore'] as int,
        bonmyeongA: json['bonmyeongA'] as String,
        bonmyeongB: json['bonmyeongB'] as String,
      );

  Map<String, dynamic> toJson() => {
    'meta': meta.toJson(),
    'totalScore': totalScore,
    'grade': grade,
    'dayGanScore': dayGanScore,
    'dayGanType': dayGanType,
    'dayJiScore': dayJiScore,
    'dayJiType': dayJiType,
    'ohaengScore': ohaengScore,
    'missingElements': missingElements,
    'guseongScore': guseongScore,
    'bonmyeongA': bonmyeongA,
    'bonmyeongB': bonmyeongB,
  };
}
