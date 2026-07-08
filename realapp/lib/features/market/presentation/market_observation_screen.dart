import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../app/route_paths.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/system_ui_styles.dart';
import '../../../core/domain/five_element.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../home/application/today_fortune_provider.dart';
import '../../shared/tab_background.dart';
import '../application/market_providers.dart';
import '../domain/market_observation.dart';

class MarketObservationScreen extends ConsumerStatefulWidget {
  const MarketObservationScreen({super.key});

  @override
  ConsumerState<MarketObservationScreen> createState() =>
      _MarketObservationScreenState();
}

class _MarketObservationScreenState
    extends ConsumerState<MarketObservationScreen> {
  Future<void> _addInstrument(MarketInstrument instrument) async {
    final added = await ref
        .read(marketRepositoryProvider)
        .addWatchItem(
          userId: localUserId,
          instrumentId: instrument.id,
          now: ref.read(appClockProvider).nowKst(),
        );
    ref.invalidate(marketWatchEntriesProvider);
    ref.invalidate(marketObservationEntriesProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? '${instrument.name}을 관심종목에 담았어요.' : '이미 관심종목에 있어요.',
        ),
      ),
    );
  }

  Future<void> _openSearch() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _MarketSearchSheet(onAddInstrument: _addInstrument),
    );
  }

  Future<void> _removeInstrument(MarketInstrument instrument) async {
    await ref
        .read(marketRepositoryProvider)
        .removeWatchItem(
          userId: localUserId,
          instrumentId: instrument.id,
          now: ref.read(appClockProvider).nowKst(),
        );
    ref.invalidate(marketWatchEntriesProvider);
    ref.invalidate(marketObservationEntriesProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${instrument.name}을 관심종목에서 뺐어요.'),
        action: SnackBarAction(
          label: '되돌리기',
          onPressed: () async {
            await ref
                .read(marketRepositoryProvider)
                .addWatchItem(
                  userId: localUserId,
                  instrumentId: instrument.id,
                  now: ref.read(appClockProvider).nowKst(),
                );
            ref.invalidate(marketWatchEntriesProvider);
            ref.invalidate(marketObservationEntriesProvider);
          },
        ),
      ),
    );
  }

  Future<void> _editWatchEntry(MarketObservationEntry entry) async {
    final draft = await showModalBottomSheet<_MarketWatchEditDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MarketWatchEditorSheet(
        instrumentName: entry.watch.instrument.name,
        initialMemo: entry.watch.item.memo ?? '',
        initialTagCodes: _decodeTags(entry.watch.item.userTagsJson),
      ),
    );
    if (draft == null) return;
    try {
      await ref
          .read(marketRepositoryProvider)
          .updateWatchItemDetails(
            userId: localUserId,
            instrumentId: entry.watch.instrument.id,
            memo: draft.memo,
            userTags: draft.tagCodes,
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관찰 메모를 저장하지 못했어요. 다시 시도해 주세요.')),
      );
      return;
    }
    ref.invalidate(marketWatchEntriesProvider);
    ref.invalidate(marketObservationEntriesProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('관찰 메모를 저장했어요.')));
  }

  @override
  Widget build(BuildContext context) {
    final fortuneAsync = ref.watch(todayFortuneProvider);

    return TabBackground(
      imagePath: AssetPaths.marketTabBackground,
      scrim: TabBackgroundScrim.strong,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('시장관찰'),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: AppSystemUiStyles.lightStatusBar,
          actions: [
            if (fortuneAsync.valueOrNull != null)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: '종목 검색',
                onPressed: _openSearch,
              ),
          ],
        ),
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '출생 정보를 입력하면 오늘의 관찰 리듬을 볼 수 있어요.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '오락과 자기점검용 참고 정보예요.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.go(RoutePaths.onboarding),
                        child: const Text('출생 정보 입력하기'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _MarketBody(
              onRemoveInstrument: _removeInstrument,
              onEditEntry: _editWatchEntry,
            );
          },
        ),
      ),
    );
  }
}

class _MarketWatchEditDraft {
  const _MarketWatchEditDraft({required this.memo, required this.tagCodes});

  final String memo;
  final List<String> tagCodes;
}

class _MarketWatchEditorSheet extends StatefulWidget {
  const _MarketWatchEditorSheet({
    required this.instrumentName,
    required this.initialMemo,
    required this.initialTagCodes,
  });

  final String instrumentName;
  final String initialMemo;
  final List<String> initialTagCodes;

  @override
  State<_MarketWatchEditorSheet> createState() =>
      _MarketWatchEditorSheetState();
}

class _MarketWatchEditorSheetState extends State<_MarketWatchEditorSheet> {
  late final TextEditingController _memoController;
  late Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.initialMemo);
    _selectedTags = widget.initialTagCodes.toSet();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      _MarketWatchEditDraft(
        memo: _memoController.text,
        tagCodes: _selectedTags.toList()..sort(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.instrumentName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('market-watch-memo-field'),
                controller: _memoController,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: '관찰 메모',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text('관심 키워드', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final keyword in MarketWatchKeyword.values)
                    FilterChip(
                      key: ValueKey('market-watch-keyword-${keyword.code}'),
                      label: Text(keyword.label),
                      selected: _selectedTags.contains(keyword.code),
                      onSelected: (selected) {
                        setState(() {
                          _selectedTags = {..._selectedTags};
                          if (selected) {
                            _selectedTags.add(keyword.code);
                          } else {
                            _selectedTags.remove(keyword.code);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  const Spacer(),
                  FilledButton(
                    key: const Key('market-watch-save'),
                    onPressed: _save,
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketBody extends ConsumerWidget {
  const _MarketBody({
    required this.onRemoveInstrument,
    required this.onEditEntry,
  });

  final ValueChanged<MarketInstrument> onRemoveInstrument;
  final ValueChanged<MarketObservationEntry> onEditEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observationsAsync = ref.watch(marketObservationEntriesProvider);
    final fortune = ref.watch(todayFortuneProvider).valueOrNull!;
    final mode = calculateMarketRiskMode(
      balance: fortune.balance,
      match: fortune.match,
      analysis: fortune.analysis,
    );
    final keywords = observationKeywords(mode, fortune.match.todayElement);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModeCard(mode: mode, keywords: keywords),
          const SizedBox(height: 12),
          observationsAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => OutlinedButton(
              onPressed: () => ref.invalidate(marketObservationEntriesProvider),
              child: const Text('다시 시도'),
            ),
            data: (entries) => entries.isEmpty
                ? const _EmptyWatchList()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 관심종목',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final entry in entries)
                        _ObservationTile(
                          key: ValueKey(
                            'market-observation-${entry.watch.instrument.id}',
                          ),
                          entry: entry,
                          onRemove: () =>
                              onRemoveInstrument(entry.watch.instrument),
                          onEdit: () => onEditEntry(entry),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            '오락과 자기점검용 참고 정보예요.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.keywords});

  final MarketRiskMode mode;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘은 ${mode.label}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              marketRiskModeGuide(mode),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '보조 키워드 · ${keywords.join(' · ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketSearchSheet extends ConsumerStatefulWidget {
  const _MarketSearchSheet({required this.onAddInstrument});

  final Future<void> Function(MarketInstrument instrument) onAddInstrument;

  @override
  ConsumerState<_MarketSearchSheet> createState() => _MarketSearchSheetState();
}

class _MarketSearchSheetState extends ConsumerState<_MarketSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
  }

  void _clearQuery() {
    _controller.clear();
    setState(() => _query = '');
  }

  Future<void> _addInstrument(MarketInstrument instrument) async {
    await widget.onAddInstrument(instrument);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final availableHeight =
        mediaQuery.size.height - keyboardInset - mediaQuery.padding.top;
    final sheetHeight = availableHeight * (keyboardInset > 0 ? 0.54 : 0.64);
    final trimmed = _query.trim();
    final resultsAsync = trimmed.isEmpty
        ? const AsyncValue<List<MarketInstrument>>.data([])
        : ref.watch(marketSearchProvider(trimmed));
    final observationsAsync = ref.watch(marketObservationEntriesProvider);
    final masterAsync = ref.watch(marketMasterImportProvider);
    final selectedInstrumentIds = <String>{
      for (final entry in observationsAsync.valueOrNull ?? const [])
        entry.watch.instrument.id,
    };

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: keyboardInset + mediaQuery.padding.bottom + 12,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 640,
              maxHeight: sheetHeight
                  .clamp(420, mediaQuery.size.height * 0.72)
                  .toDouble(),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '종목 검색',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: '검색 닫기',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('market-search-field'),
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: '종목 검색',
                      helperText: '공식 로컬 종목 데이터에서 선택해요.',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: trimmed.isEmpty
                          ? null
                          : IconButton(
                              tooltip: '검색어 지우기',
                              onPressed: _clearQuery,
                              icon: const Icon(Icons.close),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: trimmed.isEmpty
                        ? ListView(
                            children: [
                              Text(
                                '한 글자부터 종목명이나 코드를 찾아볼 수 있어요.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final example in const [
                                    '삼',
                                    '005930',
                                    'NAVER',
                                  ])
                                    ActionChip(
                                      key: ValueKey(
                                        'market-example-chip-$example',
                                      ),
                                      label: Text(example),
                                      onPressed: () => _setQuery(example),
                                    ),
                                ],
                              ),
                            ],
                          )
                        : resultsAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (_, _) => const Text('검색 결과를 불러오지 못했어요.'),
                            data: (results) {
                              if (results.isEmpty) {
                                return const Text('검색 결과에서 선택해 주세요.');
                              }
                              return ListView(
                                children: [
                                  for (final instrument in results.take(20))
                                    _SearchResultTile(
                                      instrument: instrument,
                                      alreadyAdded: selectedInstrumentIds
                                          .contains(instrument.id),
                                      onAdd: () => _addInstrument(instrument),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                  masterAsync.maybeWhen(
                    data: (summary) => Text(
                      '로컬 종목 ${summary.count}개 · 기준일 ${summary.baseDate}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.instrument,
    required this.alreadyAdded,
    required this.onAdd,
  });

  final MarketInstrument instrument;
  final bool alreadyAdded;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(instrument.name),
      subtitle: Text(
        '${instrument.symbol} · ${instrument.market} · ${instrument.corpName}',
      ),
      trailing: alreadyAdded
          ? const Chip(label: Text('추가됨'))
          : IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: '관심종목 추가',
              onPressed: onAdd,
            ),
      onTap: alreadyAdded ? null : onAdd,
    );
  }
}

class _EmptyWatchList extends StatelessWidget {
  const _EmptyWatchList();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '아직 관심종목이 없어요.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '오른쪽 위 돋보기에서 종목을 추가하면 관찰 준비도를 볼 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '예시: 삼, 005930, NAVER',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistSection extends ConsumerWidget {
  const _ChecklistSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checked = ref.watch(marketChecklistProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관찰 전 점검 ${checked.length}/${MarketChecklistItem.values.length}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        for (final item in MarketChecklistItem.values)
          CheckboxListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            value: checked.contains(item),
            onChanged: (value) {
              ref
                  .read(marketChecklistProvider.notifier)
                  .toggle(item, value ?? false);
            },
            title: Text(item.label),
            controlAffinity: ListTileControlAffinity.leading,
          ),
      ],
    );
  }
}

class _ObservationTile extends StatelessWidget {
  const _ObservationTile({
    super.key,
    required this.entry,
    required this.onRemove,
    required this.onEdit,
  });

  final MarketObservationEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  Future<void> _confirmRemove(
    BuildContext context,
    MarketInstrument instrument,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제할까요?'),
        content: Text('관심종목에서 ${instrument.name} 삭제를 진행할까요?'),
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
    if (confirmed == true) {
      onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final instrument = entry.watch.instrument;
    final score = entry.score;
    final tags = _decodeTags(entry.watch.item.userTagsJson)
        .map((code) => MarketWatchKeyword.byCode(code)?.label ?? code)
        .toList(growable: false);
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>(
            'market-observation-expanded-${instrument.id}',
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          title: Text(instrument.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${instrument.symbol} · ${instrument.market}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(value: score.score / 100),
                  ),
                  const SizedBox(width: 12),
                  Text('${score.score}'),
                ],
              ),
              const SizedBox(height: 4),
              Text('관찰 준비도', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const _ChecklistSection(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final reason in score.reasonCodes)
                    Chip(label: Text(marketReasonLabel(reason))),
                ],
              ),
            ),
            if (score.nameElement != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('이름 오행: ${score.nameElement!.korean}'),
              ),
            ],
            if ((entry.watch.item.memo ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('메모: ${entry.watch.item.memo}'),
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in tags) InputChip(label: Text(tag)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('메모/키워드'),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '삭제',
                  onPressed: () => _confirmRemove(context, instrument),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _decodeTags(String jsonText) {
  try {
    final raw = jsonDecode(jsonText);
    if (raw is List) return raw.map((item) => item.toString()).toList();
  } catch (_) {
    // 손상된 로컬 메타는 화면을 깨뜨리지 않고 빈 키워드로 처리한다.
  }
  return const [];
}
