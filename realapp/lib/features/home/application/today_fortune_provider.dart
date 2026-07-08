import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/time/app_clock.dart';
import '../../../data/local/app_database.dart';
import '../../../engine/five_elements/element_balance.dart';
import '../../../engine/five_elements/guardian_selector.dart';
import '../../../engine/gateway/models.dart';
import '../../cards/application/reward_service.dart';
import '../../fortune/content/fortune_content.dart';

/// 홈/운세 탭이 함께 쓰는 오늘 데이터 번들.
/// 같은 프로필·같은 날짜는 항상 같은 결과를 낸다 (스냅샷 캐시 + 결정적 셀렉터).
class TodayFortune {
  const TodayFortune({
    required this.profile,
    required this.analysis,
    required this.balance,
    required this.match,
    required this.content,
    required this.dailyReward,
  });

  final BirthProfile profile;
  final DailyAnalysisResult analysis;
  final ElementBalance balance;
  final GuardianMatch match;
  final FortuneContent content;

  /// 이번 로드에서 지급된 일일 확인 보상 (이미 받았으면 null).
  final RewardClaim? dailyReward;
}

/// null = 프로필 없음 (첫 방문 상태).
final todayFortuneProvider = FutureProvider<TodayFortune?>((ref) async {
  final profile = await ref.watch(activeBirthProfileProvider.future);
  if (profile == null) return null;

  final today = ref.watch(appClockProvider).todayKst();
  final repository = ref.watch(dailyFortuneRepositoryProvider);

  final analysis = await repository.getOrCreateToday(profile, today);
  final previousGuardianId = await repository.guardianIdOn(
    profile.userId,
    today.subtract(const Duration(days: 1)),
  );

  final balance = calculateElementBalance(analysis.natal);
  final match = selectGuardian(
    balance: balance,
    daily: analysis.daily,
    previousGuardianId: previousGuardianId,
  );
  await repository.saveGuardianId(profile.userId, today, match.guardianId);

  // 일일 확인 보상 (날짜당 1회, deterministic seed — 04 보상 규칙).
  final dailyReward = await ref
      .read(rewardServiceProvider)
      .claimDailyCheckIn(profile: profile, analysis: analysis, today: today);

  return TodayFortune(
    profile: profile,
    analysis: analysis,
    balance: balance,
    match: match,
    content: buildFortuneContent(analysis: analysis, match: match),
    dailyReward: dailyReward,
  );
});

/// 오늘 완료한 루틴 수 (홈 상태표의 "루틴 완료" 상태용).
final todayRoutineCompletedProvider = FutureProvider<int>((ref) async {
  final profile = await ref.watch(activeBirthProfileProvider.future);
  if (profile == null) return 0;
  final today = ref.watch(appClockProvider).todayKst();
  return ref
      .watch(routineRepositoryProvider)
      .completedCountOn(profile.userId, today);
});
