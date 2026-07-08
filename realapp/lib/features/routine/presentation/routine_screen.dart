import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/element_colors.dart';
import '../../../core/domain/five_element.dart';
import '../../../core/time/app_clock.dart';
import '../../home/application/today_fortune_provider.dart';
import '../../shared/tab_background.dart';
import '../domain/routine_recommender.dart';
import '../domain/routine_templates.dart';

/// 루틴 탭 (02): 오늘 추천 1-3개, 완료 체크, 스트릭, 감정 체크.
/// 미완료 페널티 없음 — 문구도 압박하지 않는다.
class RoutineScreen extends ConsumerStatefulWidget {
  const RoutineScreen({super.key});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  Set<String> _completedIds = {};
  int _currentStreak = 0;
  String? _mood;
  bool _loaded = false;
  String? _loadedForUserId;
  String? _loadedForProfileKey;
  DateTime? _loadedForDate;

  String _profileKey(TodayFortune fortune) {
    final profile = fortune.profile;
    return [
      profile.id,
      profile.birthDate.toIso8601String(),
      profile.birthHour,
      profile.birthMinute,
      profile.calendarType,
      profile.isLeapMonth,
      profile.genderMode,
    ].join('|');
  }

  Future<void> _loadState(TodayFortune fortune) async {
    final userId = fortune.profile.userId;
    final today = ref.read(appClockProvider).todayKst();
    final logs = await ref
        .read(routineRepositoryProvider)
        .logsOn(userId, today);
    final streak = await ref.read(routineRepositoryProvider).streakOf(userId);
    final record = await ref
        .read(recordRepositoryProvider)
        .recordOn(userId, today);
    if (!mounted) return;
    setState(() {
      _completedIds = logs
          .where((l) => l.completed)
          .map((l) => l.routineTemplateId)
          .toSet();
      _currentStreak = streak?.currentStreak ?? 0;
      _mood = record?.mood;
      _loaded = true;
      _loadedForUserId = userId;
      _loadedForProfileKey = _profileKey(fortune);
      _loadedForDate = today;
    });
  }

  Future<void> _toggle(
    TodayFortune fortune,
    RoutineTemplate template,
    bool completed,
  ) async {
    final repository = ref.read(routineRepositoryProvider);
    final now = ref.read(appClockProvider).nowKst();
    final userId = fortune.profile.userId;

    if (completed) {
      final firstOfDay = await repository.completeRoutine(
        userId: userId,
        templateId: template.id,
        date: now,
      );
      if (firstOfDay) {
        final rewardService = ref.read(rewardServiceProvider);
        final reward = await rewardService.claimRoutineCompletion(
          profile: fortune.profile,
          guardianId: fortune.match.guardianId,
          today: ref.read(appClockProvider).todayKst(),
        );
        // 스트릭 마일스톤(3·7일) — 달빛(yin) 카드 해금 (2차).
        final streak = await repository.streakOf(userId);
        final milestones = await rewardService.claimStreakMilestones(
          userId: userId,
          currentStreak: streak?.currentStreak ?? 0,
          now: ref.read(appClockProvider).todayKst(),
        );
        if (mounted) {
          final newYin = milestones.where((m) => m.newlyUnlocked).length;
          final message = newYin > 0
              ? '연속 완료 보상! 달빛 수호신 카드를 얻었어요. 도감에서 확인해 보세요.'
              : reward != null
              ? (reward.newlyUnlocked
                    ? '오늘의 수호신 카드를 얻었어요! 도감에서 확인해 보세요.'
                    : '수호신 카드의 기운이 한 겹 더 쌓였어요.')
              : null;
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      }
    } else {
      await repository.uncompleteRoutine(
        userId: userId,
        templateId: template.id,
        date: now,
      );
    }
    ref.invalidate(todayRoutineCompletedProvider);
    await _loadState(fortune);
  }

  Future<void> _saveMood(TodayFortune fortune, String mood) async {
    await ref
        .read(recordRepositoryProvider)
        .saveMood(
          userId: fortune.profile.userId,
          date: ref.read(appClockProvider).todayKst(),
          mood: mood,
          guardianId: fortune.match.guardianId,
          now: ref.read(appClockProvider).nowKst(),
        );
    setState(() => _mood = mood);
  }

  @override
  Widget build(BuildContext context) {
    final fortuneAsync = ref.watch(todayFortuneProvider);
    final currentFortune = fortuneAsync.valueOrNull;
    final backgroundPath = currentFortune == null
        ? AssetPaths.routineTabBackground
        : AssetPaths.routineBanner(currentFortune.match.element);

    return TabBackground(
      imagePath: backgroundPath,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBackground.appBar(title: const Text('루틴')),
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
            final today = ref.read(appClockProvider).todayKst();
            final needsReload =
                !_loaded ||
                _loadedForUserId != fortune.profile.userId ||
                _loadedForProfileKey != _profileKey(fortune) ||
                _loadedForDate != today;
            if (needsReload) {
              _loadState(fortune);
              return const Center(child: CircularProgressIndicator());
            }

            final routines = recommendRoutines(
              guardianElement: fortune.match.element,
              todayElement: fortune.match.todayElement,
            );
            final allDone =
                routines.isNotEmpty &&
                routines.every((t) => _completedIds.contains(t.id));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AssetPaths.routineBanner(fortune.match.element),
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (allDone)
                        Image.asset(
                          AssetPaths.routineCompleteBadge,
                          height: 90,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  allDone
                      ? '오늘의 루틴을 모두 마쳤어요. 충분해요!'
                      : '${fortune.match.element.korean}의 기운을 채우는 오늘의 루틴이에요.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_currentStreak > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$_currentStreak일째 이어지고 있어요.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                for (final template in routines)
                  Card(
                    child: CheckboxListTile(
                      value: _completedIds.contains(template.id),
                      onChanged: (checked) =>
                          _toggle(fortune, template, checked ?? false),
                      title: Text(template.title),
                      subtitle: Text(
                        '${template.description}\n'
                        '${template.element.korean} · 약 ${template.durationMinutes}분',
                      ),
                      isThreeLine: true,
                      secondary: CircleAvatar(
                        backgroundColor: ElementColors.of(
                          template.element,
                        ).withValues(alpha: 0.2),
                        child: Text(template.element.korean),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  '오늘 기분은 어때요?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (mood, label) in const [
                      ('great', '아주 좋아요'),
                      ('good', '좋아요'),
                      ('neutral', '보통이에요'),
                      ('tired', '피곤해요'),
                      ('hard', '힘들어요'),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _mood == mood,
                        onSelected: (_) => _saveMood(fortune, mood),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '못 한 날이 있어도 괜찮아요. 내일 다시 시작하면 돼요.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
