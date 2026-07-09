import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/element_colors.dart';
import '../../../core/constants/system_ui_styles.dart';
import '../../../core/domain/five_element.dart';
import '../../share/presentation/share_preview_screen.dart';
import '../../shared/tab_background.dart';
import '../application/today_fortune_provider.dart';
import '../domain/lucky_numbers.dart';

/// 오늘 홈 (02 상태표: 첫 방문/일반/루틴 완료/계산 실패/정보 부족).
/// 루틴 완료 상태 연출은 Phase 5에서 routine_logs와 연결한다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneAsync = ref.watch(todayFortuneProvider);
    final currentFortune = fortuneAsync.valueOrNull;
    final bgImage = currentFortune == null
        ? AssetPaths.homeBackground
        : AssetPaths.elementBackground(currentFortune.match.element);

    return TabBackground(
      imagePath: bgImage,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('오늘'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: AppSystemUiStyles.lightStatusBar,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: '설정',
              onPressed: () => context.push(RoutePaths.settings),
            ),
          ],
        ),
        body: fortuneAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _RetryView(),
          data: (fortune) =>
              fortune == null ? const _FirstVisitView() : _TodayView(fortune),
        ),
      ),
    );
  }
}

class _FirstVisitView extends StatelessWidget {
  const _FirstVisitView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('오늘의 수호신을 만나볼까요?'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(RoutePaths.onboarding),
            child: const Text('출생 정보 입력하기'),
          ),
        ],
      ),
    );
  }
}

class _RetryView extends ConsumerWidget {
  const _RetryView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              AssetPaths.errorEngine,
              width: 240,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text('오늘의 기운을 불러오지 못했어요.'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ref.invalidate(todayFortuneProvider),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _TodayView extends ConsumerWidget {
  const _TodayView(this.fortune);

  final TodayFortune fortune;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount =
        ref.watch(todayRoutineCompletedProvider).valueOrNull ?? 0;
    final element = fortune.match.element;
    final elementColor = ElementColors.of(element);
    final timeUnknown = fortune.analysis.natal.hour == null;
    final luckyNumbers = generateLuckyNumbers(
      profileId: fortune.profile.id,
      date: fortune.analysis.daily.date,
      dailyGanji: fortune.analysis.daily.dayPillar.ganji,
      guardianElement: fortune.match.element,
      todayElement: fortune.match.todayElement,
      dayStemSipsin: fortune.analysis.dayStemSipsin,
    );
    final guardianFrameWidth = (MediaQuery.sizeOf(context).height * 0.37)
        .clamp(216.0, 340.0)
        .toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 수호신 카드 (오행 전용 카드 배경 + 색 매칭)
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: guardianFrameWidth),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalInset = (constraints.maxWidth * 0.15)
                      .clamp(36.0, 54.0)
                      .toDouble();
                  final topInset = (constraints.maxHeight * 0.15)
                      .clamp(52.0, 78.0)
                      .toDouble();
                  final bottomInset = (constraints.maxHeight * 0.14)
                      .clamp(48.0, 74.0)
                      .toDouble();
                  final contentWidth =
                      constraints.maxWidth - horizontalInset * 2;
                  final guardianReasonWidth = (contentWidth * 0.88)
                      .clamp(168.0, 220.0)
                      .toDouble();
                  final guardianHeight = (constraints.maxHeight * 0.29)
                      .clamp(102.0, 150.0)
                      .toDouble();

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: horizontalInset,
                        top: topInset,
                        right: horizontalInset,
                        bottom: bottomInset,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: contentWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  label: '오늘의 수호신, ${element.korean}의 기운',
                                  child: Image.asset(
                                    AssetPaths.guardianIdle(element),
                                    height: guardianHeight,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '오늘의 수호신 · ${element.korean}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: guardianReasonWidth,
                                  child: Text(
                                    _formatGuardianReason(
                                      fortune.content.guardianReason,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _LuckyNumbersPlate(numbers: luckyNumbers),
                                const SizedBox(height: 8),
                                _HomeShareButton(
                                  elementColor: elementColor,
                                  onPressed: () => openSharePreview(
                                    context,
                                    SharePreviewScreen.guardian(
                                      title: '오늘의 수호신 · ${element.korean}',
                                      subtitle: fortune.content.oneLiner,
                                      element: element,
                                      myNickname: fortune.profile.displayName,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Image.asset(
                          AssetPaths.homeGuardianCardFrame,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 한 줄 운세 + 일진
        Text(
          fortune.content.oneLiner,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '오늘의 일진 ${fortune.analysis.daily.dayPillar.ganji}'
          '${fortune.analysis.daily.solarTermName != null ? ' · ${fortune.analysis.daily.solarTermName}' : ''}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (timeUnknown)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '출생 시간 미상 기준',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),

        // 오행 밸런스
        Card(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetPaths.homeBalancePanel),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오행 밸런스', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final e in FiveElement.values)
                  _BalanceRow(
                    element: e,
                    percent: fortune.balance.percentOf(e),
                  ),
                const SizedBox(height: 8),
                Text(
                  '낮은 값은 부족함이 아니라 오늘 보완하면 좋은 포인트예요.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 요약 3종 (총운/관계운/행동 조언)
        _SummaryCard(title: '총운', body: fortune.content.overall),
        _SummaryCard(title: '관계운', body: fortune.content.relationship),
        _SummaryCard(title: '행동 조언', body: fortune.content.action),
        const SizedBox(height: 16),

        // 상태별 CTA (02 상태표: 일반 → 루틴 시작 / 루틴 완료 → 보상 확인)
        if (completedCount > 0) ...[
          Card(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetPaths.homeRoutineCta),
                  fit: BoxFit.cover,
                  opacity: 0.16,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: elementColor.withValues(alpha: 0.14),
                  foregroundColor: elementColor,
                  child: const Icon(Icons.emoji_events_outlined),
                ),
                title: Text('오늘 루틴 $completedCount개 완료!'),
                subtitle: const Text('도감에서 오늘의 보상을 확인해 보세요.'),
                onTap: () => context.go(RoutePaths.cards),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(RoutePaths.routine),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('루틴 더 보기'),
          ),
        ] else
          FilledButton.icon(
            onPressed: () => context.go(RoutePaths.routine),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('오늘의 루틴 시작하기'),
          ),
        if (timeUnknown)
          TextButton(
            onPressed: () => context.push(RoutePaths.onboardingForm),
            child: const Text('출생 시간을 알게 되면 여기서 보완해 주세요'),
          ),
      ],
    );
  }
}

String _formatGuardianReason(String reason) {
  return reason
      .replaceAll(' 기운을 채워주기 위해 ', ' 기운을\n채워주기 위해 ')
      .replaceAll('. ', '.\n');
}

class _LuckyNumbersPlate extends StatelessWidget {
  const _LuckyNumbersPlate({required this.numbers});

  final List<int> numbers;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: const Color(0xFF284460),
    );
    return Semantics(
      label: '오늘의 행운 숫자 ${numbers.join(', ')}. 오늘의 기운에서 뽑은 가벼운 리듬 숫자예요.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '오늘의 행운 숫자',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          FractionallySizedBox(
            widthFactor: 0.82,
            child: AspectRatio(
              aspectRatio: 960 / 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const slotCenters = [0.27, 0.5, 0.73];
                    final slotWidth = constraints.maxWidth * 0.2;
                    final slotHeight = constraints.maxHeight * 0.5;
                    return Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          AssetPaths.homeLuckyNumbersPlate,
                          fit: BoxFit.fill,
                        ),
                        for (var i = 0; i < numbers.length; i++)
                          Positioned(
                            left:
                                constraints.maxWidth * slotCenters[i] -
                                slotWidth / 2,
                            top: constraints.maxHeight * 0.49 - slotHeight / 2,
                            width: slotWidth,
                            height: slotHeight,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  numbers[i].toString().padLeft(2, '0'),
                                  style: textStyle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Text(
            '오늘의 기운에서 뽑은 가벼운 리듬 숫자예요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HomeShareButton extends StatelessWidget {
  const _HomeShareButton({required this.elementColor, required this.onPressed});

  final Color elementColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '오늘 수호신 공유하기',
      child: FractionallySizedBox(
        widthFactor: 0.64,
        child: SizedBox(
          height: 44,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Opacity(
                  opacity: 0.26,
                  child: Image.asset(
                    AssetPaths.homeShareCtaGlow,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.ios_share, size: 17),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('오늘 수호신 공유하기'),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: elementColor.withValues(alpha: 0.92),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.element, required this.percent});

  final FiveElement element;
  final int percent;

  String get _toneLabel {
    if (percent < 10) return '보완 포인트';
    if (percent < 20) return '은은한 기운';
    if (percent < 30) return '안정적인 기운';
    return '두드러진 기운';
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = percent <= 0 ? 0.02 : percent / 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text(element.korean)),
          Expanded(
            child: Semantics(
              label: '${element.korean} $percent퍼센트, $_toneLabel',
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                color: ElementColors.of(element),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$percent%', textAlign: TextAlign.end),
                Text(
                  _toneLabel,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      // 배경 B안: 배경이 은은히 비치도록 반투명 surface
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(body),
      ),
    );
  }
}
