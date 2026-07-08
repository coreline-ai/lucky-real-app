import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../shared/tab_background.dart';

final _recentRecordsProvider = FutureProvider<List<DailyRecord>>((ref) {
  return ref.watch(recordRepositoryProvider).recent(localUserId);
});

/// 기록 캘린더 기본 화면 (Phase 5 범위: 최근 기록 목록).
/// 월 그리드 캘린더는 무료 확장 백로그.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static String _moodLabel(String? mood) => switch (mood) {
    'great' => '😊 아주 좋았어요',
    'good' => '🙂 좋았어요',
    'neutral' => '😐 보통이었어요',
    'tired' => '😪 피곤했어요',
    'hard' => '😥 힘들었어요',
    _ => '기록 없음',
  };

  static String _guardianLabel(String? guardianId) => switch (guardianId) {
    'guardian_wood_yang' => '목의 수호신',
    'guardian_fire_yang' => '화의 수호신',
    'guardian_earth_yang' => '토의 수호신',
    'guardian_metal_yang' => '금의 수호신',
    'guardian_water_yang' => '수의 수호신',
    _ => '수호신',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recentRecordsProvider);

    return TabBackground(
      imagePath: AssetPaths.historyBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('기록')),
        body: recordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: OutlinedButton(
              onPressed: () => ref.invalidate(_recentRecordsProvider),
              child: const Text('다시 시도'),
            ),
          ),
          data: (records) {
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        AssetPaths.historyEmpty,
                        width: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('오늘의 수호신을 확인하면 첫 기록이 쌓여요.'),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      '${record.date.year}.${record.date.month}.${record.date.day}',
                    ),
                    subtitle: Text(
                      '${_moodLabel(record.mood)} · ${_guardianLabel(record.guardianId)}',
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
