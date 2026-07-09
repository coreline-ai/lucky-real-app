export interface ToolSmokeFixture {
  group: string;
  label: string;
  args: Record<string, unknown>;
}

const BIRTH_1990 = {
  year: 1990,
  month: 3,
  day: 15,
  hour: 14,
  minute: 30,
  gender: 'male',
} as const;

export const TOOL_SMOKE_FIXTURES: Record<string, ToolSmokeFixture> = {
  calendar_day_info: {
    group: 'Calendar',
    label: '2026-07-09 일진',
    args: { year: 2026, month: 7, day: 9 },
  },
  calendar_month: {
    group: 'Calendar',
    label: '2026년 7월 compact 달력',
    args: { year: 2026, month: 7, compact: true },
  },
  date_convert: {
    group: 'Calendar',
    label: '양력 2026-07-09 → 음력',
    args: { direction: 'solar_to_lunar', year: 2026, month: 7, day: 9 },
  },
  solar_terms: {
    group: 'Calendar',
    label: '2026-02-04 절기 조회',
    args: { year: 2026, month: 2, day: 4 },
  },
  korean_legal_time: {
    group: 'Calendar',
    label: '2026-01-01 12:00 법정시',
    args: { year: 2026, month: 1, day: 1, hour: 12, minute: 0 },
  },
  saju_full_reading: {
    group: 'Saju',
    label: '1990-03-15 14:30 전체 중 palja+sipsin',
    args: { birth: BIRTH_1990, include: ['sipsin'] },
  },
  saju_palja: {
    group: 'Saju',
    label: '1990-03-15 14:30 팔자',
    args: { birth: BIRTH_1990 },
  },
  saju_daeun: {
    group: 'Saju',
    label: '1990-03-15 남성 대운 3개',
    args: { birth: BIRTH_1990, count: 3 },
  },
  compatibility_score: {
    group: 'Compatibility',
    label: '1990 남성 × 1992 여성 케미',
    args: {
      person1: BIRTH_1990,
      person2: { year: 1992, month: 7, day: 21, hour: 9, minute: 0, gender: 'female' },
    },
  },
  tojeong_yearly: {
    group: 'Tojeong',
    label: '1990 생 2026 토정비결',
    args: { birth: BIRTH_1990, targetYear: 2026 },
  },
  ziwei_chart: {
    group: 'Charts',
    label: '1990-03-15 14시 자미두수',
    args: { birth: BIRTH_1990, interpret: false },
  },
  qimen_chart: {
    group: 'Charts',
    label: '2026-07-09 12시 기문둔갑',
    args: { year: 2026, month: 7, day: 9, hour: 12, interpret: false },
  },
  daeyukim_chart: {
    group: 'Charts',
    label: '2026-07-09 12시 대육임',
    args: { year: 2026, month: 7, day: 9, hour: 12, interpret: false },
  },
  guseong_chart: {
    group: 'Charts',
    label: '1990 남성 2026-07-09 구성기학',
    args: { birthYear: 1990, gender: 'male', targetYear: 2026, targetMonth: 7, targetDay: 9 },
  },
  harak_reading: {
    group: 'Numeric',
    label: '1990-03-15 하락이수',
    args: { year: 1990, month: 3, day: 15 },
  },
  daejeong_reading: {
    group: 'Numeric',
    label: '1990-03-15 대정수',
    args: { birth: BIRTH_1990 },
  },
  hongyeon_reading: {
    group: 'Numeric',
    label: '1990-03-15 홍연',
    args: { birth: BIRTH_1990 },
  },
  maehwa_divination: {
    group: 'Numeric',
    label: '2026-07-09 12시 매화역수',
    args: { cast: { method: 'time', year: 2026, month: 7, day: 9, hour: 12 } },
  },
  naming_analyze: {
    group: 'Naming',
    label: '김민준 작명 분석',
    args: { surname: '김', candidates: [{ givenName: '민준', hanjaChars: ['金', '民', '俊'] }] },
  },
  ganji_info: {
    group: 'Naming',
    label: '庚午己卯 간지 정보',
    args: { ganji: '庚午己卯' },
  },
};

export const FIXTURE_GROUPS = [
  'Calendar',
  'Saju',
  'Compatibility',
  'Tojeong',
  'Charts',
  'Numeric',
  'Naming',
] as const;
