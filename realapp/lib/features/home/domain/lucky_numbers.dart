import '../../../core/domain/five_element.dart';

List<int> generateLuckyNumbers({
  required String profileId,
  required DateTime date,
  required String dailyGanji,
  required FiveElement guardianElement,
  required FiveElement todayElement,
  required String dayStemSipsin,
}) {
  final dateKey =
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
  var seed = _fnv1a32(
    '$profileId|$dateKey|$dailyGanji|${guardianElement.name}|'
    '${todayElement.name}|$dayStemSipsin',
  );
  final numbers = <int>{};
  while (numbers.length < 3) {
    seed = _nextSeed(seed);
    numbers.add(seed % 99 + 1);
  }
  return numbers.toList()..sort();
}

int _fnv1a32(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

int _nextSeed(int seed) => (seed * 1103515245 + 12345) & 0x7fffffff;
