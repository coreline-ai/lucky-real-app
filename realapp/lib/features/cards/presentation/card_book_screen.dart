import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/element_colors.dart';
import '../../../core/constants/system_ui_styles.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../shared/tab_background.dart';
import '../domain/card_catalog.dart';

/// 소유 카드 맵 (도감 진행률의 단일 근거 — 화면과 진행률이 같은 데이터를 쓴다).
final ownedCardsProvider = FutureProvider<Map<String, OwnedCard>>((ref) async {
  final owned = await ref.watch(cardRepositoryProvider).ownedCards(localUserId);
  return {for (final card in owned) card.cardId: card};
});

/// 도감 (02): 목록, 진행률, 카드 상세, 중복 count.
/// 모든 카드는 무료 활동으로만 해금된다 — 구매/가격/희소성 압박 UI 없음.
class CardBookScreen extends ConsumerWidget {
  const CardBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedAsync = ref.watch(ownedCardsProvider);

    return TabBackground(
      imagePath: AssetPaths.collectionTabBackground,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('도감'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: AppSystemUiStyles.lightStatusBar,
        ),
        body: ownedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: OutlinedButton(
              onPressed: () => ref.invalidate(ownedCardsProvider),
              child: const Text('다시 시도'),
            ),
          ),
          data: (owned) {
            final progress = owned.length / cardCatalog.length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${owned.length}/${cardCatalog.length}'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '카드는 일일 확인과 루틴 완료로 모아요.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                  children: [
                    for (final card in cardCatalog)
                      _CardTile(card: card, owned: owned[card.id]),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  const _CardTile({required this.card, required this.owned});

  final CardDefinition card;
  final OwnedCard? owned;

  void _showDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(_artFor(card), height: 200),
              ),
            ),
            const SizedBox(height: 8),
            Text(card.flavorText),
            const SizedBox(height: 8),
            Text(
              owned == null
                  ? '아직 만나지 못한 카드예요. ${card.unlockHint}.'
                  : '획득 ${owned!.count}회 · ${_sourceLabel(owned!.firstSource)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  static String _sourceLabel(String source) => switch (source) {
    'first_visit' => '첫 만남으로 획득',
    'daily_guardian' => '일일 확인으로 획득',
    'routine' => '루틴 완료로 획득',
    'streak' => '연속 완료로 획득',
    'chemistry' => '케미 공유로 획득',
    _ => '활동으로 획득',
  };

  static String _artFor(CardDefinition card) {
    if (card.isYin) return AssetPaths.guardianCardArtYin(card.element);
    if (card.isGuardian) return AssetPaths.guardianCardArt(card.element);
    return AssetPaths.elementCardArt(card.element);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwned = owned != null;
    final color = ElementColors.of(card.element);
    final borderColor = isOwned
        ? color.withValues(alpha: 0.45)
        : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55);

    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        label: '${card.name}, ${isOwned ? '보유, ${owned!.count}장' : '미보유'}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            color: isOwned
                ? color.withValues(alpha: 0.08)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: isOwned
                      ? Image.asset(_artFor(card), fit: BoxFit.cover)
                      : Opacity(
                          opacity: 0.68,
                          child: Image.asset(
                            AssetPaths.cardBack,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOwned ? card.name : '???',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (isOwned && owned!.count > 1)
                Text(
                  '×${owned!.count}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
