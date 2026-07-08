import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Local schema. Table set follows the 03↔04 domain-to-table mapping.
/// ID rules (03 핵심 식별자 설계): master data = semantic ids,
/// one-per-day user data = deterministic `{kind}_{userId}_{yyyyMMdd}`,
/// everything else = UUID.

class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get nickname => text().withLength(min: 1, max: 20)();
  TextColumn get birthProfileId => text()();
  TextColumn get fortuneTone => text().withDefault(const Constant('soft'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Seoul'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BirthProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get birthDate => dateTime()();
  IntColumn get birthHour => integer().nullable()();
  IntColumn get birthMinute => integer().nullable()();
  BoolColumn get birthTimeKnown => boolean()();
  TextColumn get calendarType => text()(); // solar | lunar
  BoolColumn get isLeapMonth => boolean().withDefault(const Constant(false))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Seoul'))();
  TextColumn get genderMode => text().nullable()(); // male | female | null
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached daily calculation results (FourPillars + DailyCycle +
/// DailyUserReading + GuardianMatch), keyed per user per day.
class DailySnapshots extends Table {
  TextColumn get id => text()(); // reading_{userId}_{yyyyMMdd}
  TextColumn get userId => text()();
  TextColumn get birthProfileId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get payloadJson => text()();
  TextColumn get guardianId => text().nullable()();
  TextColumn get engineVersion => text()();
  TextColumn get ruleVersion => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 감정/메모 기록 (03 DailyRecord). One representative record per day.
class DailyRecords extends Table {
  TextColumn get id => text()(); // record_{userId}_{yyyyMMdd}
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mood => text().nullable()();
  IntColumn get energyLevel => integer().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get guardianId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Master card catalog cache (semantic ids, bundled with app versions).
class GuardianCards extends Table {
  TextColumn get id => text()(); // e.g. card_fire_first_spark
  TextColumn get name => text()();
  TextColumn get element => text()();
  TextColumn get rarity => text()(); // common | rare | special
  TextColumn get assetId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class OwnedCards extends Table {
  TextColumn get userId => text()();
  TextColumn get cardId => text()();
  DateTimeColumn get unlockedAt => dateTime()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  TextColumn get firstSource => text()();

  @override
  Set<Column> get primaryKey => {userId, cardId};
}

class RoutineLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get routineTemplateId => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RoutineStreaks extends Table {
  TextColumn get userId => text()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 알림 종류별 설정 (03 UserSettings.notificationTypes). v3에서 추가.
class NotificationSettings extends Table {
  TextColumn get type =>
      text()(); // morning_guardian|evening_routine|card_unclaimed
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  IntColumn get hour => integer()();
  IntColumn get minute => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {type};
}

/// KRX/KIND 또는 공공데이터포털 기반 로컬 종목 마스터. v4에서 추가.
class MarketInstruments extends Table {
  TextColumn get id => text()(); // KRX:{market}:{symbol}
  TextColumn get symbol => text()();
  TextColumn get market => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get corpName => text()();
  TextColumn get isin => text().nullable()();
  TextColumn get baseDate => text()();
  TextColumn get source => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 사용자가 공식 마스터에서 선택한 관심종목. v4에서 추가.
class MarketWatchItems extends Table {
  TextColumn get id => text()(); // marketwatch_{userId}_{instrumentId}
  TextColumn get userId => text()();
  TextColumn get instrumentId => text()();
  TextColumn get memo => text().nullable()();
  TextColumn get userTagsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 케미 상대 프로필 (03 ChemistryProfile). v2에서 추가.
class ChemistryProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUserId => text()();
  TextColumn get label => text()();
  TextColumn get relationType => text()(); // friend|love|family|work|custom
  DateTimeColumn get birthDate => dateTime()();
  IntColumn get birthHour => integer().nullable()();
  IntColumn get birthMinute => integer().nullable()();
  TextColumn get calendarType => text()(); // solar | lunar
  BoolColumn get isLeapMonth => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 케미 계산 결과 캐시 (03 ChemistryResult). v2에서 추가.
class ChemistryResults extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUserId => text()();
  TextColumn get partnerProfileId => text()();
  TextColumn get payloadJson => text()(); // ChemistryAnalysis JSON
  TextColumn get engineVersion => text()();
  DateTimeColumn get calculatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    UserProfiles,
    BirthProfiles,
    DailySnapshots,
    DailyRecords,
    GuardianCards,
    OwnedCards,
    RoutineLogs,
    RoutineStreaks,
    AppMeta,
    ChemistryProfiles,
    ChemistryResults,
    NotificationSettings,
    MarketInstruments,
    MarketWatchItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // 2차 개발 마이그레이션. 기존 데이터는 무변경.
      if (from < 2) {
        await m.createTable(chemistryProfiles);
        await m.createTable(chemistryResults);
      }
      if (from < 3) {
        await m.createTable(notificationSettings);
      }
      if (from < 4) {
        await m.createTable(marketInstruments);
        await m.createTable(marketWatchItems);
      }
    },
  );
}
