import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/data/repositories/profile_repository.dart';
import 'package:ohaeng_guardians/engine/gateway/models.dart';

/// v1 → v4 마이그레이션 검증 (2차 QA 관점: 기존 사용자 데이터 보존).
///
/// v1 파일 재현: 최신 스키마로 생성한 뒤 추가 테이블만 drop하고
/// user_version을 1로 되돌린다 — v1 당시 테이블 구성과 동일해진다.
void main() {
  test('v1 → v4 마이그레이션: 기존 데이터 보존 + 추가 테이블 생성', () async {
    final dir = await Directory.systemTemp.createTemp('ohaeng_migration');
    final file = File('${dir.path}/app.db');
    addTearDown(() => dir.delete(recursive: true));

    // 1) v1 상태의 DB 파일 만들기 + 사용자 데이터 시드
    final setup = AppDatabase(NativeDatabase(file));
    await ProfileRepository(setup).saveProfile(
      nickname: '기존유저',
      birthDate: DateTime(1990, 3, 15),
      birthHour: 14,
      birthMinute: 30,
      calendarType: CalendarType.solar,
      isLeapMonth: false,
      genderMode: GenderMode.male,
      now: DateTime(2026, 7, 1),
    );
    await setup
        .into(setup.ownedCards)
        .insert(
          OwnedCardsCompanion.insert(
            userId: 'user_local',
            cardId: 'card_guardian_wood_yang',
            unlockedAt: DateTime(2026, 7, 1),
            count: const Value(2),
            firstSource: 'first_visit',
          ),
        );
    await setup.customStatement('DROP TABLE chemistry_results');
    await setup.customStatement('DROP TABLE chemistry_profiles');
    await setup.customStatement('DROP TABLE notification_settings');
    await setup.customStatement('DROP TABLE market_watch_items');
    await setup.customStatement('DROP TABLE market_instruments');
    await setup.customStatement('PRAGMA user_version = 1');
    await setup.close();

    // 2) 같은 파일을 최신 스키마로 열기 → onUpgrade(1→3) 실행
    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);

    // 기존 데이터 보존
    final profile = await ProfileRepository(migrated).getActiveBirthProfile();
    expect(profile, isNotNull);
    expect(profile!.displayName, '기존유저');
    final card = await (migrated.select(
      migrated.ownedCards,
    )..where((t) => t.cardId.equals('card_guardian_wood_yang'))).getSingle();
    expect(card.count, 2);

    // 케미 테이블 생성·동작
    await migrated
        .into(migrated.chemistryProfiles)
        .insert(
          ChemistryProfilesCompanion.insert(
            id: 'chem_test',
            ownerUserId: 'user_local',
            label: '친구',
            relationType: 'friend',
            birthDate: DateTime(1992, 7, 21),
            birthHour: const Value(9),
            birthMinute: const Value(0),
            calendarType: CalendarType.solar.name,
            createdAt: DateTime(2026, 7, 8),
          ),
        );
    expect(
      await migrated.select(migrated.chemistryProfiles).get(),
      hasLength(1),
    );

    // 알림 설정 테이블 생성·동작 (v3)
    await migrated
        .into(migrated.notificationSettings)
        .insert(
          NotificationSettingsCompanion.insert(
            type: 'morning_guardian',
            enabled: const Value(true),
            hour: 8,
          ),
        );
    expect(
      await migrated.select(migrated.notificationSettings).get(),
      hasLength(1),
    );

    // 시장관찰 테이블 생성·동작 (v4)
    await migrated
        .into(migrated.marketInstruments)
        .insert(
          MarketInstrumentsCompanion.insert(
            id: 'KRX:KOSPI:005930',
            symbol: '005930',
            market: 'KOSPI',
            name: '삼성전자',
            normalizedName: '삼성전자',
            corpName: '삼성전자',
            baseDate: '2026-07-08',
            source: 'test',
            updatedAt: DateTime(2026, 7, 8),
          ),
        );
    await migrated
        .into(migrated.marketWatchItems)
        .insert(
          MarketWatchItemsCompanion.insert(
            id: 'marketwatch_user_local_KRX_KOSPI_005930',
            userId: 'user_local',
            instrumentId: 'KRX:KOSPI:005930',
            createdAt: DateTime(2026, 7, 8),
          ),
        );
    expect(
      await migrated.select(migrated.marketWatchItems).get(),
      hasLength(1),
    );
  });
}
