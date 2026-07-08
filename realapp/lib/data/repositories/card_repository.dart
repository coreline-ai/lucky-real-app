import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// 카드 해금 (03 UserCardCollection 규칙: 중복은 count 증가, 유료 재화 없음).
class CardRepository {
  CardRepository(this._db);

  final AppDatabase _db;

  /// 해금 시도. 처음이면 true, 중복이면 count만 올리고 false.
  Future<bool> unlock({
    required String userId,
    required String cardId,
    required String source,
    required DateTime now,
  }) async {
    final existing =
        await (_db.select(_db.ownedCards)
              ..where((t) => t.userId.equals(userId) & t.cardId.equals(cardId)))
            .getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.ownedCards)
          .insert(
            OwnedCardsCompanion.insert(
              userId: userId,
              cardId: cardId,
              unlockedAt: now,
              firstSource: source,
            ),
          );
      return true;
    }

    await (_db.update(_db.ownedCards)
          ..where((t) => t.userId.equals(userId) & t.cardId.equals(cardId)))
        .write(OwnedCardsCompanion(count: Value(existing.count + 1)));
    return false;
  }

  Future<List<OwnedCard>> ownedCards(String userId) {
    return (_db.select(
      _db.ownedCards,
    )..where((t) => t.userId.equals(userId))).get();
  }
}
