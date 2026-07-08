import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/market_repository.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';

void main() {
  late AppDatabase db;
  late MarketRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = MarketRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  String fixtureJson() => jsonEncode({
    'schemaVersion': 1,
    'source': {
      'name': 'test',
      'url': 'fixture',
      'baseDate': '2026-07-08',
      'generatedAt': '2026-07-08',
    },
    'instruments': [
      {
        'id': 'KRX:KOSPI:005930',
        'symbol': '005930',
        'market': 'KOSPI',
        'name': '삼성전자',
        'normalizedName': '삼성전자',
        'corpName': '삼성전자',
        'isin': 'KR7005930003',
        'baseDate': '2026-07-08',
        'source': 'test',
        'updatedAt': '2026-07-08',
      },
      {
        'id': 'KRX:KOSPI:006400',
        'symbol': '006400',
        'market': 'KOSPI',
        'name': '삼성SDI',
        'normalizedName': '삼성SDI',
        'corpName': '삼성SDI',
        'isin': 'KR7006400006',
        'baseDate': '2026-07-08',
        'source': 'test',
        'updatedAt': '2026-07-08',
      },
      {
        'id': 'KRX:KOSPI:035420',
        'symbol': '035420',
        'market': 'KOSPI',
        'name': 'NAVER',
        'normalizedName': 'NAVER',
        'corpName': '네이버',
        'isin': 'KR7035420009',
        'baseDate': '2026-07-08',
        'source': 'test',
        'updatedAt': '2026-07-08',
      },
    ],
  });

  test(
    'imports the master idempotently and searches by name/code/corp name',
    () async {
      final first = await repository.importFromAssetJson(fixtureJson());
      final second = await repository.importFromAssetJson(fixtureJson());

      expect(first.count, 3);
      expect(second.count, 3);
      expect(await db.select(db.marketInstruments).get(), hasLength(3));

      expect(
        (await repository.search('삼')).map((e) => e.name),
        contains('삼성전자'),
      );
      expect((await repository.search('005930')).single.name, '삼성전자');
      expect((await repository.search('네이버')).single.symbol, '035420');
    },
  );

  test(
    'adds, prevents duplicates, archives, and restores watch items',
    () async {
      await repository.importFromAssetJson(fixtureJson());
      final now = DateTime(2026, 7, 8);

      expect(
        await repository.addWatchItem(
          userId: localUserId,
          instrumentId: 'KRX:KOSPI:005930',
          now: now,
        ),
        isTrue,
      );
      expect(
        await repository.addWatchItem(
          userId: localUserId,
          instrumentId: 'KRX:KOSPI:005930',
          now: now,
        ),
        isFalse,
      );
      expect(await repository.watchItems(localUserId), hasLength(1));

      await repository.removeWatchItem(
        userId: localUserId,
        instrumentId: 'KRX:KOSPI:005930',
        now: now,
      );
      expect(await repository.watchItems(localUserId), isEmpty);

      expect(
        await repository.addWatchItem(
          userId: localUserId,
          instrumentId: 'KRX:KOSPI:005930',
          now: now,
        ),
        isTrue,
      );
      expect(await repository.watchItems(localUserId), hasLength(1));
    },
  );

  test('persists checklist by user and KST date', () async {
    final today = DateTime(2026, 7, 8);
    final tomorrow = DateTime(2026, 7, 9);

    await repository.saveChecklist(
      userId: localUserId,
      date: today,
      completed: {'news', 'calm'},
    );

    expect(await repository.loadChecklist(userId: localUserId, date: today), {
      'news',
      'calm',
    });
    expect(
      await repository.loadChecklist(userId: localUserId, date: tomorrow),
      isEmpty,
    );
  });

  test(
    'updates watch item memo and keywords without changing the instrument',
    () async {
      await repository.importFromAssetJson(fixtureJson());
      final now = DateTime(2026, 7, 8);
      await repository.addWatchItem(
        userId: localUserId,
        instrumentId: 'KRX:KOSPI:005930',
        now: now,
      );

      await repository.updateWatchItemDetails(
        userId: localUserId,
        instrumentId: 'KRX:KOSPI:005930',
        memo: '관찰 메모',
        userTags: ['information', 'focus'],
      );

      final entry = (await repository.watchItems(localUserId)).single;
      expect(entry.instrument.symbol, '005930');
      expect(entry.item.memo, '관찰 메모');
      expect(entry.item.userTagsJson, contains('information'));
      expect(entry.item.userTagsJson, contains('focus'));
    },
  );
}
