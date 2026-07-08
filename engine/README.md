# manseryeok

한국 사주·만세력 계산을 위한 TypeScript 엔진입니다. 생년월일시 입력을 음양력, 윤달, 한국 법정시, 절기 경계, 자시 기준, 진태양시 보정 정책에 따라 정규화하고 사주팔자와 관련 운세 계산 결과를 제공합니다.

## 포함 기능

### 만세력 핵심

- 양력 입력과 음력 입력 지원
- 음력 윤달 변환 지원
- 한국 법정시 정책 반영
  - UTC+08:30 시기
  - UTC+09:00 시기
  - 1948~1960, 1987~1988 하절기/DST
  - 존재하지 않는 민간시각과 중복 민간시각 오류 처리
- 진태양시 보정
  - 관측지 경도
  - 기준 자오선
  - 균시차
- 24절기 데이터와 절입 시각 기반 월주 계산
- 연주, 월주, 일주, 시주 계산
- 야자시/조자시 기준 선택
- 지원 범위: 공개 계산 기준 1908-04-01 ~ 2101년, 내부 절기/음양력 원천 데이터 1899 ~ 2101년

### 사주 분석

- 팔자 산출
- 대운, 세운, 월운 계산
- 대운 시작 나이와 시작 개월 수 계산
- 십신 계산
- 지장간 십신 계산
- 운성 계산
- 신살 계산
- 지지 합·충·형·파·해 관계 분석
- 공망 계산
- 납음오행 계산
- 원진 분석
- 격국 판단
- 용신 판단

### 확장 엔진

- 궁합
- 달력
- 작명
- 자미두수
- 기문둔갑
- 토정비결
- 대육임
- 홍연
- 매화역수
- 하락이수
- 구성학
- 대정수

## 설치

```bash
npm install
```

## 검증

```bash
npm run type-check
npm run build
npm test
npm run solar-terms:verify
```

## 기본 입력 형식

```ts
type BirthInputData = {
  year: number;
  month: number;
  day: number;
  hour: number | null;
  minute: number | null;
  gender: 'male' | 'female';
  isLunar: boolean;
  isLeapMonth?: boolean;
  birthPlace: string | null;
};

type CalculateOptions = {
  trueSolarTime?: boolean;
  longitude?: number;
  midnightMode?: 'yaja' | 'joja';
};
```

## 사주팔자 계산

```ts
import { calculatePalja } from 'manseryeok-engine';

const birth = {
  year: 1990,
  month: 3,
  day: 15,
  hour: 14,
  minute: 30,
  gender: 'male' as const,
  isLunar: false,
  birthPlace: 'Seoul',
};

const palja = calculatePalja(birth, {
  trueSolarTime: true,
  longitude: 126.978,
  midnightMode: 'yaja',
});

console.log(palja);
// {
//   yearGan: '庚',
//   yearJi: '午',
//   monthGan: '己',
//   monthJi: '卯',
//   dayGan: '...',
//   dayJi: '...',
//   hourGan: '...',
//   hourJi: '...'
// }
```

## 종합 사주 결과 계산

```ts
import { buildSajuResult } from 'manseryeok-engine';

const result = buildSajuResult(birth, {
  calculateOptions: {
    trueSolarTime: true,
    longitude: 126.978,
    midnightMode: 'yaja',
  },
  now: new Date('2026-07-07T00:00:00+09:00'),
  subSchool: 'gyeokguk',
});

console.log(result.palja);
console.log(result.sipsin);
console.log(result.daeun);
console.log(result.seun);
console.log(result.wolun);
console.log(result.gyeokguk);
console.log(result.yongsin);
```

## 대운·세운·월운 계산

```ts
import {
  calculatePalja,
  calculateDaeun,
  calculateSeun,
  calculateWolun,
  calculateYunStartAge,
} from 'manseryeok-engine';

const palja = calculatePalja(birth);
const daeun = calculateDaeun(palja, birth, 8);
const yunStartAge = calculateYunStartAge(birth);
const seun = calculateSeun(2026);
const wolun = calculateWolun(new Date('2026-07-07T00:00:00+09:00'));

console.log({ daeun, yunStartAge, seun, wolun });
```

## 음양력 변환과 절기 조회

```ts
import { ManseryeokEngine } from 'manseryeok-engine';

const lunar = ManseryeokEngine.solarToLunar({
  year: 1990,
  month: 3,
  day: 15,
  hour: 14,
  minute: 30,
});

const solar = ManseryeokEngine.lunarToSolar({
  year: 1990,
  month: 2,
  day: 19,
  isLeapMonth: false,
  hour: 14,
  minute: 30,
});

const terms = ManseryeokEngine.listSolarTermsForYear(2026);
const context = ManseryeokEngine.getSolarContext({
  year: 2026,
  month: 2,
  day: 4,
  hour: 5,
  minute: 0,
});

console.log({ lunar, solar, terms, context });
```

## 정규화 컨텍스트 확인

```ts
import { createNormalizedManseryeokContext } from 'manseryeok-engine';

const context = createNormalizedManseryeokContext(birth, {
  trueSolarTime: true,
  longitude: 126.978,
  midnightMode: 'yaja',
});

console.log(context.legalTime);
console.log(context.trueSolar);
console.log(context.yearMonthContextDateTime);
console.log(context.dayHourContextDateTime);
```

## 오류 처리

한국 법정시 전환 구간에서는 입력 시각이 존재하지 않거나 중복될 수 있습니다. 이 경우 명시적인 엔진 오류가 발생합니다.

```ts
import {
  createNormalizedManseryeokContext,
  ManseryeokPolicyError,
  NonexistentCivilTimeError,
  AmbiguousCivilTimeError,
} from 'manseryeok-engine';

try {
  createNormalizedManseryeokContext({
    year: 1961,
    month: 8,
    day: 10,
    hour: 0,
    minute: 15,
    gender: 'male',
    isLunar: false,
    birthPlace: null,
  });
} catch (error) {
  if (error instanceof NonexistentCivilTimeError) {
    console.error('존재하지 않는 민간시각입니다.', error.context);
  } else if (error instanceof AmbiguousCivilTimeError) {
    console.error('중복 민간시각입니다.', error.context);
  } else if (error instanceof ManseryeokPolicyError) {
    console.error('만세력 정책 오류입니다.', error.context);
  } else {
    throw error;
  }
}
```

## 주요 공개 API

- `calculatePalja(input, options?)`
- `buildSajuResult(input, options?)`
- `calculateDaeun(palja, input, count?, options?)`
- `calculateYunStartAge(input, options?)`
- `calculateSeun(yearOrDate)`
- `calculateWolun(date)`
- `createNormalizedManseryeokContext(input, options?)`
- `ManseryeokEngine.solarToLunar(input)`
- `ManseryeokEngine.lunarToSolar(input)`
- `ManseryeokEngine.getGanji(input)`
- `ManseryeokEngine.getSolarContext(input)`
- `ManseryeokEngine.listSolarTermsForYear(year)`

## 라이선스

ISC
