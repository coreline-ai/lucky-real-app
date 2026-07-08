import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../shared/tab_background.dart';
import '../content/chemistry_content.dart';

final partnersProvider = FutureProvider<List<ChemistryProfile>>((ref) {
  return ref.watch(chemistryRepositoryProvider).partners(localUserId);
});

/// 케미 탭 (02): 상대 목록 + 추가. 결과는 상대 선택 시 계산·표시.
class ChemistryScreen extends ConsumerWidget {
  const ChemistryScreen({super.key});

  Future<void> _deletePartner(
    BuildContext context,
    WidgetRef ref,
    ChemistryProfile partner,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${partner.label} 삭제'),
        content: const Text('상대 정보와 케미 기록이 함께 삭제돼요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(chemistryRepositoryProvider).deletePartner(partner.id);
    ref.invalidate(partnersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnersAsync = ref.watch(partnersProvider);

    return TabBackground(
      imagePath: AssetPaths.chemistryResultBackground,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('케미')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(RoutePaths.chemistryAdd),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('상대 추가'),
        ),
        body: partnersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: OutlinedButton(
              onPressed: () => ref.invalidate(partnersProvider),
              child: const Text('다시 시도'),
            ),
          ),
          data: (partners) {
            if (partners.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '친구의 생년월일을 입력해 첫 케미를 확인하세요.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: partners.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final partner = partners[index];
                final relation = RelationTypeLabel.fromName(
                  partner.relationType,
                );
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(relation.korean[0])),
                    title: Text(partner.label),
                    subtitle: Text(relation.korean),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: '삭제',
                      onPressed: () => _deletePartner(context, ref, partner),
                    ),
                    onTap: () => context.push(
                      '${RoutePaths.chemistryResult}/${partner.id}',
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
