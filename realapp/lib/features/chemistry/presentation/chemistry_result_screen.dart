import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/chemistry_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../engine/gateway/models.dart';
import '../../share/presentation/share_preview_screen.dart';
import '../../shared/tab_background.dart';
import '../content/chemistry_content.dart';

class ChemistryView {
  const ChemistryView({
    required this.partner,
    required this.analysis,
    required this.content,
  });

  final ChemistryProfile partner;
  final ChemistryAnalysis analysis;
  final ChemistryContent content;
}

/// 상대별 케미 계산 (캐시 우선, 엔진 버전 불일치 시 재계산).
final chemistryViewProvider = FutureProvider.autoDispose
    .family<ChemistryView?, String>((ref, partnerId) async {
      final repository = ref.watch(chemistryRepositoryProvider);
      final partner = await repository.partnerById(partnerId);
      final me = await ref
          .read(profileRepositoryProvider)
          .getActiveBirthProfile();
      if (partner == null || me == null) return null;

      // 계산이 가벼우므로 항상 재계산하고, 결과 테이블은 이력·공유용으로 upsert.
      final analysis = await ref
          .watch(engineGatewayProvider)
          .calculateChemistry(
            birthInputFromProfile(me),
            birthInputFromPartner(partner),
          );
      await repository.saveResult(
        ownerUserId: localUserId,
        partnerId: partnerId,
        analysis: analysis,
        now: ref.read(appClockProvider).nowKst(),
      );

      return ChemistryView(
        partner: partner,
        analysis: analysis,
        content: buildChemistryContent(
          analysis: analysis,
          relation: RelationTypeLabel.fromName(partner.relationType),
        ),
      );
    });

/// 케미 결과 (02): 점수·카테고리·잘 맞는 점·조심할 소통·함께할 팁.
/// 관계 단정 없이 경향으로만 표현한다. 공유 버튼은 Phase 3에서 추가.
class ChemistryResultScreen extends ConsumerWidget {
  const ChemistryResultScreen({super.key, required this.partnerId});

  final String partnerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(chemistryViewProvider(partnerId));

    return TabBackground(
      imagePath: AssetPaths.chemistryResultBackground,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(
          title: const Text('케미 결과'),
          actions: [
            if (viewAsync.valueOrNull != null)
              IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: '공유',
                onPressed: () async {
                  final view = viewAsync.valueOrNull!;
                  final displayScore = chemistryDisplayScore(view.analysis);
                  final me = await ref
                      .read(profileRepositoryProvider)
                      .getActiveBirthProfile();
                  if (!context.mounted) return;
                  final recordShared = ref.read(chemistrySharedCounterProvider);
                  await openSharePreview(
                    context,
                    SharePreviewScreen.chemistry(
                      title: '우리의 케미 리듬 ${displayScore.score}',
                      subtitle: view.content.headline,
                      myNickname: me?.displayName ?? '',
                      onSharedChemistry: recordShared,
                    ),
                  );
                },
              ),
          ],
        ),
        body: viewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: OutlinedButton(
              onPressed: () => ref.invalidate(chemistryViewProvider(partnerId)),
              child: const Text('다시 시도'),
            ),
          ),
          data: (view) {
            if (view == null) {
              return const Center(child: Text('상대 정보를 찾을 수 없어요.'));
            }
            final analysis = view.analysis;
            final displayScore = chemistryDisplayScore(analysis);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage(AssetPaths.chemistryResultBackground),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        view.partner.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '케미 리듬 ${displayScore.score}',
                        style: Theme.of(context).textTheme.displaySmall,
                        semanticsLabel:
                            '케미 리듬 ${displayScore.score}, ${displayScore.label}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayScore.label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(view.content.headline, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _ScoreRow(
                          label: '기질',
                          score: analysis.dayGanScore,
                          max: 30,
                          note: analysis.dayGanType,
                        ),
                        _ScoreRow(
                          label: '감정',
                          score: analysis.dayJiScore,
                          max: 25,
                          note: analysis.dayJiType,
                        ),
                        _ScoreRow(
                          label: '오행 균형',
                          score: analysis.ohaengScore,
                          max: 25,
                          note: '',
                        ),
                        _ScoreRow(
                          label: '기운 조화',
                          score: analysis.guseongScore,
                          max: 20,
                          note: '',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _Section(title: '잘 맞는 점', body: view.content.strengths),
                _Section(title: '조심하면 좋은 소통', body: view.content.communication),
                _Section(title: '함께 해보세요', body: view.content.togetherTip),
                _Section(title: '오행 밸런스', body: view.content.balanceNote),
                const SizedBox(height: 8),
                Text(
                  '케미 결과는 재미와 대화 소재를 위한 참고 콘텐츠예요.',
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

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.score,
    required this.max,
    required this.note,
  });

  final String label;
  final int score;
  final int max;
  final String note;

  @override
  Widget build(BuildContext context) {
    final aspectLabel = chemistryAspectLabel(
      score: score,
      max: max,
      note: note,
    );
    final detail = note.isEmpty ? aspectLabel : '$aspectLabel · $note';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: Semantics(
              label: '$label, $aspectLabel',
              excludeSemantics: true,
              child: LinearProgressIndicator(
                value: max <= 0 ? 0 : score / max,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              detail,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(body),
      ),
    );
  }
}
