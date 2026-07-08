/// Port of engine/src/engine/compatibility (scoring + index) and the
/// hongyeon subset it depends on (하도수→선천수→홍국수→본명성).
///
/// 점수 산식은 TS가 정본이다 (09 계약):
/// 일간 30 + 일지 25 + 오행 보완 25 + 구성 20 = 100.
/// 문구(description/advice)는 생성하지 않는다 — 콘텐츠 레이어 책임.
/// Pure Dart — Flutter import 금지 레이어.
library;

import '../gateway/models.dart';

// ---------- 오행 매핑 (09 계약 고정표) ----------

const Map<String, String> _ganOhaeng = {
  '甲': '목',
  '乙': '목',
  '丙': '화',
  '丁': '화',
  '戊': '토',
  '己': '토',
  '庚': '금',
  '辛': '금',
  '壬': '수',
  '癸': '수',
};

const Map<String, String> _jiOhaeng = {
  '子': '수',
  '丑': '토',
  '寅': '목',
  '卯': '목',
  '辰': '토',
  '巳': '화',
  '午': '화',
  '未': '토',
  '申': '금',
  '酉': '금',
  '戌': '토',
  '亥': '수',
};

/// 상생: 목→화→토→금→수→목.
const Map<String, String> _saengSaeng = {
  '목': '화',
  '화': '토',
  '토': '금',
  '금': '수',
  '수': '목',
};

// ---------- 관계 쌍 테이블 (scoring.ts) ----------

const List<(String, String)> _ganhapPairs = [
  ('甲', '己'),
  ('乙', '庚'),
  ('丙', '辛'),
  ('丁', '壬'),
  ('戊', '癸'),
];

const List<(String, String)> _ganchungPairs = [
  ('甲', '庚'),
  ('乙', '辛'),
  ('丙', '壬'),
  ('丁', '癸'),
];

const List<(String, String)> _yukhapPairs = [
  ('子', '丑'),
  ('寅', '亥'),
  ('卯', '戌'),
  ('辰', '酉'),
  ('巳', '申'),
  ('午', '未'),
];

const List<(String, String)> _chungPairs = [
  ('子', '午'),
  ('丑', '未'),
  ('寅', '申'),
  ('卯', '酉'),
  ('辰', '戌'),
  ('巳', '亥'),
];

const List<(String, String)> _hyeongPairs = [
  ('寅', '巳'),
  ('巳', '申'),
  ('寅', '申'),
  ('丑', '戌'),
  ('戌', '未'),
  ('丑', '未'),
  ('子', '卯'),
];

bool _isPairMatch(List<(String, String)> pairs, String a, String b) {
  return pairs.any((p) => (p.$1 == a && p.$2 == b) || (p.$1 == b && p.$2 == a));
}

// ---------- 구성(hongyeon subset) ----------

const Map<String, int> _hadosuMap = {
  '甲': 1,
  '己': 1,
  '乙': 2,
  '庚': 2,
  '丙': 3,
  '辛': 3,
  '丁': 4,
  '壬': 4,
  '戊': 5,
  '癸': 5,
};

const List<({String name, String ohaeng})> _guseongData = [
  (name: '일백수성(一白水星)', ohaeng: '수'),
  (name: '이흑토성(二黑土星)', ohaeng: '토'),
  (name: '삼벽목성(三碧木星)', ohaeng: '목'),
  (name: '사록목성(四綠木星)', ohaeng: '목'),
  (name: '오황토성(五黃土星)', ohaeng: '토'),
  (name: '육백금성(六白金星)', ohaeng: '금'),
  (name: '칠적금성(七赤金星)', ohaeng: '금'),
  (name: '팔백토성(八白土星)', ohaeng: '토'),
  (name: '구자화성(九紫火星)', ohaeng: '화'),
];

({String name, String ohaeng}) _bonmyeongseong(ChemistryPalja palja) {
  final seoncheonsu =
      (_hadosuMap[palja.yearGan] ?? 0) +
      (_hadosuMap[palja.monthGan] ?? 0) +
      (_hadosuMap[palja.dayGan] ?? 0) +
      (_hadosuMap[palja.hourGan] ?? 0);
  final remainder = seoncheonsu % 9;
  final hongguksu = remainder == 0 ? 9 : remainder;
  return _guseongData[hongguksu - 1];
}

// ---------- 입력 ----------

/// TS Palja와 동일한 8글자 표현 (시간 미상이면 hourGan/hourJi는 빈 문자열).
class ChemistryPalja {
  const ChemistryPalja({
    required this.yearGan,
    required this.yearJi,
    required this.monthGan,
    required this.monthJi,
    required this.dayGan,
    required this.dayJi,
    required this.hourGan,
    required this.hourJi,
  });

  final String yearGan;
  final String yearJi;
  final String monthGan;
  final String monthJi;
  final String dayGan;
  final String dayJi;
  final String hourGan;
  final String hourJi;
}

// ---------- 부분 점수 (scoring.ts와 1:1) ----------

({int score, String type}) dayGanScore(String gan1, String gan2) {
  if (_isPairMatch(_ganhapPairs, gan1, gan2)) {
    return (score: 30, type: '천간합');
  }
  if (_isPairMatch(_ganchungPairs, gan1, gan2)) {
    return (score: 5, type: '천간충');
  }
  final oh1 = _ganOhaeng[gan1];
  final oh2 = _ganOhaeng[gan2];
  if (oh1 == null || oh2 == null) return (score: 15, type: '보통');
  if (oh1 == oh2) return (score: 15, type: '비화');
  if (_saengSaeng[oh1] == oh2 || _saengSaeng[oh2] == oh1) {
    return (score: 20, type: '상생');
  }
  return (score: 10, type: '상극');
}

({int score, String type}) dayJiScore(String ji1, String ji2) {
  if (_isPairMatch(_yukhapPairs, ji1, ji2)) return (score: 25, type: '육합');
  if (_isPairMatch(_chungPairs, ji1, ji2)) return (score: 3, type: '충');
  if (_isPairMatch(_hyeongPairs, ji1, ji2)) return (score: 5, type: '형');
  final oh1 = _jiOhaeng[ji1];
  final oh2 = _jiOhaeng[ji2];
  if (oh1 == null || oh2 == null) return (score: 12, type: '보통');
  if (oh1 == oh2) return (score: 15, type: '비화');
  if (_saengSaeng[oh1] == oh2 || _saengSaeng[oh2] == oh1) {
    return (score: 18, type: '상생');
  }
  return (score: 8, type: '상극');
}

({int score, List<String> missing}) ohaengComplementScore(
  ChemistryPalja p1,
  ChemistryPalja p2,
) {
  final count = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};
  void countPalja(ChemistryPalja p) {
    for (final gan in [p.yearGan, p.monthGan, p.dayGan, p.hourGan]) {
      final oh = _ganOhaeng[gan];
      if (oh != null) count[oh] = count[oh]! + 1;
    }
    for (final ji in [p.yearJi, p.monthJi, p.dayJi, p.hourJi]) {
      final oh = _jiOhaeng[ji];
      if (oh != null) count[oh] = count[oh]! + 1;
    }
  }

  countPalja(p1);
  countPalja(p2);

  const ideal = 16 / 5;
  final avgDeviation =
      count.values.map((c) => (c - ideal).abs()).reduce((a, b) => a + b) / 5;
  final score = (25 - avgDeviation * 5).clamp(0, double.infinity).round();
  final missing = [
    for (final e in count.entries)
      if (e.value == 0) e.key,
  ];
  return (score: score, missing: missing);
}

// ---------- 종합 ----------

String _grade(int score) {
  if (score >= 85) return 'S';
  if (score >= 70) return 'A';
  if (score >= 55) return 'B';
  if (score >= 40) return 'C';
  return 'D';
}

ChemistryAnalysis calculateChemistry({
  required EngineMeta meta,
  required ChemistryPalja paljaA,
  required ChemistryPalja paljaB,
}) {
  final dayGan = dayGanScore(paljaA.dayGan, paljaB.dayGan);
  final dayJi = dayJiScore(paljaA.dayJi, paljaB.dayJi);
  final ohaeng = ohaengComplementScore(paljaA, paljaB);

  final bmA = _bonmyeongseong(paljaA);
  final bmB = _bonmyeongseong(paljaB);
  final int guseongScore;
  if (bmA.ohaeng == bmB.ohaeng) {
    guseongScore = 12;
  } else if (_saengSaeng[bmA.ohaeng] == bmB.ohaeng ||
      _saengSaeng[bmB.ohaeng] == bmA.ohaeng) {
    guseongScore = 20;
  } else {
    guseongScore = 5;
  }

  final total = dayGan.score + dayJi.score + ohaeng.score + guseongScore;
  return ChemistryAnalysis(
    meta: meta,
    totalScore: total,
    grade: _grade(total),
    dayGanScore: dayGan.score,
    dayGanType: dayGan.type,
    dayJiScore: dayJi.score,
    dayJiType: dayJi.type,
    ohaengScore: ohaeng.score,
    missingElements: List.unmodifiable(ohaeng.missing),
    guseongScore: guseongScore,
    bonmyeongA: bmA.name,
    bonmyeongB: bmB.name,
  );
}
