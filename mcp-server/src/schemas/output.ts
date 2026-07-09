// 툴 outputSchema 조각 (D10).
// 실용주의: 핵심 필드는 타입 고정, 엔진이 확장할 수 있는 대형·부가 필드는 passthrough.
// registerTool의 outputSchema는 ZodRawShape(필드명→zod 타입의 평면 객체)를 받는다.
import { z } from 'zod';

/** 모든 성공 응답에 포함되는 공용 메타 (D7) */
export const MetaSchema = z.object({
  engineVersion: z.string(),
  ruleVersion: z.string(),
});

// --- A그룹: 만세력·달력 ---

/** engine types.ts CalendarDay 1:1 */
export const CalendarDaySchema = z
  .object({
    solarDate: z.string(),
    lunarDate: z.string(),
    lunarMonth: z.number().int(),
    lunarDay: z.number().int(),
    isLeapMonth: z.boolean(),
    dayGan: z.string(),
    dayJi: z.string(),
    dayGanJi: z.string(),
    ohaeng: z.string(),
    sinsal12: z.string(),
    gilhyung: z.string(),
    taekil: z.string(),
    jieqi: z.string().optional(),
  })
  .passthrough();

/** compact 모드의 핵심 3필드. full 모드의 나머지 필드는 passthrough로 허용 */
export const CalendarDayCompactSchema = z
  .object({
    solarDate: z.string(),
    dayGanJi: z.string(),
    gilhyung: z.string(),
  })
  .passthrough();

/** engine solar-terms.ts SolarTermInfo 1:1 */
export const SolarTermSchema = z
  .object({
    sourceName: z.string(),
    koreanName: z.string(),
    year: z.number().int(),
    month: z.number().int(),
    day: z.number().int(),
    hour: z.number().int(),
    minute: z.number().int(),
    second: z.number().int(),
    julianDay: z.number(),
  })
  .passthrough();

/** 양·음력 날짜 공용 (음력이면 isLeapMonth 포함, 시각 필드는 엔진 원문 유지) */
export const ConvertedDateSchema = z
  .object({
    year: z.number().int(),
    month: z.number().int(),
    day: z.number().int(),
    isLeapMonth: z.boolean().optional(),
  })
  .passthrough();

/** engine korean-legal-time.ts KoreanLegalTimeResolution 1:1 */
export const LegalTimeResolutionSchema = z
  .object({
    policyId: z.string(),
    standardOffsetMinutes: z.number(),
    daylightOffsetMinutes: z.number(),
    totalOffsetMinutes: z.number(),
    standardMeridianDegrees: z.number(),
    transitionStatus: z.string(),
    sourceIds: z.array(z.string()),
  })
  .passthrough();

// --- 툴별 outputSchema (ZodRawShape) ---

export const calendarDayInfoOutput = {
  meta: MetaSchema,
  day: CalendarDaySchema,
};

export const calendarMonthOutput = {
  meta: MetaSchema,
  year: z.number().int(),
  month: z.number().int(),
  monthGanJi: z.string(),
  compact: z.boolean(),
  days: z.array(CalendarDayCompactSchema),
};

export const dateConvertOutput = {
  meta: MetaSchema,
  direction: z.enum(['solar_to_lunar', 'lunar_to_solar']),
  input: ConvertedDateSchema,
  result: ConvertedDateSchema,
};

export const solarTermsOutput = {
  meta: MetaSchema,
  query: z.object({
    year: z.number().int(),
    month: z.number().int().optional(),
    day: z.number().int().optional(),
  }),
  terms: z.array(SolarTermSchema),
};

export const koreanLegalTimeOutput = {
  meta: MetaSchema,
  input: z.object({
    year: z.number().int(),
    month: z.number().int(),
    day: z.number().int(),
    hour: z.number().int(),
    minute: z.number().int(),
    second: z.number().int(),
  }),
  resolution: LegalTimeResolutionSchema,
};

// --- B그룹: 사주 ---

/** engine types.ts Palja 1:1 — 시주 미상이면 hourGan/hourJi가 빈 문자열(D11) */
export const PaljaSchema = z.object({
  yearGan: z.string(),
  yearJi: z.string(),
  monthGan: z.string(),
  monthJi: z.string(),
  dayGan: z.string(),
  dayJi: z.string(),
  hourGan: z.string(),
  hourJi: z.string(),
});

export const PillarSchema = z.object({ gan: z.string(), ji: z.string() });

/** engine types.ts Daeun */
export const DaeunSchema = z
  .object({
    age: z.number().int(),
    gan: z.string(),
    ji: z.string(),
    ohaeng: z.string(),
    isCurrent: z.boolean(),
    startAgeMonths: z.number().optional(),
  })
  .passthrough();

export const SAJU_SUB_SCHOOLS = ['gyeokguk', 'johu', 'gangyak', 'mulsang'] as const;

/** saju_full_reading의 include 섹션 키 */
export const SAJU_SECTIONS = [
  'sipsin',
  'jijanggan',
  'unsung',
  'daeun',
  'un',
  'sinsal',
  'relations',
  'gyeokguk',
  'yongsin',
] as const;

/** SajuResult 부분집합 — palja는 항상 포함, 나머지는 include 필터에 따라 가변(passthrough) */
export const SajuReadingSchema = z.object({ palja: PaljaSchema }).passthrough();

export const sajuFullReadingOutput = {
  meta: MetaSchema,
  birthTimeKnown: z.boolean(),
  subSchool: z.enum(SAJU_SUB_SCHOOLS),
  sections: z.array(z.enum(SAJU_SECTIONS)),
  reading: SajuReadingSchema,
};

export const sajuPaljaOutput = {
  meta: MetaSchema,
  birthTimeKnown: z.boolean(),
  palja: PaljaSchema,
};

export const sajuDaeunOutput = {
  meta: MetaSchema,
  count: z.number().int(),
  daeun: z.array(DaeunSchema),
};

// --- C그룹: 궁합 ---

/** engine compatibility/types.ts CompatibilityResult — 핵심 필드 고정 + passthrough */
export const CompatibilityResultSchema = z
  .object({
    totalScore: z.number(),
    grade: z.string(),
    summary: z.string(),
    categories: z.array(
      z
        .object({ key: z.string(), name: z.string(), score: z.number(), maxScore: z.number() })
        .passthrough(),
    ),
    dayGanRelation: z.object({ type: z.string(), description: z.string() }).passthrough(),
    dayJiRelation: z.object({ type: z.string(), description: z.string() }).passthrough(),
    ohaengComplement: z.object({ score: z.number() }).passthrough(),
    guseongRelation: z.object({ score: z.number() }).passthrough(),
    advice: z.array(z.string()),
    person1Palja: PaljaSchema,
    person2Palja: PaljaSchema,
  })
  .passthrough();

export const compatibilityScoreOutput = {
  meta: MetaSchema,
  result: CompatibilityResultSchema,
};

// --- D그룹: 신수·연운 ---

export const tojeongYearlyOutput = {
  meta: MetaSchema,
  /** 계산에 실제 사용된 음력 생일 (양력 입력 시 자동 변환 결과, D6) */
  lunarBirth: ConvertedDateSchema,
  targetYear: z.number().int(),
  result: z
    .object({
      birthYear: z.number().int(),
      targetYear: z.number().int(),
      gwae: z
        .object({ gwaeCode: z.string(), gwaeNumber: z.number().int() })
        .passthrough(),
      interpretation: z
        .object({ title: z.string(), overall: z.string(), monthly: z.array(z.string()) })
        .passthrough(),
    })
    .passthrough(),
};

// --- E그룹: 명반형 차트 ---

export const ZIWEI_SCHOOLS = ['samhap', 'sahwa', 'jungju'] as const;
export const QIMEN_SCHOOLS = ['siguk', 'yeonguk', 'wolguk', 'hongyeon'] as const;

export const ziweiChartOutput = {
  meta: MetaSchema,
  school: z.enum(ZIWEI_SCHOOLS).optional(),
  chart: z
    .object({
      solarDate: z.string(),
      lunarDate: z.string(),
      fiveElementsClass: z.string(),
      soulPalaceBranch: z.string(),
      bodyPalaceBranch: z.string(),
      palaces: z.array(z.object({ index: z.number().int(), name: z.string() }).passthrough()),
    })
    .passthrough(),
  interpretation: z.object({}).passthrough().optional(),
  schoolAnalysis: z.object({}).passthrough().optional(),
};

export const qimenChartOutput = {
  meta: MetaSchema,
  school: z.enum(QIMEN_SCHOOLS).optional(),
  chart: z
    .object({
      dunType: z.string(),
      bureauNumber: z.number().int(),
      solarTerm: z.string(),
      yuan: z.string(),
      solarDate: z.string(),
      palaces: z.array(z.object({ index: z.number().int(), name: z.string() }).passthrough()),
    })
    .passthrough(),
  interpretation: z.object({}).passthrough().optional(),
  schoolAnalysis: z.object({}).passthrough().optional(),
};

export const daeyukimChartOutput = {
  meta: MetaSchema,
  chart: z
    .object({
      solarDate: z.string(),
      gwaMyeong: z.string(),
      wolJang: z.string(),
      saGwa: z.array(z.object({}).passthrough()),
      samJeon: z.array(z.object({}).passthrough()),
    })
    .passthrough(),
  interpretation: z.object({}).passthrough().optional(),
};

export const guseongChartOutput = {
  meta: MetaSchema,
  target: z.object({ year: z.number().int(), month: z.number().int(), day: z.number().int() }),
  result: z
    .object({
      birthYear: z.number().int(),
      gender: z.string(),
      bonmyeongseong: z
        .object({ number: z.number().int(), name: z.string(), ohaeng: z.string() })
        .passthrough(),
      interpretation: z.string(),
    })
    .passthrough(),
};

// --- F그룹: 수리형 ---

export const harakReadingOutput = {
  meta: MetaSchema,
  result: z
    .object({
      hadosu: z.number(),
      nakseosu: z.number(),
      hexagramNumber: z.number().int(),
      hexagramName: z.string(),
      interpretation: z.string(),
    })
    .passthrough(),
};

/** birth|palja 유니온 툴 공통 필드 (D5·D11) */
const paljaSourceFields = {
  paljaSource: z.enum(['birth', 'palja']),
  hourKnown: z.boolean(),
  palja: PaljaSchema,
};

export const daejeongReadingOutput = {
  meta: MetaSchema,
  ...paljaSourceFields,
  result: z
    .object({
      seoncheonsuTotal: z.number(),
      hucheonsuTotal: z.number(),
      hexagramNumber: z.number().int(),
      hexagramName: z.string(),
      changingLine: z.number().int(),
      interpretation: z.string(),
    })
    .passthrough(),
};

export const hongyeonReadingOutput = {
  meta: MetaSchema,
  ...paljaSourceFields,
  result: z
    .object({
      seoncheonsu: z.number(),
      hongguksu: z.number(),
      bonmyeongseong: z.string(),
      bonmyeongOhaeng: z.string(),
      gugung: z.array(z.object({}).passthrough()),
      tonggido: z.array(z.object({}).passthrough()),
      interpretation: z.string(),
    })
    .passthrough(),
};

export const maehwaDivinationOutput = {
  meta: MetaSchema,
  cast: z.object({ method: z.enum(['time', 'number', 'name']) }).passthrough(),
  result: z
    .object({
      method: z.string(),
      hexagramNumber: z.number().int(),
      hexagramName: z.string(),
      changingLine: z.number().int(),
      cheYongRelation: z.string(),
      interpretation: z.string(),
    })
    .passthrough(),
};

// --- G그룹: 작명·유틸 ---

export const namingAnalyzeOutput = {
  meta: MetaSchema,
  result: z
    .object({
      surname: z.string(),
      school: z.string(),
      candidates: z.array(
        z
          .object({
            name: z.string(),
            totalScore: z.number(),
            /** 한자 미입력 또는 DB 미등재 시 null */
            jawonOhaeng: z.object({}).passthrough().nullable(),
          })
          .passthrough(),
      ),
    })
    .passthrough(),
};

export const ganjiInfoOutput = {
  meta: MetaSchema,
  items: z.array(
    z.object({
      hanja: z.string(),
      kind: z.enum(['gan', 'ji', 'unknown']),
      korean: z.string().nullable(),
      ohaeng: z.string().nullable(),
    }),
  ),
};
