# 도메인/데이터 명세

## 기본 원칙

- 앱 목적은 만세력 기반의 개인화된 오늘 운세, 수호신, 오행 루틴, 카드/도감, 궁합/케미 제공이다.
- 광고, 인앱결제, 유료 재화, 유료 카드팩, 확률형 결제 보상 데이터는 정의하지 않는다.
- 해석 톤은 결정론적 예언이 아니라 자기이해, 루틴, 회고 중심의 가벼운 운세 콘텐츠다.
- 기본 저장 방식은 로컬 우선이다.
- 날짜 기준은 기본 `Asia/Seoul`이다.
- 만세력 계산은 재현 가능해야 하므로 계산 버전과 규칙 버전을 함께 저장한다.

## 공통 타입

### FiveElement

| 값 | 한글 | 성향 태그 |
|---|---|---|
| `wood` | 목 | 성장, 계획, 확장 |
| `fire` | 화 | 표현, 활력, 관계 |
| `earth` | 토 | 안정, 정리, 신뢰 |
| `metal` | 금 | 판단, 집중, 절제 |
| `water` | 수 | 회복, 지혜, 흐름 |

### YinYang

| 값 | 의미 |
|---|---|
| `yang` | 양 |
| `yin` | 음 |

### TenGod

값은 한국어 로마자 표기(국어의 로마자 표기법)로 통일한다.

| 값 | 한글 |
|---|---|
| `bigyeon` | 비견 |
| `geobjae` | 겁재 |
| `siksin` | 식신 |
| `sanggwan` | 상관 |
| `pyeonjae` | 편재 |
| `jeongjae` | 정재 |
| `pyeongwan` | 편관 |
| `jeonggwan` | 정관 |
| `pyeonin` | 편인 |
| `jeongin` | 정인 |

### Stem / Branch

```ts
type Stem = {
  code: string;        // 갑, 을, 병...
  index: number;       // 0-9
  element: FiveElement;
  yinYang: YinYang;
};

type Branch = {
  code: string;        // 자, 축, 인...
  index: number;       // 0-11
  element: FiveElement;
  yinYang: YinYang;
  hiddenStems: string[];
};
```

## 사용자 프로필

### UserProfile

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `id` | string | Y | 로컬 UUID |
| `nickname` | string | Y | 표시 이름 |
| `avatarId` | string | N | 기본 아바타 또는 수호신 이미지 ID |
| `birthProfileId` | string | Y | 대표 출생 프로필 |
| `createdAt` | datetime | Y | 생성 시각 |
| `updatedAt` | datetime | Y | 수정 시각 |
| `settings` | UserSettings | Y | 앱 설정 |

규칙:

- 닉네임은 1-20자.
- 한 기기에서 여러 출생 프로필을 가질 수 있으나 대표 프로필은 1개.
- 삭제 시 연결된 기록, 카드, 케미 기록은 사용자 선택에 따라 함께 삭제 가능해야 한다.

### UserSettings

| 필드 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `timezone` | string | `Asia/Seoul` | 날짜 계산 기준 |
| `calendarType` | enum | `solar` | 입력 선호: 양력/음력 |
| `notificationEnabled` | bool | false | 알림 사용 여부 |
| `dailyReminderTime` | time | `08:00` | 오늘 운세 알림 |
| `fortuneTone` | enum | `soft` | 해석 톤: soft, playful, concise (설정 화면에서 변경) |
| `notificationTypes` | map | 전체 off | 알림 종류별 on/off: 아침 수호신, 저녁 루틴, 카드 미수령 |
| `quietHours` | range? | null | 방해금지 시간대 |

백업/동기화 기능은 MVP에 없다. 없다는 사실을 개인정보 안내에 명시한다. 로컬 백업 내보내기는 무료 확장 백로그 항목이다.

## 출생 프로필

### BirthProfile

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `id` | string | Y | UUID |
| `userId` | string | Y | 소유자 |
| `displayName` | string | Y | 본인, 친구, 파트너 등 |
| `birthDate` | date | Y | 입력 생년월일 |
| `birthTime` | time | N | 출생 시간 |
| `birthTimeKnown` | bool | Y | 시간 정보 여부 |
| `calendarType` | enum | Y | `solar`, `lunar` |
| `isLeapMonth` | bool | N | 음력 윤달 여부 |
| `timezone` | string | Y | 출생지 시간대 |
| `genderMode` | enum | N | 전통 대운 계산용 선택값 |
| `createdAt` | datetime | Y | 생성 시각 |

규칙:

- `calendarType = lunar`이면 `isLeapMonth` 필드가 필요하다.
- 출생 시간이 없으면 시주는 `unknown`으로 계산하고, 해석에서도 시간 기반 요소를 제외한다.
- MVP에서 `timezone`은 `Asia/Seoul` 고정이다. 기준 TS 엔진이 한국 법정시 정책 전용이므로 다른 시간대 입력은 검증 기준이 없다. 사용자 수정 기능은 진태양시 보정과 함께 v2 후보다.
- `genderMode`가 없으면 대운 계산을 생략하고, 대운 기반 해석을 결과에서 제외한다. 기준 TS 엔진의 `gender`는 필수 입력이므로 EngineGateway 계약에서 대운 요청 시 `genderMode`를 필수로 검증한다.
- 민감정보이므로 서버 전송은 명시적 동의 없이는 금지한다.

## 만세력 엔진

### ManseryeokConfig

| 필드 | 타입 | 설명 |
|---|---|---|
| `engineVersion` | string | 계산 엔진 버전 |
| `ruleVersion` | string | 절기/일주/시주 계산 규칙 버전 |
| `timezone` | string | 계산 기준 시간대 |
| `monthPillarRule` | enum | 기본 `solar_term` |
| `dayBoundaryRule` | enum | `midnight`, `late_zi_hour` |
| `unknownTimePolicy` | enum | `omit_hour_pillar` |

규칙:

- 월주는 음력 월이 아니라 절기 기준으로 계산한다.
- 일주는 지정된 기준일과 60갑자 순환표로 계산한다.
- 시주는 출생 시간이 있을 때만 계산한다.
- 계산 결과에는 반드시 `engineVersion`, `ruleVersion`을 남겨 재계산 차이를 추적한다.
- `dayBoundaryRule`은 기준 TS 엔진의 `midnightMode`와 1:1 매핑한다: `late_zi_hour` = `yaja`(야자시), `midnight` = `joja`(조자시). 매핑은 EngineGateway 계약 문서에 고정하고 fixture로 검증한다.

### FourPillars

| 필드 | 타입 | 설명 |
|---|---|---|
| `birthProfileId` | string | 대상 프로필 |
| `yearPillar` | Pillar | 연주 |
| `monthPillar` | Pillar | 월주 |
| `dayPillar` | Pillar | 일주 |
| `hourPillar` | Pillar? | 시주 |
| `dayMaster` | Stem | 일간 |
| `elementBalance` | ElementBalance | 오행 분포 |
| `tenGodSummary` | TenGodSummary | 십신 분포 |
| `calculatedAt` | datetime | 계산 시각 |
| `config` | ManseryeokConfig | 계산 규칙 |

### Pillar

| 필드 | 타입 | 설명 |
|---|---|---|
| `stem` | Stem | 천간 |
| `branch` | Branch | 지지 |
| `ganji` | string | 예: 갑자 |
| `stemTenGod` | TenGod? | 일간 기준 천간 십신 |
| `hiddenStemTenGods` | TenGod[] | 지장간 십신 |

## 일진 / 오늘 데이터

### DailyCycle

| 필드 | 타입 | 설명 |
|---|---|---|
| `date` | date | 앱 기준 날짜 |
| `timezone` | string | 날짜 기준 |
| `dayPillar` | Pillar | 일진 |
| `monthPillar` | Pillar | 해당 절기 월주 |
| `yearPillar` | Pillar | 해당 연주 |
| `solarTerm` | string? | 절기명 |
| `elementVector` | ElementBalance | 오늘 오행 |
| `createdByRuleVersion` | string | 계산 규칙 |

규칙:

- `DailyCycle`은 사용자와 독립적인 날짜 데이터다.
- 같은 날짜라도 시간대가 다르면 결과가 달라질 수 있으므로 `timezone`을 키에 포함한다.

### DailyUserReading

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 결정적 ID: `reading_{userId}_{yyyyMMdd}` |
| `userId` | string | 사용자 |
| `birthProfileId` | string | 기준 프로필 |
| `date` | date | 대상 날짜 |
| `dailyCycleId` | string | 일진 참조 |
| `primaryElement` | FiveElement | 오늘 강조 오행 |
| `supportElement` | FiveElement | 보완 오행 |
| `primaryTenGod` | TenGod | 오늘 주요 십신 |
| `score` | int | 0-100 가벼운 컨디션 점수 |
| `summary` | string | 한 줄 운세 |
| `advice` | string | 오늘 조언 |
| `caution` | string | 주의 포인트 |
| `luckyItems` | LuckyItem[] | 색, 방향, 행동 등 |
| `guardianMatchId` | string | 오늘 수호신 매칭 |

규칙:

- 점수는 사용자 재미 요소이며 부정적 낙인을 피한다.
- `score < 40`이어도 “나쁜 날”이 아니라 조절/회복 중심 문구를 사용한다.
- 해석은 `사주 원국 + 오늘 일진 + 오행 균형 + 십신 관계`를 함께 본다.
- `summary`, `advice`, `caution` 문구는 엔진이 생성하지 않는다. 엔진/EngineGateway는 계산 결과와 근거 코드만 반환하고, 문구는 앱의 콘텐츠 레이어가 근거 코드 기반 템플릿으로 조립해 이 모델에 채운다.

## 오행 균형

### ElementBalance

| 필드 | 타입 | 설명 |
|---|---|---|
| `wood` | number | 목 비중 |
| `fire` | number | 화 비중 |
| `earth` | number | 토 비중 |
| `metal` | number | 금 비중 |
| `water` | number | 수 비중 |
| `dominant` | FiveElement[] | 강한 오행 |
| `weak` | FiveElement[] | 약한 오행 |

규칙:

- 내부 점수는 0 이상 숫자.
- 사용자 표시용 비율은 합계 100으로 정규화 가능.
- 천간, 지지, 지장간 가중치는 엔진 설정으로 관리한다.
- 약한 오행은 무조건 보충 대상이 아니라 오늘 일진과 함께 판단한다.

## 수호신

### Guardian

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 예: `guardian_wood_sprout` |
| `name` | string | 수호신 이름 |
| `element` | FiveElement | 대표 오행 |
| `yinYang` | YinYang? | 선택 성향 |
| `personalityTags` | string[] | 차분함, 돌파력 등 |
| `description` | string | 도감 설명 |
| `visualAssetId` | string | 이미지 리소스 |
| `routineBias` | string[] | 추천 루틴 태그 |
| `unlockCondition` | UnlockCondition | 획득 조건 |

### GuardianMatch

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | UUID |
| `userId` | string | 사용자 |
| `date` | date | 날짜 |
| `guardianId` | string | 매칭 수호신 |
| `matchReasonCodes` | string[] | 매칭 근거 코드 |
| `elementNeed` | FiveElement | 오늘 보완/활용 오행 |
| `confidence` | number | 0-1 |
| `message` | string | 사용자 표시 문구 |

매칭 규칙:

1. 사용자 원국의 오행 분포를 계산한다.
2. 오늘 일진의 오행과 십신을 반영한다.
3. 과다 오행은 더 키우기보다 정리/완충 루틴을 추천한다.
4. 부족 오행은 보충 루틴 후보로 올린다.
5. 같은 수호신이 연속으로 너무 자주 나오면 다양성 가중치를 적용한다.
6. 매칭 근거는 내부 코드로 남긴다.

근거 코드:

| 코드 | 의미 |
|---|---|
| `weak_element_support` | 약한 오행 보완 |
| `dominant_element_balance` | 강한 오행 조절 |
| `daily_tengod_focus` | 오늘 십신과 연결 |
| `routine_continuity` | 최근 루틴 흐름 유지 |
| `collection_rotation` | 도감 다양성 보정 |

## 오행 루틴

### RoutineTemplate

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 시맨틱 ID: `routine_wood_morning_walk` (마스터 데이터) |
| `title` | string | 루틴명 |
| `element` | FiveElement | 연결 오행 |
| `tags` | string[] | 산책, 정리, 글쓰기 등 |
| `durationMinutes` | int | 예상 시간 |
| `difficulty` | enum | `easy`, `normal`, `deep` |
| `repeatable` | bool | 반복 가능 여부 |
| `description` | string | 설명 |
| `completionType` | enum | `check`, `text`, `photo_optional` |

### DailyRoutineRecommendation

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | UUID |
| `userId` | string | 사용자 |
| `date` | date | 날짜 |
| `routineTemplateId` | string | 추천 루틴 |
| `sourceGuardianId` | string | 연결 수호신 |
| `reasonCode` | string | 추천 근거 |
| `priority` | int | 표시 순서 |
| `completed` | bool | 완료 여부 |
| `completedAt` | datetime? | 완료 시각 |

추천 규칙:

- 하루 기본 추천은 1-3개.
- 5분 이내 루틴을 최소 1개 포함한다.
- 사용자가 반복적으로 완료하지 않는 루틴은 난이도를 낮춘다.
- 미완료 페널티는 없다.
- 루틴 완료는 카드/도감 해금 조건으로 사용할 수 있으나 유료 재화와 연결하지 않는다.

### RoutineStreak

| 필드 | 타입 | 설명 |
|---|---|---|
| `userId` | string | 사용자 |
| `currentStreak` | int | 현재 연속 완료 일수 |
| `longestStreak` | int | 최장 연속 기록 |
| `lastCompletedDate` | date? | 마지막 완료 날짜 |

스트릭 규칙:

- 하루 1개 이상 루틴 완료 시 그날은 스트릭에 포함된다.
- 하루를 건너뛰면 `currentStreak`은 0에서 다시 시작하되, `longestStreak`은 유지한다.
- 끊김을 실패나 손실로 표현하지 않는다. “다시 시작” 관점의 문구만 사용한다.
- 날짜 판정 기준은 `Asia/Seoul`이다.
- 기기 시간을 되돌려도 이미 지난 날짜의 스트릭은 소급 변경되지 않는다.

## 카드 / 도감

### Card

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 카드 ID |
| `name` | string | 카드명 |
| `guardianId` | string? | 연결 수호신 |
| `element` | FiveElement | 오행 |
| `rarity` | enum | `common`, `rare`, `special` |
| `assetId` | string | 이미지 |
| `flavorText` | string | 짧은 설명 |
| `unlockCondition` | UnlockCondition | 해금 조건 |

### UserCardCollection

| 필드 | 타입 | 설명 |
|---|---|---|
| `userId` | string | 사용자 |
| `cardId` | string | 카드 |
| `unlocked` | bool | 획득 여부 |
| `unlockedAt` | datetime? | 획득 시각 |
| `count` | int | 중복 획득 수 |
| `firstSource` | enum | `daily_guardian`, `routine`, `streak`, `chemistry`, `event` |

규칙:

- 확률형 유료 뽑기 없음.
- 카드는 행동, 출석, 루틴, 케미 공유 등 무료 활동으로 해금한다.
- `rarity`는 수집 난이도 표현일 뿐 과금 가치가 아니다.
- 중복 카드는 유료 재화로 환산하지 않는다.

### UnlockCondition

| 필드 | 타입 | 설명 |
|---|---|---|
| `type` | enum | `first_visit`, `routine_count`, `guardian_seen`, `element_balance`, `chemistry_shared`, `calendar_record`, `streak`, `event` |
| `targetId` | string? | 대상 수호신/오행/루틴 |
| `requiredCount` | int | 필요 횟수 |
| `period` | enum? | `daily`, `weekly`, `lifetime` |

## 궁합 / 케미

### ChemistryProfile

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | UUID |
| `ownerUserId` | string | 생성자 |
| `birthProfileId` | string | 대상 출생 프로필 |
| `label` | string | 친구, 연인, 팀원 등 |
| `relationType` | enum | `friend`, `love`, `family`, `work`, `custom` |

### ChemistryResult

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | UUID |
| `profileAId` | string | 기준 A |
| `profileBId` | string | 기준 B |
| `calculatedAt` | datetime | 계산 시각 |
| `overallScore` | int | 0-100 |
| `elementHarmony` | ElementHarmony | 오행 조화 |
| `tenGodRelation` | TenGodRelationSummary | 십신 관계 |
| `strengths` | string[] | 강점 |
| `frictions` | string[] | 주의점 |
| `routineSuggestionIds` | string[] | 함께 하기 좋은 루틴 |
| `shareCardId` | string? | 공유 이미지 카드 |

규칙:

- 두 사람의 일간, 오행 분포, 일지 관계, 주요 십신 관계를 비교한다.
- 결과는 관계 단정이 아니라 “잘 맞는 방식 / 조심할 소통 방식”으로 표현한다.
- 낮은 점수도 부정 표현 대신 보완 루틴을 함께 제공한다.
- 공유 이미지는 민감한 생년월일을 기본적으로 숨긴다.

## 기록 / 캘린더

### DailyRecord

| 필드 | 타입 | 설명 |
|---|---|---|
| `id` | string | 결정적 ID: `record_{userId}_{yyyyMMdd}` |
| `userId` | string | 사용자 |
| `date` | date | 날짜 |
| `mood` | enum? | `great`, `good`, `neutral`, `tired`, `hard` |
| `energyLevel` | int? | 1-5 |
| `memo` | string? | 짧은 메모 |
| `completedRoutineIds` | string[] | 완료 루틴 |
| `guardianId` | string | 그날 수호신 |
| `dailyReadingId` | string | 오늘 운세 |
| `createdAt` | datetime | 생성 |
| `updatedAt` | datetime | 수정 |

규칙:

- 하루 하나의 대표 기록을 가진다.
- 메모는 로컬 저장 기본.
- 감정 기록은 운세 점수와 분리한다.

### CalendarDaySummary

| 필드 | 타입 | 설명 |
|---|---|---|
| `date` | date | 날짜 |
| `guardianId` | string? | 수호신 |
| `primaryElement` | FiveElement? | 대표 오행 |
| `routineCompletedCount` | int | 완료 수 |
| `hasMemo` | bool | 메모 여부 |
| `mood` | enum? | 감정 |
| `cardUnlockedCount` | int | 획득 카드 수 |

## 데이터 무결성 규칙

- `BirthProfile` 삭제 시 연결된 `FourPillars`, `DailyUserReading`, `ChemistryResult`는 재계산 또는 삭제 대상이다.
- `BirthProfile` 수정 시 오늘 날짜의 `DailyUserReading`, `GuardianMatch`, `FourPillars`는 즉시 재계산한다. 과거 날짜의 기록, 카드, 케미 결과는 계산 당시 `engineVersion`/`ruleVersion` 기준으로 보존하고 소급 재계산하지 않는다.
- 카드/도감(`UserCardCollection`), 기록(`DailyRecord`), 스트릭(`RoutineStreak`)은 사용자(`userId`) 소유다. 대표 출생 프로필을 변경해도 유지된다. 변경 시 오늘의 운세/수호신만 새 대표 프로필 기준으로 재계산한다.
- `Guardian`, `Card`, `RoutineTemplate`은 앱 버전에 포함되는 마스터 데이터다.
- 마스터 데이터 ID는 앱 업데이트 후에도 바뀌지 않아야 한다.
- 계산 데이터는 `ruleVersion`이 바뀌면 재계산 가능 상태로 표시한다.
- 사용자가 보는 문구 데이터와 계산 근거 데이터는 분리한다.
- 공유 데이터에는 생년월일, 출생시간, 메모를 기본 포함하지 않는다.

## 핵심 식별자 설계

```text
user_{uuid}
birth_{uuid}
daily_cycle_{yyyyMMdd}_{timezone}
reading_{userId}_{yyyyMMdd}
guardian_wood_sprout
routine_wood_morning_walk
card_fire_first_spark
chemistry_{uuid}
record_{userId}_{yyyyMMdd}
```

식별자 규칙:

- 마스터 데이터(수호신, 카드, 루틴 템플릿)는 시맨틱 ID를 사용한다.
- 하루 1개인 사용자 데이터(운세, 기록)는 `{종류}_{userId}_{yyyyMMdd}` 결정적 ID를 사용한다.
- 그 외 사용자 생성 데이터는 UUID를 사용한다.
- ID에 포함되는 timezone 문자열은 `/`를 `_`로 치환한다. 예: `daily_cycle_20260707_Asia_Seoul`.

## 정의하지 않는 데이터

무료 앱 기준으로 다음 데이터 모델은 만들지 않는다.

- 유료 재화
- 광고 시청 보상
- 유료 카드팩
- 확률형 결제 뽑기
- 구독 등급
- 결제 이력
- 유료 전용 수호신
- 결제 기반 루틴 잠금
- 랭킹 경쟁형 과금 지표

보상 구조는 “오늘 확인 → 루틴 실천 → 기록 → 도감 해금 → 공유”의 무료 순환으로 설계한다.
