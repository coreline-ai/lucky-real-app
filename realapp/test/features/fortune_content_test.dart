import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';
import 'package:ohaeng_guardians/engine/five_elements/element_balance.dart';
import 'package:ohaeng_guardians/engine/five_elements/guardian_selector.dart';
import 'package:ohaeng_guardians/engine/gateway/mock_engine_gateway.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/fortune/content/fortune_content.dart';

/// 05 문구 원칙 게이트: 단정·공포·결제 유도 표현 전수 검사.
const List<String> _forbidden = [
  '반드시',
  '무조건',
  '실패한다',
  '위험하다',
  '결제',
  '구매',
  '구독',
  '프리미엄',
  '광고',
  '할인',
];

void main() {
  test('모든 십신 그룹·오행 조합의 문구에 금지 표현이 없다', () async {
    final gateway = const MockEngineGateway();
    final base = await gateway.calculateDailyAnalysis(
      BirthInput(
        year: 1990,
        month: 3,
        day: 15,
        hour: 14,
        minute: 30,
        calendarType: CalendarType.solar,
      ),
      DateTime(2026, 7, 7),
    );

    const allSipsin = [
      '비견',
      '겁재',
      '식신',
      '상관',
      '편재',
      '정재',
      '편관',
      '정관',
      '편인',
      '정인',
      '',
    ];

    for (final sipsin in allSipsin) {
      final analysis = DailyAnalysisResult(
        meta: base.meta,
        natal: base.natal,
        daily: base.daily,
        dayStemSipsin: sipsin,
        seun: base.seun,
        wolun: base.wolun,
      );
      for (final element in FiveElement.values) {
        final match = GuardianMatch(
          element: element,
          reasonCodes: const [
            GuardianReasonCodes.weakElementSupport,
            GuardianReasonCodes.dailyTengodFocus,
            GuardianReasonCodes.dominantElementBalance,
            GuardianReasonCodes.collectionRotation,
          ],
          todayElement: element,
        );
        final content = buildFortuneContent(analysis: analysis, match: match);
        final all = [
          content.oneLiner,
          content.overall,
          content.relationship,
          content.action,
          content.emotion,
          content.workStudy,
          content.condition,
          content.caution,
          content.elementKeyword,
          content.guardianReason,
        ];
        for (final text in all) {
          expect(text, isNotEmpty);
          for (final word in _forbidden) {
            expect(
              text.contains(word),
              isFalse,
              reason: '금지 표현 "$word" 발견: $text',
            );
          }
        }
      }
    }
  });

  test('수호신 산출 이유는 한두 문장이다 (수용 기준)', () async {
    final balance = ElementBalance({
      for (final e in FiveElement.values) e: 1.0,
      FiveElement.water: 0.1,
    });
    final gateway = const MockEngineGateway();
    final daily = await gateway.calculateDailyCycle(DateTime(2026, 7, 7));
    final match = selectGuardian(balance: balance, daily: daily);
    final analysis = await gateway.calculateDailyAnalysis(
      BirthInput(
        year: 1990,
        month: 3,
        day: 15,
        hour: 14,
        minute: 30,
        calendarType: CalendarType.solar,
      ),
      DateTime(2026, 7, 7),
    );
    final content = buildFortuneContent(analysis: analysis, match: match);

    final sentences = content.guardianReason
        .split('.')
        .where((s) => s.trim().isNotEmpty)
        .length;
    expect(sentences, inInclusiveRange(1, 2));
  });
}
