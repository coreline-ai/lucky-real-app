import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/cards/presentation/card_book_screen.dart';
import '../features/chemistry/presentation/chemistry_result_screen.dart';
import '../features/chemistry/presentation/chemistry_screen.dart';
import '../features/chemistry/presentation/partner_form_screen.dart';
import '../features/fortune/presentation/fortune_screen.dart';
import '../features/guardian/presentation/guardian_reveal_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/market/presentation/market_observation_screen.dart';
import '../features/routine/presentation/routine_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/birth_profile_form_screen.dart';
import '../features/onboarding/presentation/onboarding_intro_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'route_paths.dart';

/// 하단 6탭(홈/운세/루틴/도감/시장관찰/케미) + 온보딩/설정.
/// 시장관찰은 로컬 종목 마스터 기반 관찰 후보만 제공한다.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingIntroScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboardingForm,
        builder: (context, state) => const BirthProfileFormScreen(),
      ),
      GoRoute(
        path: RoutePaths.guardianReveal,
        builder: (context, state) => const GuardianRevealScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.chemistryAdd,
        builder: (context, state) => const PartnerFormScreen(),
      ),
      GoRoute(
        path: '${RoutePaths.chemistryResult}/:partnerId',
        builder: (context, state) => ChemistryResultScreen(
          partnerId: state.pathParameters['partnerId']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _TabScaffold(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.fortune,
                builder: (context, state) => const FortuneScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.routine,
                builder: (context, state) => const RoutineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cards,
                builder: (context, state) => const CardBookScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.market,
                builder: (context, state) => const MarketObservationScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.chemistry,
                builder: (context, state) => const ChemistryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: '홈'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: '운세'),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: '루틴',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark),
            label: '도감',
          ),
          NavigationDestination(icon: Icon(Icons.query_stats), label: '시장관찰'),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: '케미',
          ),
        ],
      ),
    );
  }
}
