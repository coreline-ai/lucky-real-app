import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/chemistry_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';
import 'package:ohaeng_guardians/features/chemistry/content/chemistry_content.dart';

/// 05 문구 원칙 게이트 (케미): 단정·공포·결제 유도 표현 전수 검사.
const List<String> _forbidden = [
  '반드시',
  '무조건',
  '실패한다',
  '위험하다',
  '헤어',
  '이별',
  '결제',
  '구매',
  '구독',
  '프리미엄',
  '광고',
];

void main() {
  test('케미 문구: 전 등급 × 전 관계 × 전 관계유형 조합에 금지 표현 없음', () {
    const meta = EngineMeta(engineVersion: 't', ruleVersion: 't');
    const grades = ['S', 'A', 'B', 'C', 'D'];
    const ganTypes = ['천간합', '천간충', '비화', '상생', '상극', '보통'];
    const jiTypes = ['육합', '충', '형', '비화', '상생', '상극', '보통'];

    for (final grade in grades) {
      for (final ganType in ganTypes) {
        for (final jiType in jiTypes) {
          for (final relation in RelationType.values) {
            for (final missing in [
              <String>[],
              ['수'],
              ['금', '토'],
            ]) {
              final analysis = ChemistryAnalysis(
                meta: meta,
                totalScore: grade == 'D' ? 20 : 70,
                grade: grade,
                dayGanScore: 10,
                dayGanType: ganType,
                dayJiScore: 10,
                dayJiType: jiType,
                ohaengScore: 10,
                missingElements: missing,
                guseongScore: 10,
                bonmyeongA: '일백수성(一白水星)',
                bonmyeongB: '구자화성(九紫火星)',
              );
              final content = buildChemistryContent(
                analysis: analysis,
                relation: relation,
              );
              for (final text in [
                content.headline,
                content.strengths,
                content.communication,
                content.togetherTip,
                content.balanceNote,
              ]) {
                expect(text, isNotEmpty);
                for (final word in _forbidden) {
                  expect(
                    text.contains(word),
                    isFalse,
                    reason: '금지 표현 "$word": $text',
                  );
                }
              }
            }
          }
        }
      }
    }
  });

  test('상대 프로필 삭제 시 케미 결과도 함께 삭제된다 (03 무결성)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = ChemistryRepository(db);

    final partnerId = await repository.addPartner(
      ownerUserId: 'user_local',
      label: '친구A',
      relationType: 'friend',
      birthDate: DateTime(1992, 7, 21),
      birthHour: 9,
      birthMinute: 0,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      now: DateTime(2026, 7, 8),
    );
    await repository.saveResult(
      ownerUserId: 'user_local',
      partnerId: partnerId,
      analysis: const ChemistryAnalysis(
        meta: EngineMeta(engineVersion: 't', ruleVersion: 't'),
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
      ),
      now: DateTime(2026, 7, 8),
    );
    expect(await db.select(db.chemistryResults).get(), hasLength(1));

    await repository.deletePartner(partnerId);

    expect(await repository.partners('user_local'), isEmpty);
    expect(await db.select(db.chemistryResults).get(), isEmpty);
  });
}
