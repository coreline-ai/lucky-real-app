import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/features/home/domain/lucky_numbers.dart';

void main() {
  test('lucky numbers are deterministic, unique, and within 1-99', () {
    final first = generateLuckyNumbers(
      profileId: 'birth_local_user_20260709',
      date: DateTime(2026, 7, 9),
      dailyGanji: '甲申',
      guardianElement: FiveElement.water,
      todayElement: FiveElement.wood,
      dayStemSipsin: '정관',
    );
    final second = generateLuckyNumbers(
      profileId: 'birth_local_user_20260709',
      date: DateTime(2026, 7, 9),
      dailyGanji: '甲申',
      guardianElement: FiveElement.water,
      todayElement: FiveElement.wood,
      dayStemSipsin: '정관',
    );

    expect(second, first);
    expect(first, hasLength(3));
    expect(first.toSet(), hasLength(3));
    for (final number in first) {
      expect(number, inInclusiveRange(1, 99));
    }
  });

  test('lucky numbers can change when the manseryeok seed changes', () {
    final waterDay = generateLuckyNumbers(
      profileId: 'birth_local_user_20260709',
      date: DateTime(2026, 7, 9),
      dailyGanji: '甲申',
      guardianElement: FiveElement.water,
      todayElement: FiveElement.wood,
      dayStemSipsin: '정관',
    );
    final fireDay = generateLuckyNumbers(
      profileId: 'birth_local_user_20260709',
      date: DateTime(2026, 7, 10),
      dailyGanji: '乙酉',
      guardianElement: FiveElement.fire,
      todayElement: FiveElement.metal,
      dayStemSipsin: '식신',
    );

    expect(fireDay, isNot(waterDay));
  });
}
