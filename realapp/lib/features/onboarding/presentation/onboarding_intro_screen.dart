import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';

class _IntroPage {
  const _IntroPage(this.asset, this.title, this.body);

  final String asset;
  final String title;
  final String body;
}

/// 앱 소개 3장 (02: 모든 개념을 한 화면에 설명하지 않는다).
class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  static const List<_IntroPage> _pages = [
    _IntroPage(
      AssetPaths.onboardingGuardianIntro,
      '오늘의 수호신을 만나요',
      '내 사주와 오늘의 기운으로 매일 다른 수호신이 찾아와요.',
    ),
    _IntroPage(
      AssetPaths.onboardingRoutineIntro,
      '나에게 맞는 오행 루틴',
      '오늘의 균형에 맞춘 작은 실천 한 가지면 충분해요.',
    ),
    _IntroPage(
      AssetPaths.onboardingCollectionRecord,
      '기록과 도감이 쌓여요',
      '하루하루의 확인과 실천이 카드와 기록으로 남아요.',
    ),
  ];

  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goPrevious() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _goNext() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _index == 0) return;
        _goPrevious();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(page.asset, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(page.body, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    const Spacer(),
                    if (_index > 0) ...[
                      TextButton.icon(
                        onPressed: _goPrevious,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('이전'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilledButton(
                      onPressed: () {
                        if (isLast) {
                          context.go(RoutePaths.onboardingForm);
                        } else {
                          _goNext();
                        }
                      },
                      child: Text(isLast ? '시작하기' : '다음'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
