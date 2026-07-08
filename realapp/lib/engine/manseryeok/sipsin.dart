/// Port of engine/src/engine/saju/sipsin.ts (십신/지장간 subset used by the
/// gateway contract).
library;

/// 각 지지에 숨어 있는 천간 목록 (본기, 중기, 여기 순).
const Map<String, List<String>> jijangganTable = {
  '子': ['癸', '壬'],
  '丑': ['己', '癸', '辛'],
  '寅': ['甲', '丙', '戊'],
  '卯': ['乙'],
  '辰': ['戊', '乙', '癸'],
  '巳': ['丙', '庚', '戊'],
  '午': ['丁', '己'],
  '未': ['己', '丁', '乙'],
  '申': ['庚', '壬', '戊'],
  '酉': ['辛'],
  '戌': ['戊', '辛', '丁'],
  '亥': ['壬', '甲'],
};

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

const Map<String, String> _saengSaeng = {
  '목': '화',
  '화': '토',
  '토': '금',
  '금': '수',
  '수': '목',
};

const Map<String, String> _sangGeuk = {
  '목': '토',
  '토': '수',
  '수': '화',
  '화': '금',
  '금': '목',
};

const Set<String> _yangGan = {'甲', '丙', '戊', '庚', '壬'};

String determineSipsin(String dayGan, String targetGan) {
  final myOhaeng = _ganOhaeng[dayGan];
  final targetOhaeng = _ganOhaeng[targetGan];
  if (myOhaeng == null || targetOhaeng == null) return '';

  final sameYinYang = _yangGan.contains(dayGan) == _yangGan.contains(targetGan);

  if (myOhaeng == targetOhaeng) return sameYinYang ? '비견' : '겁재';
  if (_saengSaeng[myOhaeng] == targetOhaeng) return sameYinYang ? '식신' : '상관';
  if (_sangGeuk[myOhaeng] == targetOhaeng) return sameYinYang ? '편재' : '정재';
  if (_sangGeuk[targetOhaeng] == myOhaeng) return sameYinYang ? '편관' : '정관';
  if (_saengSaeng[targetOhaeng] == myOhaeng) return sameYinYang ? '편인' : '정인';
  return '';
}

const List<String> _jiPositions = ['yearJi', 'monthJi', 'dayJi', 'hourJi'];

/// palja map keys: yearGan/yearJi/monthGan/monthJi/dayGan/dayJi/hourGan/hourJi
/// (missing hour = empty string), mirroring TS Palja.
Map<String, String> calculateSipsin(Map<String, String> palja) {
  final dayGan = palja['dayGan'] ?? '';
  final result = <String, String>{
    'yearGan': (palja['yearGan'] ?? '').isNotEmpty
        ? determineSipsin(dayGan, palja['yearGan']!)
        : '',
    'monthGan': (palja['monthGan'] ?? '').isNotEmpty
        ? determineSipsin(dayGan, palja['monthGan']!)
        : '',
    'dayGan': '',
    'hourGan': (palja['hourGan'] ?? '').isNotEmpty
        ? determineSipsin(dayGan, palja['hourGan']!)
        : '',
  };

  for (final pos in _jiPositions) {
    final ji = palja[pos] ?? '';
    if (ji.isEmpty) {
      result[pos] = '';
      continue;
    }
    final hidden = jijangganTable[ji];
    if (hidden == null || hidden.isEmpty) {
      result[pos] = '';
      continue;
    }
    result[pos] = determineSipsin(dayGan, hidden.first);
  }
  return result;
}

Map<String, List<String>> extractJijanggan(Map<String, String> palja) {
  final result = <String, List<String>>{};
  for (final pos in _jiPositions) {
    final ji = palja[pos] ?? '';
    result[pos] = ji.isEmpty
        ? <String>[]
        : List<String>.of(jijangganTable[ji] ?? const []);
  }
  return result;
}

/// 지지 위치별 본기/중기/여기 십신. 지지가 없는 위치는 키를 만들지 않는다
/// (TS calculateJijangganSipsin과 동일).
Map<String, Map<String, String>> calculateJijangganSipsin(
  Map<String, String> palja,
) {
  final dayGan = palja['dayGan'] ?? '';
  final result = <String, Map<String, String>>{};
  for (final pos in _jiPositions) {
    final ji = palja[pos] ?? '';
    if (ji.isEmpty) continue;
    final gans = jijangganTable[ji];
    if (gans == null || gans.isEmpty) continue;
    final entry = <String, String>{'bongi': determineSipsin(dayGan, gans[0])};
    if (gans.length >= 2) entry['junggi'] = determineSipsin(dayGan, gans[1]);
    if (gans.length >= 3) entry['yeogi'] = determineSipsin(dayGan, gans[2]);
    result[pos] = entry;
  }
  return result;
}
