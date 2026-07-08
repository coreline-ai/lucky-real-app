# Flutter 기술 아키텍처

## 기본 방향

오행가디언즈는 **서버 없는 오프라인 우선 Flutter 앱**으로 설계한다.

핵심 원칙:

- 만세력 계산은 순수 Dart 패키지로 분리한다.
- 오늘의 수호신, 운세, 루틴, 카드/도감, 궁합은 모두 로컬 계산을 우선한다.
- 사용자 생년월일/시간 정보는 기기 내부 저장소에만 보관한다.
- 광고, 인앱결제, RevenueCat, AdMob, Analytics SDK는 제외한다.
- 공유 기능은 서버 링크가 아니라 로컬 생성 이미지 중심으로 구현한다.
- 알림은 푸시 서버 없이 로컬 예약 알림만 사용한다.

## 권장 기술 스택

| 영역 | 권장 패키지 | 용도 |
|---|---|---|
| 상태 관리 | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | 화면 상태, 의존성 주입, 테스트 가능한 Provider 구성 |
| 라우팅 | `go_router` | 탭/상세/공유 진입 라우팅 |
| 불변 모델 | `freezed`, `freezed_annotation` | 운세 결과, 오행 점수, 카드 보상 모델 |
| JSON | `json_serializable`, `json_annotation` | 로컬 캐시/에셋 데이터 직렬화 |
| 코드 생성 | `build_runner` | Riverpod/Freezed/JSON 생성 |
| 로컬 DB | `drift`, `sqlite3_flutter_libs` | 프로필, 일일 결과, 카드 획득, 루틴 이력 저장 |
| 경량 설정 | `shared_preferences` | 최소 설정값(온보딩 완료 여부 등) |
| 파일 경로 | `path_provider` | 공유 이미지 임시 저장, 로컬 백업 파일 위치 |
| 공유 | `share_plus` | 생성된 궁합/카드/오늘 운 이미지 공유 |
| 알림 | `flutter_local_notifications`, `timezone` | 매일 운세/루틴 리마인더 예약 |
| 날짜/포맷 | `intl` | 한국어 날짜, 절기/일주 표시 포맷 |
| 테스트 | `test`, `flutter_test`, `integration_test` | 엔진 단위 테스트, 위젯 테스트, 앱 플로우 테스트 |

정확한 버전은 `pubspec.yaml` 작성 시점에 최신 안정 버전을 고정한다. `riverpod`, `go_router`, `drift`, `flutter_local_notifications`는 업데이트 영향이 있으므로 lockfile 기반으로 관리한다.

## 전체 구조

권장 구조는 **Feature-first + Layered Architecture**다.

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
    bootstrap.dart
  core/
    errors/
    extensions/
    result/
    time/
    utils/
  engine/
    manseryeok/
    five_elements/
    fortune/
    compatibility/
  features/
    onboarding/
    home/
    guardian/
    fortune/
    routine/
    cards/
    compatibility/
    settings/
    share/
    notifications/
  data/
    local/
    repositories/
    assets/
  l10n/
```

의존성 방향:

```text
presentation -> application -> domain -> data interface
data implementation -> domain interface
engine -> pure Dart only
platform services -> plugin wrapper only
```

규칙:

- `engine/`은 Flutter import 금지.
- `features/*/presentation`에서 DB 직접 접근 금지.
- `drift`, `share_plus`, `flutter_local_notifications`는 adapter/service 안에 격리.
- 운세 생성 로직은 Widget 안에 두지 않는다.
- 오늘 날짜 의존성은 `AppClock`으로 주입한다.

## 상세 폴더 구조

```text
lib/
  main.dart

  app/
    app.dart
    bootstrap.dart
    router.dart
    route_paths.dart
    theme.dart
    app_providers.dart

  core/
    result/
      app_result.dart
      app_failure.dart
    time/
      app_clock.dart
      kst_date.dart
    logging/
      app_logger.dart
    constants/
      element_colors.dart
      storage_keys.dart

  engine/
    manseryeok/
      manseryeok_engine.dart
      solar_lunar_converter.dart
      sexagenary_cycle.dart
      solar_terms.dart
      ten_gods.dart
      models/
        birth_input.dart
        four_pillars.dart
        pillar.dart
        heavenly_stem.dart
        earthly_branch.dart
    five_elements/
      five_element.dart
      five_element_score.dart
      element_balance_calculator.dart
      guardian_selector.dart
    fortune/
      daily_fortune_engine.dart
      routine_recommender.dart
      fortune_message_rules.dart
    compatibility/
      compatibility_engine.dart
      chemistry_score.dart
      compatibility_message_rules.dart

  data/
    local/
      app_database.dart
      tables/
        user_profiles.dart
        birth_profiles.dart
        daily_snapshots.dart
        daily_records.dart
        cards.dart
        routine_logs.dart
        routine_streaks.dart
        chemistry_profiles.dart
        chemistry_results.dart
        notification_settings.dart
        app_meta.dart
      daos/
        profile_dao.dart
        daily_snapshot_dao.dart
        daily_record_dao.dart
        card_dao.dart
        routine_log_dao.dart
        chemistry_dao.dart
    assets/
      asset_bundle_reader.dart
      card_catalog_data_source.dart
      fortune_copy_data_source.dart
    repositories/
      profile_repository_impl.dart
      daily_fortune_repository_impl.dart
      card_repository_impl.dart
      routine_repository_impl.dart

  features/
    onboarding/
      domain/
      application/
      presentation/
        onboarding_screen.dart
        birth_profile_form.dart

    home/
      application/
        today_home_controller.dart
      presentation/
        home_screen.dart
        today_guardian_panel.dart
        today_routine_panel.dart
        card_reward_panel.dart

    guardian/
      domain/
        guardian.dart
      application/
        guardian_service.dart
      presentation/
        guardian_detail_screen.dart

    fortune/
      domain/
        daily_fortune.dart
      application/
        daily_fortune_controller.dart
      presentation/
        fortune_screen.dart

    routine/
      domain/
        element_routine.dart
        routine_completion.dart
      application/
        routine_controller.dart
      presentation/
        routine_screen.dart

    cards/
      domain/
        guardian_card.dart
        card_collection.dart
      application/
        card_collection_controller.dart
      presentation/
        card_book_screen.dart
        card_detail_screen.dart

    compatibility/
      domain/
        compatibility_request.dart
        compatibility_result.dart
      application/
        compatibility_controller.dart
      presentation/
        compatibility_input_screen.dart
        compatibility_result_screen.dart

    share/
      application/
        share_image_service.dart
      presentation/
        share_card_canvas.dart
        share_preview_screen.dart

    notifications/
      application/
        notification_scheduler.dart
      infrastructure/
        local_notification_service.dart

    settings/
      application/
      presentation/
        settings_screen.dart
```

## 만세력 엔진 포팅

기존 repo의 TypeScript 엔진을 기준 구현으로 삼는다.

기존 주요 파일 (repo 루트의 `engine/` 패키지):

- `engine/src/engine/core/manseryeok-engine.ts`
- `engine/src/engine/core/solar-terms.ts`
- `engine/src/engine/core/lunar-solar.ts`
- `engine/src/engine/core/korean-legal-time.ts`
- `engine/src/engine/saju/calculator.ts`
- `engine/src/engine/saju/sipsin.ts`
- `engine/src/engine/saju/yongsin.ts`
- `engine/src/engine/compatibility/*`

Dart 엔진은 별도 package로 분리할 수 있다.

```text
packages/
  manseryeok_engine/
    lib/
      manseryeok_engine.dart
      src/
    test/
```

순수 Dart 엔진 입력은 기준 TS 엔진의 `BirthInputData` 계약과 1:1로 맞춘다. `DateTime` 단일 필드는 출생시간 미상과 음력 날짜를 표현할 수 없으므로 사용하지 않는다.

```dart
class BirthInput {
  final int year;
  final int month;
  final int day;
  final int? hour;    // 출생시간 미상이면 null
  final int? minute;  // 출생시간 미상이면 null
  final CalendarType calendarType; // solar, lunar
  final bool isLeapMonth;          // lunar일 때만 의미
  final GenderMode? genderMode;    // 대운 계산 시 필수, 없으면 대운 생략
  final String timezone;           // MVP: Asia/Seoul 고정
}
```

TS 계약 매핑:

- `hour == null` ↔ TS `hour: null` (시주 미산출)
- `genderMode` ↔ TS `gender`(필수). null이면 대운 API를 호출하지 않는다.
- `dayBoundaryRule` `late_zi_hour`/`midnight` ↔ TS `midnightMode` `yaja`/`joja`

출력:

```dart
class FourPillars {
  final Pillar year;
  final Pillar month;
  final Pillar day;
  final Pillar? hour;
}

class FiveElementScore {
  final int wood;
  final int fire;
  final int earth;
  final int metal;
  final int water;
}
```

엔진 책임:

- 양력/음력 변환
- 윤달 처리
- 60갑자 계산
- 년주/월주/일주/시주 산출
- 절기 기준 월주 전환
- 천간/지지 오행 매핑
- 지장간 반영 옵션
- 오행 점수 계산
- 오늘의 일진 계산
- 수호 오행/수호신 후보 선택
- 궁합 점수 계산

MVP 단순화:

- 기본 시간대는 `Asia/Seoul`.
- 위치 기반 진태양시 보정은 v2 옵션으로 분리할 수 있다.
- 출생지가 필요한 정밀 보정은 MVP에서 필수가 아니다.
- 해석 문구는 계산 엔진과 분리한다.
- 엔진 테스트는 Flutter 없이 `dart test`로 실행 가능해야 한다.

## EngineGateway

Flutter UI는 명리 계산을 직접 구현하지 않는다.

EngineGateway는 **계산 결과와 근거 코드만** 반환한다. 사용자에게 보여줄 문구(`summary`, `advice`, `caution` 등)는 콘텐츠 레이어(`fortune_message_rules`, `compatibility_message_rules`)가 근거 코드 기반 템플릿으로 조립한다. 계산과 문구를 분리해야 문구 수정이 엔진 재검증을 유발하지 않는다.

```dart
abstract interface class EngineGateway {
  Future<FourPillars> calculateFourPillars(BirthInput input);
  Future<DailyCycle> calculateDailyCycle(DateTime date, String timezone);
  // 문구 없는 계산 결과: 오행 균형, 십신, 점수, 근거 코드
  Future<DailyAnalysis> calculateDailyAnalysis(BirthInput input, DateTime date);
  // 문구 없는 계산 결과: 조화 점수, 관계 코드
  Future<ChemistryAnalysis> calculateChemistry(BirthInput a, BirthInput b);
}
```

`DailyUserReading`, `ChemistryResult`는 `DailyAnalysis`/`ChemistryAnalysis`에 콘텐츠 레이어가 문구를 채워 만든 앱 도메인 모델이다.

MVP 초기에 가능한 전략:

1. Dart 엔진 포팅 전까지 MockGateway로 UI 개발.
2. TypeScript 엔진 fixture를 JSON으로 생성.
3. Dart 엔진 포팅 후 fixture 기반 결과 비교.
4. UI는 EngineGateway만 의존하므로 엔진 구현 교체 가능.

## 오프라인 저장 전략

저장소:

- `drift`: 구조화된 장기 데이터
- `shared_preferences`: 최소 설정값만
- `path_provider`: 공유 이미지 임시 파일

로컬 DB 테이블:

```text
user_profiles
birth_profiles
daily_snapshots
daily_records
guardian_cards
owned_cards
routine_logs
routine_streaks
chemistry_profiles
chemistry_results
notification_settings
app_meta
```

도메인 모델(03 문서) ↔ 테이블 매핑:

| 도메인 모델 | 테이블 |
|---|---|
| UserProfile, UserSettings | `user_profiles` |
| BirthProfile | `birth_profiles` |
| FourPillars, DailyCycle, DailyUserReading, GuardianMatch | `daily_snapshots` |
| DailyRecord (감정/메모/캘린더) | `daily_records` |
| Card (마스터), UserCardCollection | `guardian_cards`, `owned_cards` |
| DailyRoutineRecommendation, 완료 이력 | `routine_logs` |
| RoutineStreak | `routine_streaks` |
| ChemistryProfile | `chemistry_profiles` |
| ChemistryResult | `chemistry_results` |
| 알림 설정 | `notification_settings` |
| engineVersion/ruleVersion 등 | `app_meta` |

캐싱 정책:

- 오늘 날짜(`Asia/Seoul` 기준) `DailySnapshot`이 있으면 재사용.
- 날짜가 바뀌면 새로 계산. 앱 사용 중 자정이 지나면 다음 조회 시점에 새 날짜 기준으로 재계산한다.
- 엔진 버전이 바뀌면 `engineVersion` 비교 후 snapshot 재계산.
- 카드 획득은 deterministic seed 기반으로 중복 방지.
- 일일 보상은 날짜당 1회만 지급한다. 기기 시간을 되돌려 같은 날짜로 재진입해도 지급 이력(`owned_cards`)이 우선하므로 중복 지급되지 않는다.

```text
daily reward seed = birthProfileId + yyyyMMdd + todayPillar + engineVersion
```

## 오늘 홈 생성 플로우

```text
앱 실행
 -> 프로필 로드
 -> 오늘 날짜 KST 계산
 -> DailySnapshot 조회
 -> 없으면 EngineGateway 실행
 -> FiveElementScore 계산
 -> GuardianSelector 실행
 -> DailyFortuneEngine 실행
 -> RoutineRecommender 실행
 -> 카드 보상 결정
 -> DailySnapshot 저장
 -> 홈 화면 표시
```

Provider 예시:

```dart
@riverpod
Future<TodayHomeState> todayHome(TodayHomeRef ref) async {
  final profile = await ref.watch(activeProfileProvider.future);
  final repository = ref.watch(dailyFortuneRepositoryProvider);
  return repository.getOrCreateToday(profile.id);
}
```

## 카드/도감 보상

카드 시스템은 수익화가 아니라 재방문 동기다.

카드 타입:

- 오행 수호신 카드
- 십간/십이지 카드
- 오늘의 기운 카드
- 궁합 케미 카드
- 루틴 연속 달성 카드

보상 규칙:

- 하루 1회 기본 카드.
- 루틴 완료 시 추가 도장 또는 조각.
- 같은 카드 중복 시 숙련도/별빛 포인트 같은 비과금 성장값으로 전환.
- 랜덤은 완전 난수보다 deterministic seed 사용.
- 모든 카드는 무료 활동으로 획득 가능해야 한다.

## 공유 이미지

공유 대상:

- 오늘의 수호신 카드
- 오늘 운세 요약
- 오행 밸런스
- 궁합/케미 결과
- 도감 카드 획득 화면

구현 방식:

1. 공유 전용 Widget 작성.
2. `RepaintBoundary`로 이미지 캡처.
3. PNG 파일로 임시 저장.
4. `share_plus`로 공유.
5. 공유 완료 또는 취소 후 임시 파일 정리.

주의:

- 기본 공유 이미지에는 출생 시간 전체를 노출하지 않는다.
- 궁합 공유는 상대방 입력값 저장 여부를 명확히 분리한다.
- 앱 링크가 없더라도 이미지 자체로 의미가 전달되게 구성한다.

## 로컬 알림

서버 푸시는 사용하지 않는다.

MVP 알림 종류 (02 문서와 동일):

- 매일 아침 “오늘의 수호신 도착”
- 저녁 “오늘의 오행 루틴 체크”
- 카드 보상 미수령 알림

점심 오행 밸런스 체크, 주간 회고 알림은 MVP 이후 확장이다.

구현:

- `flutter_local_notifications`
- `timezone`으로 `Asia/Seoul` 기준 예약
- Android 13+ 알림 권한 요청
- iOS 권한 요청 및 사용자 거부 상태 처리
- 설정 화면에서 완전 비활성화 가능

Payload:

```text
type=today_guardian
date=yyyy-MM-dd
profileId=local-profile-id
```

알림 진입 처리:

- 알림을 탭해 진입한 시점에 오늘 `DailySnapshot`이 없으면 홈 생성 플로우가 즉시 계산한다. 알림 발송 시점에 스냅샷 존재를 가정하지 않는다.
- 계산 실패 시 홈의 엔진 계산 실패 상태(재시도 CTA)로 안전하게 진입한다.

## 테스트 구조

```text
test/
  engine/
    manseryeok_engine_test.dart
    solar_terms_test.dart
    sexagenary_cycle_test.dart
    five_element_score_test.dart
    compatibility_engine_test.dart
  features/
    fortune/
    routine/
    cards/
  data/
    app_database_test.dart
  golden/
    share_card_golden_test.dart

integration_test/
  app_smoke_test.dart
  onboarding_to_today_test.dart
```

테스트 원칙:

- 엔진은 Flutter 없이 테스트 가능해야 한다.
- 오늘 날짜 의존성은 `AppClock`으로 주입한다.
- 랜덤 보상은 seed 주입으로 재현 가능해야 한다.
- Drift migration 테스트를 포함한다.
- 공유 이미지는 golden test로 최소 1개 이상 검증한다.

## MVP에서 제외하는 기술

- 로그인 서버
- 서버 DB
- 클라우드 동기화
- 결제 SDK
- 광고 SDK
- 원격 푸시
- 랭킹/소셜 피드
- AI 해석 서버
- 위치 기반 정밀 태양시 보정
- 사용자 행동 분석 SDK

## 참고 링크

- Flutter Architecture Guide: https://docs.flutter.dev/app-architecture/guide
- Flutter Offline-first: https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- Flutter Testing Overview: https://docs.flutter.dev/testing/overview
- Riverpod: https://pub.dev/packages/flutter_riverpod
- go_router: https://pub.dev/packages/go_router
- Drift: https://pub.dev/packages/drift
- flutter_local_notifications: https://pub.dev/packages/flutter_local_notifications
- share_plus: https://pub.dev/packages/share_plus
- path_provider: https://pub.dev/packages/path_provider
- timezone: https://pub.dev/packages/timezone
