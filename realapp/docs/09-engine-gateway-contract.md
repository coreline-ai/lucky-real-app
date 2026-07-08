# EngineGateway 계약

작성일: 2026-07-07  
계약 버전: `1.0.0`  
기준 엔진: `manseryeok-engine@0.1.0` (repo `engine/`)  
규칙 버전(ruleVersion): `krlt-yaja-2026.07` — 한국 법정시 정책 + 야자시 기본 + 절기 월주

이 문서는 Flutter 앱과 만세력 엔진 사이의 JSON 계약을 고정한다. Dart 엔진 포팅은 이 계약과 fixture(`realapp/engine-fixtures/`)를 기준으로 검증한다.

## 공통 규칙

- 시간대는 `Asia/Seoul` 고정. 요청에 timezone 필드가 있어도 MVP에서는 `Asia/Seoul`만 유효하다.
- 출생 시간 미상은 `hour: null, minute: null`로 표현한다. 이때 시주(`pillars.hour`)는 `null`이다.
- 게이트웨이 응답에는 사용자 문구(summary/advice 등 string copy) 필드를 두지 않는다. 문구는 앱 콘텐츠 레이어가 근거 코드로 조립한다.
- 모든 응답에는 `meta.engineVersion`, `meta.ruleVersion`을 포함한다.
- 간지 문자는 한자(예: `庚`, `午`)를 정본으로 한다. 한글 표기는 표시 레이어 책임이다.

## BirthInput

```json
{
  "year": 1990,
  "month": 3,
  "day": 15,
  "hour": 14,
  "minute": 30,
  "calendarType": "solar",
  "isLeapMonth": false,
  "genderMode": "male",
  "timezone": "Asia/Seoul"
}
```

| 계약 필드 | TS 엔진 `BirthInputData` | 비고 |
|---|---|---|
| `year/month/day` | `year/month/day` | 그대로 |
| `hour/minute` (nullable) | `hour/minute` (nullable) | null = 출생시 미상 |
| `calendarType: "solar"\|"lunar"` | `isLunar: boolean` | `lunar` → `true` |
| `isLeapMonth` | `isLeapMonth` | `calendarType=lunar`일 때만 의미 |
| `genderMode: "male"\|"female"\|null` | `gender` (필수) | 팔자/일진 계산은 성별 무관. **대운 계산 시에만 필수** — null이면 대운 API를 호출하지 않는다. 엔진 호출이 불가피할 때는 임의값 전달 금지, 대운 생략 |
| `timezone` | (없음) | 엔진은 KST 전용. `Asia/Seoul` 외 값은 `INVALID_INPUT` |
| (옵션) `dayBoundaryRule` | `midnightMode` | 아래 매핑표 |

### dayBoundaryRule ↔ midnightMode 매핑

| 계약 값 | TS 엔진 값 | 의미 | 기본 |
|---|---|---|---|
| `late_zi_hour` | `yaja` | 야자시: 23시대 출생은 당일 일주 유지, 시주만 다음날 자시 | ✔ 기본값 |
| `midnight` | `joja` | 조자시: 23시부터 일주가 다음날로 전환 | |

## 메서드

### 1. calculateFourPillars(BirthInput) → FourPillarsResult

```json
{
  "meta": { "engineVersion": "0.1.0", "ruleVersion": "krlt-yaja-2026.07" },
  "pillars": {
    "year":  { "gan": "庚", "ji": "午" },
    "month": { "gan": "己", "ji": "卯" },
    "day":   { "gan": "辛", "ji": "巳" },
    "hour":  { "gan": "乙", "ji": "未" }
  },
  "dayMaster": "辛",
  "sipsin": { "yearGan": "겁재", "monthGan": "편인" },
  "jijanggan": { "yearJi": ["丙", "己", "丁"] },
  "jijangganSipsin": { "yearJi": { "bongi": "정관" } }
}
```

- `pillars.hour`는 출생시 미상이면 `null`.
- `sipsin`/`jijanggan`/`jijangganSipsin`의 키·값은 TS 엔진 `calculateSipsin`/`extractJijanggan`/`calculateJijangganSipsin` 출력을 정본으로 한다 (fixture 참조).

### 2. calculateDailyCycle(date) → DailyCycleResult

입력: `{ "year": 2026, "month": 7, "day": 7 }` (시각은 정오 12:00 고정으로 계산)

```json
{
  "meta": { "engineVersion": "0.1.0", "ruleVersion": "krlt-yaja-2026.07" },
  "date": "2026-07-07",
  "yearPillar":  { "gan": "丙", "ji": "午" },
  "monthPillar": { "gan": "甲", "ji": "午" },
  "dayPillar":   { "gan": "…", "ji": "…" },
  "solarTermContext": { "currentTerm": "소서", "isTermDay": false }
}
```

- 월주는 절기 기준. 절입일 경계는 fixture의 입춘 전후 케이스로 고정한다.

### 3. calculateDailyAnalysis(BirthInput, date) → DailyAnalysisResult

원국과 오늘 일진의 관계 계산값만 반환한다. 수호신 선택·점수·문구는 앱 레이어 책임이다.

```json
{
  "meta": { "engineVersion": "0.1.0", "ruleVersion": "krlt-yaja-2026.07" },
  "natal": { "…": "FourPillarsResult와 동일" },
  "daily": { "…": "DailyCycleResult와 동일" },
  "interaction": {
    "dayStemSipsin": "정재",
    "seun": { "gan": "丙", "ji": "午" },
    "wolun": { "gan": "甲", "ji": "午" }
  }
}
```

- `interaction.dayStemSipsin`: 원국 일간 기준으로 본 오늘 일간의 십신.

### 4. calculateChemistry(BirthInput, BirthInput) → ChemistryAnalysis

기준 구현: TS `engine/compatibility/calculateCompatibility` (2026-07-08 확정, 2차 개발).
점수 산식은 TS가 정본이다: 일간 30 + 일지 25 + 오행 보완 25 + 구성(본명성) 20 = 총 100.
관계 `type` 문자열은 TS 원문(`천간합`/`천간충`/`비화`/`상생`/`상극`, `육합`/`충`/`형`/`보통`)을
그대로 사용한다 — fixture 대조 일치성을 위해 코드화하지 않는다.
`summary`/`description`/`advice` 등 문구 필드는 **계약에서 제외**한다 (문구는 앱 콘텐츠 레이어).

```json
{
  "meta": { "engineVersion": "…", "ruleVersion": "…" },
  "totalScore": 73,
  "grade": "A",
  "dayGan": { "score": 20, "type": "상생" },
  "dayJi": { "score": 25, "type": "육합" },
  "ohaeng": { "score": 18, "missingElements": ["금"] },
  "guseong": { "score": 20, "bonmyeongA": "일백수성", "bonmyeongB": "삼벽목성" }
}
```

- 등급 경계: S≥85, A≥70, B≥55, C≥40, D<40 (TS `getGrade`).
- 출생시 미상(hour null)은 시주 없는 팔자로 계산된다 (오행 카운트 16→14글자, TS 동작 그대로).
- 두 입력 모두 게이트웨이의 날짜 범위 선검증을 거친다.

## 오류 모델

엔진 오류는 아래 코드로 매핑해 앱에 전달한다. 사용자 문구 변환은 앱 책임, 원문 메시지/스택은 노출 금지.

| 계약 오류 코드 | TS 엔진 오류 | 사용자 안내 분류 |
|---|---|---|
| `OUT_OF_SUPPORTED_RANGE` | 하한: `ManseryeokPolicyError`("legal time is not defined before the 1908…"), 상한: 코드 없는 `Error`("No 입춘 data for …"), 기타: `ManseryeokRangeError` | 지원 범위 밖 날짜 (1908-04-01 ~ 2101) |
| `NONEXISTENT_CIVIL_TIME` | `NonexistentCivilTimeError` | 존재하지 않는 시각 (법정시 전환) |
| `AMBIGUOUS_CIVIL_TIME` | `AmbiguousCivilTimeError` | 중복 시각 (법정시 전환) |
| `ENGINE_DATA_ERROR` | `ManseryeokDataError` | 내부 데이터 오류, 재시도 안내 |
| `ENGINE_POLICY_ERROR` | `ManseryeokPolicyError` (범위 관련 제외) | 내부 정책 오류, 재시도 안내 |
| `INVALID_INPUT` | (엔진 호출 전 앱 검증) | 필수 입력 누락, 잘못된 음력/윤달, 미래 생년월일, 비지원 timezone |

주의: TS 엔진의 실측 동작상 범위 위반이 단일 오류 타입으로 오지 않는다 (하한=POLICY, 상한=코드 없는 Error). **게이트웨이 구현은 엔진 호출 전에 날짜를 1908-04-01~2101-12-31 범위로 선검증**해 `OUT_OF_SUPPORTED_RANGE`를 직접 발생시키는 것을 정본 동작으로 한다. 엔진 오류 매핑은 방어선이다.

## 오행/음양 고정 매핑

계약에 포함되는 불변 지식이다. Dart 포팅 시 동일 테이블을 사용한다.

| 천간 | 甲 | 乙 | 丙 | 丁 | 戊 | 己 | 庚 | 辛 | 壬 | 癸 |
|---|---|---|---|---|---|---|---|---|---|---|
| 오행 | 목 | 목 | 화 | 화 | 토 | 토 | 금 | 금 | 수 | 수 |
| 음양 | 양 | 음 | 양 | 음 | 양 | 음 | 양 | 음 | 양 | 음 |

| 지지 | 子 | 丑 | 寅 | 卯 | 辰 | 巳 | 午 | 未 | 申 | 酉 | 戌 | 亥 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 오행 | 수 | 토 | 목 | 목 | 토 | 화 | 화 | 토 | 금 | 금 | 토 | 수 |
| 음양 | 양 | 음 | 양 | 음 | 양 | 음 | 양 | 음 | 양 | 음 | 양 | 음 |

오행 분포(ElementBalance)의 가중치(천간/지지/지장간)는 앱 설정으로 관리하며(03 문서), 계약은 원천 데이터(pillars, jijanggan)만 보장한다.

## Fixture

- 위치: `realapp/engine-fixtures/gateway-fixtures.v1.json`
- 재생성: `engine/` 디렉터리에서 `node scripts/generate-gateway-fixtures.mjs`
- 재생성 결과는 바이트 단위 동일해야 한다 (결정성).
- 케이스 구성: 대표 생년월일 5건, 음력/윤달, 출생시 미상, 야자시 vs 조자시 경계, 법정시 전환 오류 2건, 지원 범위 밖 2건, 일진/절기 경계(입춘 전후), 세운/월운, 음양력 상호 변환.
- Dart 포팅의 머지 게이트: fixture 전건 일치 (불일치는 원인 문서화 전까지 머지 금지).
