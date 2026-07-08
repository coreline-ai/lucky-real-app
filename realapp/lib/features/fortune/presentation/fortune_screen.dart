import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../home/application/today_fortune_provider.dart';
import '../../shared/tab_background.dart';

/// 운세 탭: 상세 7종 + 접힌 용어 설명 (01/02 구성).
class FortuneScreen extends ConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneAsync = ref.watch(todayFortuneProvider);

    return TabBackground(
      imagePath: AssetPaths.fortuneTabBackground,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('운세')),
        body: fortuneAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: OutlinedButton(
              onPressed: () => ref.invalidate(todayFortuneProvider),
              child: const Text('다시 시도'),
            ),
          ),
          data: (fortune) {
            if (fortune == null) {
              return Center(
                child: FilledButton(
                  onPressed: () => context.go(RoutePaths.onboarding),
                  child: const Text('출생 정보 입력하기'),
                ),
              );
            }
            final content = fortune.content;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    AssetPaths.fortuneBanner,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                _Section(title: '총운', body: content.overall),
                _Section(title: '감정 흐름', body: content.emotion),
                // 배경 B안: 관계/일·학업/컨디션 섹션에 전용 배경 스트립
                _Section(
                  title: '관계 흐름',
                  body: content.relationship,
                  backgroundPath: AssetPaths.fortuneRelationshipStrip,
                ),
                _Section(
                  title: '일/학업 흐름',
                  body: content.workStudy,
                  backgroundPath: AssetPaths.fortuneWorkStudyStrip,
                ),
                _Section(
                  title: '컨디션 흐름',
                  body: content.condition,
                  backgroundPath: AssetPaths.fortuneConditionStrip,
                ),
                _Section(title: '오늘 조심할 점', body: content.caution),
                _Section(title: '오늘의 오행 키워드', body: content.elementKeyword),
                const SizedBox(height: 8),
                const _GlossaryTile(),
                const SizedBox(height: 8),
                Text(
                  '오늘의 운세는 오락과 자기성찰을 위한 참고 콘텐츠예요.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    this.backgroundPath,
  });

  final String title;
  final String body;

  /// 배경 B안: 섹션 전용 배경 스트립 (홈 밸런스 패널과 동일한 저투명 방식).
  final String? backgroundPath;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(body),
    );
    if (backgroundPath == null) return Card(child: tile);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundPath!),
            fit: BoxFit.cover,
            opacity: 0.18,
          ),
        ),
        child: tile,
      ),
    );
  }
}

/// 전문 용어 접힌 설명 (02: 만세력 표를 앞세우지 않고, 궁금한 사람만 편다).
class _GlossaryTile extends StatelessWidget {
  const _GlossaryTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('용어가 궁금하다면'),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: const [
            _GlossaryItem('일진', '오늘 날짜에 배정된 육십갑자예요. 하루의 기운을 읽는 기준이 돼요.'),
            _GlossaryItem('일간', '내 사주에서 태어난 날의 천간이에요. 나를 대표하는 글자로 봐요.'),
            _GlossaryItem(
              '십신',
              '일간과 다른 글자들의 관계를 열 가지로 나눈 이름이에요. 오늘의 흐름을 해석하는 렌즈가 돼요.',
            ),
            _GlossaryItem('오행', '목·화·토·금·수 다섯 기운이에요. 균형을 살펴 오늘의 루틴을 골라요.'),
            _GlossaryItem('절기', '태양의 움직임으로 나눈 계절의 마디예요. 월의 기준이 돼요.'),
          ],
        ),
      ),
    );
  }
}

class _GlossaryItem extends StatelessWidget {
  const _GlossaryItem(this.term, this.description);

  final String term;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              term,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
