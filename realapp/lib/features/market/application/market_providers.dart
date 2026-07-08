import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/time/app_clock.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/market_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../home/application/today_fortune_provider.dart';
import '../domain/market_observation.dart';

const String marketInstrumentsAssetPath = 'assets/market/kr_instruments.json';

final marketMasterImportProvider = FutureProvider<MarketImportSummary>((
  ref,
) async {
  final jsonText = await rootBundle.loadString(marketInstrumentsAssetPath);
  return ref.watch(marketRepositoryProvider).importFromAssetJson(jsonText);
});

final marketSearchProvider =
    FutureProvider.family<List<MarketInstrument>, String>((ref, query) async {
      await ref.watch(marketMasterImportProvider.future);
      return ref.watch(marketRepositoryProvider).search(query);
    });

final marketWatchEntriesProvider = FutureProvider<List<MarketWatchEntry>>((
  ref,
) async {
  await ref.watch(marketMasterImportProvider.future);
  return ref.watch(marketRepositoryProvider).watchItems(localUserId);
});

enum MarketChecklistItem {
  news('오늘 뉴스와 공시 확인'),
  criteria('내 기준 확인'),
  calm('충동 판단 아님'),
  riskLimit('감내 범위 확인');

  const MarketChecklistItem(this.label);

  final String label;

  static MarketChecklistItem? byName(String name) {
    for (final item in values) {
      if (item.name == name) return item;
    }
    return null;
  }
}

class MarketChecklistController
    extends StateNotifier<Set<MarketChecklistItem>> {
  MarketChecklistController({
    required this.repository,
    required this.userId,
    required this.date,
  }) : super(<MarketChecklistItem>{}) {
    _load();
  }

  final MarketRepository repository;
  final String userId;
  final DateTime date;

  Future<void> _load() async {
    final saved = await repository.loadChecklist(userId: userId, date: date);
    state = {for (final name in saved) ?MarketChecklistItem.byName(name)};
  }

  Future<void> toggle(MarketChecklistItem item, bool checked) async {
    final next = {...state};
    if (checked) {
      next.add(item);
    } else {
      next.remove(item);
    }
    state = next;
    await repository.saveChecklist(
      userId: userId,
      date: date,
      completed: next.map((item) => item.name).toSet(),
    );
  }
}

final marketChecklistProvider =
    StateNotifierProvider<MarketChecklistController, Set<MarketChecklistItem>>(
      (ref) => MarketChecklistController(
        repository: ref.watch(marketRepositoryProvider),
        userId: localUserId,
        date: ref.watch(appClockProvider).todayKst(),
      ),
    );

class MarketObservationEntry {
  const MarketObservationEntry({required this.watch, required this.score});

  final MarketWatchEntry watch;
  final MarketObservationScore score;
}

final marketObservationEntriesProvider =
    FutureProvider<List<MarketObservationEntry>>((ref) async {
      final fortune = await ref.watch(todayFortuneProvider.future);
      if (fortune == null) return const [];
      final watchEntries = await ref.watch(marketWatchEntriesProvider.future);
      final checklist = ref.watch(marketChecklistProvider);

      final entries = [
        for (final watch in watchEntries)
          MarketObservationEntry(
            watch: watch,
            score: calculateMarketObservationScore(
              instrumentId: watch.instrument.id,
              name: watch.instrument.name,
              corpName: watch.instrument.corpName,
              balance: fortune.balance,
              match: fortune.match,
              analysis: fortune.analysis,
              checklistCompleted: checklist.length,
              checklistTotal: MarketChecklistItem.values.length,
              userTags: _decodeTags(watch.item.userTagsJson),
            ),
          ),
      ]..sort((a, b) => b.score.score.compareTo(a.score.score));
      return entries;
    });

List<String> _decodeTags(String jsonText) {
  final raw = jsonDecode(jsonText);
  if (raw is List) return raw.map((e) => e.toString()).toList();
  return const [];
}
