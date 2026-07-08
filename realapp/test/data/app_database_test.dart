import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('schema creates the expected tables', () {
    final names = db.allTables.map((t) => t.actualTableName).toSet();
    expect(names, {
      'user_profiles',
      'birth_profiles',
      'daily_snapshots',
      'daily_records',
      'guardian_cards',
      'owned_cards',
      'routine_logs',
      'routine_streaks',
      'app_meta',
      'chemistry_profiles',
      'chemistry_results',
      'notification_settings',
      'market_instruments',
      'market_watch_items',
    });
  });

  test('app_meta round-trips a value', () async {
    await db
        .into(db.appMeta)
        .insert(AppMetaCompanion.insert(key: 'engineVersion', value: '0.1.0'));
    final row = await (db.select(
      db.appMeta,
    )..where((t) => t.key.equals('engineVersion'))).getSingle();
    expect(row.value, '0.1.0');
  });

  test('owned_cards enforces one row per user+card (중복은 count로 처리)', () async {
    final entry = OwnedCardsCompanion.insert(
      userId: 'user_test',
      cardId: 'card_wood_first_sprout',
      unlockedAt: DateTime(2026, 7, 7),
      firstSource: 'daily_guardian',
    );
    await db.into(db.ownedCards).insert(entry);
    expect(
      () => db.into(db.ownedCards).insert(entry),
      throwsA(isA<SqliteException>()),
    );
  });
}
