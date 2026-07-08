import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/element_colors.dart';
import '../../../core/domain/five_element.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../home/application/today_fortune_provider.dart';
import '../../notifications/application/notification_scheduler.dart';

/// 첫 수호신 공개 (02 온보딩 3단계): 카드 공개 연출 + 짧은 해석 +
/// 도감에 첫 카드 저장(first_visit) + 루틴 CTA.
class GuardianRevealScreen extends ConsumerStatefulWidget {
  const GuardianRevealScreen({super.key});

  @override
  ConsumerState<GuardianRevealScreen> createState() =>
      _GuardianRevealScreenState();
}

class _GuardianRevealScreenState extends ConsumerState<GuardianRevealScreen> {
  bool _cardSaved = false;

  Future<void> _saveFirstCard(TodayFortune fortune) async {
    if (_cardSaved) return;
    _cardSaved = true;
    await ref
        .read(cardRepositoryProvider)
        .unlock(
          userId: localUserId,
          cardId: 'card_${fortune.match.guardianId}',
          source: 'first_visit',
          now: ref.read(appClockProvider).nowKst(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final fortuneAsync = ref.watch(todayFortuneProvider);

    return Scaffold(
      body: SafeArea(
        child: fortuneAsync.when(
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
            _saveFirstCard(fortune);
            final element = fortune.match.element;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    '${fortune.profile.displayName}님의 오늘 수호신',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ElementColors.of(
                          element,
                        ).withValues(alpha: 0.15),
                      ),
                      child: Semantics(
                        label: '첫 수호신 카드, ${element.korean}의 기운',
                        child: Image.asset(
                          AssetPaths.guardianIdle(element),
                          height: 240,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${element.korean}의 기운',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fortune.content.guardianReason,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '첫 카드가 도감에 저장됐어요.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  // 알림 권한은 첫 수호신 공개 후에만 요청한다 (02 온보딩 4단계).
                  OutlinedButton.icon(
                    onPressed: () async {
                      final scheduler = ref.read(notificationSchedulerProvider);
                      final granted = await scheduler.requestPermission();
                      if (granted) {
                        await scheduler.update(
                          AppNotificationType.morningGuardian,
                          enabled: true,
                        );
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              granted
                                  ? '매일 아침 수호신 알림을 보내드릴게요.'
                                  : '알림은 설정에서 언제든 켤 수 있어요.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_none),
                    label: const Text('매일 아침 수호신 알림 받기'),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go(RoutePaths.home),
                      child: const Text('오늘의 루틴 보러 가기'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
