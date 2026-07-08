import '../../../core/domain/five_element.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/card_repository.dart';
import '../../../engine/gateway/models.dart';

/// 무료 보상 지급 (04 보상 규칙).
/// - deterministic seed = birthProfileId + yyyyMMdd + todayPillar + engineVersion
/// - 날짜당 1회: app_meta에 지급 이력 키를 남기고, 이력이 우선한다.
///   기기 시간을 되돌려 같은 날짜로 재진입해도 키가 남아 있어 중복 지급되지 않는다.
class RewardClaim {
  const RewardClaim({required this.cardId, required this.newlyUnlocked});

  final String cardId;

  /// false면 중복 획득 (count만 증가).
  final bool newlyUnlocked;
}

class RewardService {
  RewardService(this._db, this._cards);

  final AppDatabase _db;
  final CardRepository _cards;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  /// FNV-1a 32bit — 플랫폼 무관 결정적 해시.
  static int seedHash(String input) {
    var hash = 0x811c9dc5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// 오늘의 일일 확인 보상 카드 ID (결정적).
  static String dailyCardId({
    required String birthProfileId,
    required DateTime date,
    required String todayPillarGanji,
    required String engineVersion,
  }) {
    final seed = seedHash(
      '$birthProfileId|${_dateKey(date)}|$todayPillarGanji|$engineVersion',
    );
    final element = FiveElement.values[seed % FiveElement.values.length];
    return 'card_element_${element.name}';
  }

  Future<bool> _alreadyClaimed(String key) async {
    final row = await (_db.select(
      _db.appMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row != null;
  }

  Future<void> _markClaimed(String key) async {
    await _db
        .into(_db.appMeta)
        .insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: '1'));
  }

  /// 일일 확인 보상. 이미 받았으면 null.
  Future<RewardClaim?> claimDailyCheckIn({
    required BirthProfile profile,
    required DailyAnalysisResult analysis,
    required DateTime today,
  }) async {
    final key = 'reward_daily_${profile.userId}_${_dateKey(today)}';
    if (await _alreadyClaimed(key)) return null;

    final cardId = dailyCardId(
      birthProfileId: profile.id,
      date: today,
      todayPillarGanji: analysis.daily.dayPillar.ganji,
      engineVersion: analysis.meta.engineVersion,
    );
    final newlyUnlocked = await _cards.unlock(
      userId: profile.userId,
      cardId: cardId,
      source: 'daily_guardian',
      now: today,
    );
    await _markClaimed(key);
    return RewardClaim(cardId: cardId, newlyUnlocked: newlyUnlocked);
  }

  /// 스트릭 마일스톤 해금 (2차): 3일→목 yin, 7일→화 yin.
  /// 평생 1회 키라서 스트릭이 끊겼다 다시 도달해도, 시간을 되돌려도 중복 지급되지 않는다.
  Future<List<RewardClaim>> claimStreakMilestones({
    required String userId,
    required int currentStreak,
    required DateTime now,
  }) async {
    const milestones = [
      (days: 3, cardId: 'card_guardian_wood_yin'),
      (days: 7, cardId: 'card_guardian_fire_yin'),
    ];
    final claims = <RewardClaim>[];
    for (final milestone in milestones) {
      if (currentStreak < milestone.days) continue;
      final key = 'reward_streak${milestone.days}_$userId';
      if (await _alreadyClaimed(key)) continue;
      final newlyUnlocked = await _cards.unlock(
        userId: userId,
        cardId: milestone.cardId,
        source: 'streak',
        now: now,
      );
      await _markClaimed(key);
      claims.add(
        RewardClaim(cardId: milestone.cardId, newlyUnlocked: newlyUnlocked),
      );
    }
    return claims;
  }

  /// 케미 공유 마일스톤 해금 (2차): 1/2/3회 → 토/금/수 yin. 평생 1회 키.
  Future<List<RewardClaim>> claimChemistryShareMilestones({
    required String userId,
    required int shareCount,
    required DateTime now,
  }) async {
    const milestones = [
      (count: 1, cardId: 'card_guardian_earth_yin'),
      (count: 2, cardId: 'card_guardian_metal_yin'),
      (count: 3, cardId: 'card_guardian_water_yin'),
    ];
    final claims = <RewardClaim>[];
    for (final milestone in milestones) {
      if (shareCount < milestone.count) continue;
      final key = 'reward_chemshare${milestone.count}_$userId';
      if (await _alreadyClaimed(key)) continue;
      final newlyUnlocked = await _cards.unlock(
        userId: userId,
        cardId: milestone.cardId,
        source: 'chemistry',
        now: now,
      );
      await _markClaimed(key);
      claims.add(
        RewardClaim(cardId: milestone.cardId, newlyUnlocked: newlyUnlocked),
      );
    }
    return claims;
  }

  /// 루틴 완료 보상 (하루 1회): 오늘 수호신 카드.
  Future<RewardClaim?> claimRoutineCompletion({
    required BirthProfile profile,
    required String guardianId,
    required DateTime today,
  }) async {
    final key = 'reward_routine_${profile.userId}_${_dateKey(today)}';
    if (await _alreadyClaimed(key)) return null;

    final cardId = 'card_$guardianId';
    final newlyUnlocked = await _cards.unlock(
      userId: profile.userId,
      cardId: cardId,
      source: 'routine',
      now: today,
    );
    await _markClaimed(key);
    return RewardClaim(cardId: cardId, newlyUnlocked: newlyUnlocked);
  }
}
