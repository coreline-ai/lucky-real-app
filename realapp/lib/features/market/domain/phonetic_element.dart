import '../../../core/domain/five_element.dart';

const List<FiveElement> _hangulInitialElements = [
  FiveElement.wood, // ㄱ
  FiveElement.wood, // ㄲ
  FiveElement.fire, // ㄴ
  FiveElement.fire, // ㄷ
  FiveElement.fire, // ㄸ
  FiveElement.fire, // ㄹ
  FiveElement.water, // ㅁ
  FiveElement.water, // ㅂ
  FiveElement.water, // ㅃ
  FiveElement.metal, // ㅅ
  FiveElement.metal, // ㅆ
  FiveElement.earth, // ㅇ
  FiveElement.metal, // ㅈ
  FiveElement.metal, // ㅉ
  FiveElement.metal, // ㅊ
  FiveElement.wood, // ㅋ
  FiveElement.fire, // ㅌ
  FiveElement.water, // ㅍ
  FiveElement.earth, // ㅎ
];

FiveElement? elementOfHangulSyllable(String character) {
  if (character.isEmpty) return null;
  final code = character.runes.first;
  if (code < 0xAC00 || code > 0xD7A3) return null;
  final initialIndex = (code - 0xAC00) ~/ 588;
  if (initialIndex < 0 || initialIndex >= _hangulInitialElements.length) {
    return null;
  }
  return _hangulInitialElements[initialIndex];
}

Map<FiveElement, int> phoneticElementCounts(String value) {
  final counts = {for (final element in FiveElement.values) element: 0};
  for (final rune in value.runes) {
    final element = elementOfHangulSyllable(String.fromCharCode(rune));
    if (element != null) counts[element] = counts[element]! + 1;
  }
  return counts;
}

FiveElement? primaryPhoneticElement(String value) {
  final counts = phoneticElementCounts(value);
  FiveElement? selected;
  var best = 0;
  for (final element in FiveElement.values) {
    final count = counts[element] ?? 0;
    if (count > best) {
      selected = element;
      best = count;
    }
  }
  return selected;
}
