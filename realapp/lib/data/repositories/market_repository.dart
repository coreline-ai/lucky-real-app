import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/app_database.dart';

class MarketWatchEntry {
  const MarketWatchEntry({required this.item, required this.instrument});

  final MarketWatchItem item;
  final MarketInstrument instrument;
}

class MarketImportSummary {
  const MarketImportSummary({
    required this.sourceName,
    required this.baseDate,
    required this.count,
  });

  final String sourceName;
  final String baseDate;
  final int count;
}

class MarketRepository {
  MarketRepository(this._db);

  final AppDatabase _db;

  static const String _assetVersionKey = 'market_instruments_asset_version';
  static const String _checklistPrefix = 'market_checklist';

  static String normalizeQuery(String query) =>
      query.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  static String watchItemId(String userId, String instrumentId) =>
      'marketwatch_${userId}_${instrumentId.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}';

  static String checklistKey(String userId, DateTime date) =>
      '$_checklistPrefix:$userId:${_dateKey(date)}';

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}$month$day';
  }

  Future<MarketImportSummary> importFromAssetJson(String jsonText) async {
    final payload = jsonDecode(jsonText) as Map<String, dynamic>;
    final source = (payload['source'] as Map<String, dynamic>?) ?? const {};
    final sourceName = (source['name'] as String?) ?? 'UNKNOWN';
    final baseDate = (source['baseDate'] as String?) ?? '';
    final rows = (payload['instruments'] as List).cast<Map<String, dynamic>>();
    final version = '$sourceName:$baseDate:${rows.length}';

    final current = await (_db.select(
      _db.appMeta,
    )..where((t) => t.key.equals(_assetVersionKey))).getSingleOrNull();
    final existingCount = await _db.select(_db.marketInstruments).get();
    if (current?.value == version && existingCount.length == rows.length) {
      return MarketImportSummary(
        sourceName: sourceName,
        baseDate: baseDate,
        count: rows.length,
      );
    }

    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.marketInstruments, [
          for (final row in rows)
            MarketInstrumentsCompanion.insert(
              id: row['id'] as String,
              symbol: row['symbol'] as String,
              market: row['market'] as String,
              name: row['name'] as String,
              normalizedName: row['normalizedName'] as String,
              corpName: row['corpName'] as String,
              isin: Value(row['isin'] as String?),
              baseDate: row['baseDate'] as String,
              source: row['source'] as String,
              updatedAt: DateTime.parse(row['updatedAt'] as String),
            ),
        ]);
      });
      await _db
          .into(_db.appMeta)
          .insertOnConflictUpdate(
            AppMetaCompanion.insert(key: _assetVersionKey, value: version),
          );
    });

    return MarketImportSummary(
      sourceName: sourceName,
      baseDate: baseDate,
      count: rows.length,
    );
  }

  Future<List<MarketInstrument>> search(String query, {int limit = 20}) async {
    final normalized = normalizeQuery(query);
    if (normalized.isEmpty) return Future.value(const []);
    final raw = query.trim();
    final selector = _db.select(_db.marketInstruments)
      ..where(
        (t) =>
            t.symbol.like('$normalized%') |
            t.normalizedName.contains(normalized) |
            t.corpName.contains(raw),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.market),
        (t) => OrderingTerm.asc(t.symbol),
      ]);
    final rows = await selector.get();
    rows.sort((a, b) {
      final rank = _searchRank(
        normalized,
        raw,
        a,
      ).compareTo(_searchRank(normalized, raw, b));
      if (rank != 0) return rank;
      final name = a.name.compareTo(b.name);
      if (name != 0) return name;
      return a.symbol.compareTo(b.symbol);
    });
    return rows.take(limit).toList(growable: false);
  }

  int _searchRank(String normalized, String raw, MarketInstrument item) {
    final name = item.normalizedName;
    final corpName = normalizeQuery(item.corpName);
    if (item.symbol == normalized) return 0;
    if (item.symbol.startsWith(normalized)) return 1;
    if (normalized == '삼' && name.startsWith('삼성')) return 2;
    if (name == normalized || corpName == normalized) return 3;
    if (name.startsWith(normalized) || corpName.startsWith(normalized)) {
      return 4;
    }
    if (name.contains(normalized) || corpName.contains(normalized)) return 5;
    if (item.corpName.contains(raw)) return 6;
    return 7;
  }

  Future<MarketInstrument?> instrumentById(String id) {
    return (_db.select(
      _db.marketInstruments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> addWatchItem({
    required String userId,
    required String instrumentId,
    required DateTime now,
    String? memo,
    List<String>? userTags,
  }) async {
    final instrument = await instrumentById(instrumentId);
    if (instrument == null) {
      throw StateError('Unknown market instrument: $instrumentId');
    }
    final id = watchItemId(userId, instrumentId);
    final existing = await (_db.select(
      _db.marketWatchItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing != null && existing.archivedAt == null) return false;

    await _db
        .into(_db.marketWatchItems)
        .insertOnConflictUpdate(
          MarketWatchItemsCompanion.insert(
            id: id,
            userId: userId,
            instrumentId: instrumentId,
            memo: Value(memo ?? existing?.memo),
            userTagsJson: Value(
              userTags == null
                  ? existing?.userTagsJson ?? '[]'
                  : jsonEncode(userTags),
            ),
            createdAt: existing?.createdAt ?? now,
            archivedAt: const Value(null),
          ),
        );
    return true;
  }

  Future<void> removeWatchItem({
    required String userId,
    required String instrumentId,
    required DateTime now,
  }) async {
    final id = watchItemId(userId, instrumentId);
    await (_db.update(_db.marketWatchItems)..where((t) => t.id.equals(id)))
        .write(MarketWatchItemsCompanion(archivedAt: Value(now)));
  }

  Future<void> updateWatchItemDetails({
    required String userId,
    required String instrumentId,
    required String? memo,
    required List<String> userTags,
  }) async {
    final id = watchItemId(userId, instrumentId);
    await (_db.update(
      _db.marketWatchItems,
    )..where((t) => t.id.equals(id))).write(
      MarketWatchItemsCompanion(
        memo: Value(memo == null || memo.trim().isEmpty ? null : memo),
        userTagsJson: Value(jsonEncode(userTags)),
      ),
    );
  }

  Future<List<MarketWatchEntry>> watchItems(String userId) async {
    final items =
        await (_db.select(_db.marketWatchItems)
              ..where((t) => t.userId.equals(userId) & t.archivedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final entries = <MarketWatchEntry>[];
    for (final item in items) {
      final instrument = await instrumentById(item.instrumentId);
      if (instrument != null) {
        entries.add(MarketWatchEntry(item: item, instrument: instrument));
      }
    }
    return entries;
  }

  Future<Set<String>> loadChecklist({
    required String userId,
    required DateTime date,
  }) async {
    final row =
        await (_db.select(_db.appMeta)
              ..where((t) => t.key.equals(checklistKey(userId, date))))
            .getSingleOrNull();
    if (row == null) return const {};
    final raw = jsonDecode(row.value);
    if (raw is! List) return const {};
    return raw.map((item) => item.toString()).toSet();
  }

  Future<void> saveChecklist({
    required String userId,
    required DateTime date,
    required Set<String> completed,
  }) async {
    final sorted = completed.toList()..sort();
    await _db
        .into(_db.appMeta)
        .insertOnConflictUpdate(
          AppMetaCompanion.insert(
            key: checklistKey(userId, date),
            value: jsonEncode(sorted),
          ),
        );
  }
}
