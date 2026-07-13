import { resolveSchool } from '../adapter/school-resolver';
import { correctToTrueSolarTime } from '../adapter/time-corrector';
import {
  calculateDayGanScore,
  calculateDayJiScore,
  calculateGuseongScore,
  calculateOhaengComplementScore,
} from '../compatibility/scoring';
import type {
  CompatibilityCategory,
  CompatibilityGrade,
  CompatibilityResult,
} from '../compatibility/types';
import { resolveKoreanLegalTime } from '../core/korean-legal-time';
import type { LunarDateTime, SolarDateTime } from '../core/lunar-solar';
import {
  normalizeSolarTermToKst,
  type SolarTermInfo,
} from '../core/solar-term-normalization';
import { shiftDateTimeUtc, toKstTimestamp, type DateTimeParts } from '../core/temporal';
import {
  calculateHongguksu,
  calculateSeoncheonsu,
  getBonmyeongseong,
} from '../hongyeon/index';
import type { CalendarDay, Gender, MidnightMode, Ohaeng, Palja } from '../types';

export interface BrowserShardFetchResponse {
  readonly ok: boolean;
  readonly status: number;
  json(): Promise<unknown>;
}

export type BrowserShardFetch = (url: string) => Promise<BrowserShardFetchResponse>;

export interface BrowserShardedCalendarOptions {
  /** Public URL containing manifest.json, lunar-solar/, and solar-terms/. */
  baseUrl: string;
  /** Injectable for tests, non-browser runtimes, or custom auth/CDN behavior. */
  fetch?: BrowserShardFetch;
}

interface YearRange {
  startYear: number;
  endYear: number;
}

interface FileMetadata<TCount> {
  path: string;
  count: TCount;
  bytes: number;
  sha256: string;
}

interface LunarSolarShardCount {
  solarToLunar: number;
  lunarToSolar: number;
  total: number;
}

export interface BrowserDataManifest {
  version: number;
  lunarSolar: {
    range: YearRange;
    solarToLunarRange: YearRange;
    lunarToSolarRange: YearRange;
    count: { solarToLunar: number; lunarToSolar: number };
    shards: Record<string, FileMetadata<LunarSolarShardCount>>;
  };
  solarTerms: {
    range: YearRange;
    count: number;
    shards: Record<string, FileMetadata<number>>;
  };
}

interface LunarSolarShard {
  solarToLunar: Record<string, [number, number, number, number]>;
  lunarToSolar: Record<string, [number, number, number]>;
}

export interface BrowserCalculateOptions {
  trueSolarTime?: boolean;
  longitude?: number;
  midnightMode?: MidnightMode;
}

export interface BrowserBirthInput {
  year: number;
  month: number;
  day: number;
  hour: number | null;
  minute: number | null;
  gender: Gender;
  isLunar?: boolean;
  isLeapMonth?: boolean;
  birthPlace?: string | null;
  calculateOptions?: BrowserCalculateOptions;
}

export interface BrowserShardedCalendar {
  solarToLunarAsync(input: SolarDateTime): Promise<LunarDateTime>;
  lunarToSolarAsync(input: LunarDateTime): Promise<SolarDateTime>;
  listSolarTermsForYearAsync(year: number): Promise<SolarTermInfo[]>;
  getCalendarDayAsync(year: number, month: number, day: number): Promise<CalendarDay>;
  calculatePaljaAsync(input: BrowserBirthInput, options?: BrowserCalculateOptions): Promise<Palja>;
  calculateCompatibilityAsync(
    person1: BrowserBirthInput,
    person2: BrowserBirthInput,
  ): Promise<CompatibilityResult>;
  loadManifest(): Promise<BrowserDataManifest>;
  clearCache(): void;
}

const MANIFEST_VERSION = 1;

const STEMS = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'] as const;
const BRANCHES = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'] as const;
const MONTH_BRANCH_START_INDEX = 2;
const MAJOR_SOLAR_TERM_TO_MONTH_INDEX: Record<string, number> = {
  소한: 11,
  입춘: 0,
  경칩: 1,
  청명: 2,
  입하: 3,
  망종: 4,
  소서: 5,
  입추: 6,
  백로: 7,
  한로: 8,
  입동: 9,
  대설: 10,
};
const TIGER_MONTH_STEM_START: Record<string, number> = {
  甲: 2,
  己: 2,
  乙: 4,
  庚: 4,
  丙: 6,
  辛: 6,
  丁: 8,
  壬: 8,
  戊: 0,
  癸: 0,
};
const JIJI_KOREAN = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'] as const;
const GAN_HANJA_TO_KOREAN: Record<string, string> = {
  甲: '갑',
  乙: '을',
  丙: '병',
  丁: '정',
  戊: '무',
  己: '기',
  庚: '경',
  辛: '신',
  壬: '임',
  癸: '계',
};
const JI_HANJA_TO_KOREAN: Record<string, string> = {
  子: '자',
  丑: '축',
  寅: '인',
  卯: '묘',
  辰: '진',
  巳: '사',
  午: '오',
  未: '미',
  申: '신',
  酉: '유',
  戌: '술',
  亥: '해',
};
const GAN_OHAENG_MAP: Record<string, Ohaeng> = {
  갑: '목',
  을: '목',
  병: '화',
  정: '화',
  무: '토',
  기: '토',
  경: '금',
  신: '금',
  임: '수',
  계: '수',
};
const SINSAL_12_ORDER = ['건록', '제신', '만일', '평일', '정일', '집일', '파일', '위일', '성일', '수일', '개일', '폐일'] as const;
const GIL_SINSAL = new Set(['건록', '만일', '성일', '개일']);
const HYUNG_SINSAL = new Set(['파일', '위일', '폐일']);
const TAEKIL_MAP: Record<string, string> = {
  건록: '사업 시작, 취직, 이사에 좋음',
  제신: '청소, 치료, 제사에 적합',
  만일: '혼인, 개업, 건축에 좋음',
  평일: '평범한 날, 작은 일에 무난',
  정일: '계약, 약속, 협의에 적합',
  집일: '수리, 보수, 정리에 적합',
  파일: '소송에 좋으나 건축/이사에 나쁨',
  위일: '조심해야 할 날, 큰일 피할 것',
  성일: '무역, 계약, 건축에 좋음',
  수일: '수확, 정리, 마무리에 적합',
  개일: '개업, 이사, 치료에 좋음',
  폐일: '모든 일 불리, 특히 개업/이사 나쁨',
};

interface GanjiPillar {
  gan: string;
  ji: string;
  ganji: string;
}

interface GanjiResult {
  year: GanjiPillar;
  month: GanjiPillar;
  day: GanjiPillar;
  hour: GanjiPillar;
}

interface BrowserGanjiInput extends SolarDateTime {
  sect?: number;
  yearMonthDateTime?: Partial<DateTimeParts>;
  dayHourDateTime?: Partial<DateTimeParts>;
  dayHourDateTimeSchoolApplied?: boolean;
}

interface ResolvedGanjiInput {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
  sect: number;
  yearMonthDateTime: DateTimeParts;
  dayHourDateTime: DateTimeParts;
  dayHourDateTimeSchoolApplied: boolean;
}

interface BrowserBirthContext {
  yearMonthContextDateTime: DateTimeParts;
  dayHourContextDateTime: DateTimeParts;
  dayHourDateTimeSchoolApplied: boolean;
  sect: number;
}

function pad(value: number): string {
  return String(value).padStart(2, '0');
}

function pad2(value: number): string {
  return String(value).padStart(2, '0');
}

function mod(value: number, divisor: number): number {
  return ((value % divisor) + divisor) % divisor;
}

function solarKey(input: SolarDateTime): string {
  return `${input.year}-${pad(input.month)}-${pad(input.day)}`;
}

function lunarKey(input: LunarDateTime): string {
  return `${input.year}-${pad(input.month)}-${pad(input.day)}-${input.isLeapMonth ? 1 : 0}`;
}

function timeParts(input: SolarDateTime | LunarDateTime) {
  return {
    hour: input.hour ?? 0,
    minute: input.minute ?? 0,
    second: input.second ?? 0,
  };
}

function resolveDateTime(
  base: Pick<BrowserGanjiInput, 'year' | 'month' | 'day' | 'hour' | 'minute' | 'second'>,
  override?: Partial<DateTimeParts>,
): DateTimeParts {
  return {
    year: override?.year ?? base.year,
    month: override?.month ?? base.month,
    day: override?.day ?? base.day,
    hour: override?.hour ?? base.hour ?? 0,
    minute: override?.minute ?? base.minute ?? 0,
    second: override?.second ?? base.second ?? 0,
  };
}

function resolveGanjiInput(input: BrowserGanjiInput): ResolvedGanjiInput {
  const base = {
    year: input.year,
    month: input.month,
    day: input.day,
    hour: input.hour ?? 0,
    minute: input.minute ?? 0,
    second: input.second ?? 0,
  };

  return {
    ...base,
    sect: input.sect ?? 2,
    yearMonthDateTime: resolveDateTime(base, input.yearMonthDateTime),
    dayHourDateTime: resolveDateTime(base, input.dayHourDateTime),
    dayHourDateTimeSchoolApplied: input.dayHourDateTimeSchoolApplied ?? false,
  };
}

function createPillar(sexagenaryIndex: number): GanjiPillar {
  const normalized = mod(sexagenaryIndex, 60);
  const gan = STEMS[normalized % 10];
  const ji = BRANCHES[normalized % 12];
  return { gan, ji, ganji: `${gan}${ji}` };
}

function toJulianDay(year: number, month: number, day: number): number {
  const a = Math.floor((14 - month) / 12);
  const y = year + 4800 - a;
  const m = month + 12 * a - 3;

  return (
    day +
    Math.floor((153 * m + 2) / 5) +
    365 * y +
    Math.floor(y / 4) -
    Math.floor(y / 100) +
    Math.floor(y / 400) -
    32045 -
    0.5
  );
}

function shiftSolarDate(year: number, month: number, day: number, offset: number) {
  const shifted = new Date(Date.UTC(year, month - 1, day));
  shifted.setUTCDate(shifted.getUTCDate() + offset);

  return {
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1,
    day: shifted.getUTCDate(),
  };
}

function getDayIndex(year: number, month: number, day: number): number {
  return mod(Math.floor(toJulianDay(year, month, day) + 49.5), 60);
}

function getHourBranchIndex(hour: number): number {
  if (hour === 23 || hour === 0) return 0;
  return Math.floor((hour + 1) / 2);
}

function getHourStemIndex(dayStem: string, hourBranchIndex: number): number {
  const dayStemIndex = STEMS.indexOf(dayStem as (typeof STEMS)[number]);
  const offsets = [0, 2, 4, 6, 8];
  return mod(offsets[dayStemIndex % 5] + hourBranchIndex, 10);
}

function jiToIndex(ji: string): number {
  const idx = JIJI_KOREAN.indexOf(ji as (typeof JIJI_KOREAN)[number]);
  if (idx === -1) throw new Error(`유효하지 않은 지지: ${ji}`);
  return idx;
}

function getSinsal12(monthJi: string, dayJi: string): string {
  return SINSAL_12_ORDER[(jiToIndex(dayJi) - jiToIndex(monthJi) + 12) % 12];
}

function getGilhyung(sinsal12: string): '길' | '흉' | '평' {
  if (GIL_SINSAL.has(sinsal12)) return '길';
  if (HYUNG_SINSAL.has(sinsal12)) return '흉';
  return '평';
}

function getGanOhaeng(gan: string): Ohaeng {
  const ohaeng = GAN_OHAENG_MAP[gan];
  if (!ohaeng) throw new Error(`유효하지 않은 천간: ${gan}`);
  return ohaeng;
}

function getGrade(score: number): CompatibilityGrade {
  if (score >= 85) return 'S';
  if (score >= 70) return 'A';
  if (score >= 55) return 'B';
  if (score >= 40) return 'C';
  return 'D';
}

function getGradeSummary(grade: CompatibilityGrade): string {
  if (grade === 'S') return '천생연분! 서로를 자연스럽게 끌어당기는 최상의 궁합입니다.';
  if (grade === 'A') return '좋은 궁합입니다. 서로를 보완하며 함께 성장할 수 있습니다.';
  if (grade === 'B') return '무난한 궁합입니다. 노력하면 좋은 관계를 유지할 수 있습니다.';
  if (grade === 'C') return '다소 마찰이 있을 수 있지만, 이해와 노력으로 극복 가능합니다.';
  return '도전적인 궁합입니다. 서로 다름을 인정하는 것이 중요합니다.';
}

function buildAdvice(
  dayGanType: string,
  dayJiType: string,
  ohaengScore: number,
  guseongScore: number,
): string[] {
  const advice: string[] = [];
  if (dayGanType === '천간합') {
    advice.push('일간이 합하여 천생의 인연입니다. 서로에 대한 신뢰를 꾸준히 쌓아가세요.');
  } else if (dayGanType === '천간충') {
    advice.push('일간이 충하여 갈등이 있을 수 있습니다. 대화로 풀어가는 습관이 중요합니다.');
  }
  if (dayJiType === '육합') {
    advice.push('일지가 육합하여 감정적 교류가 깊습니다. 함께하는 시간이 행복의 원천이 됩니다.');
  } else if (dayJiType === '충') {
    advice.push('일지가 충하여 가정 내 마찰에 주의하세요. 서로의 공간을 존중해 주세요.');
  }
  if (ohaengScore < 10) advice.push('두 사람의 오행이 편중되어 있습니다. 부족한 오행 방향의 활동을 함께 해보세요.');
  if (guseongScore >= 18) advice.push('본명성이 상생하여 함께할수록 시너지가 납니다.');
  if (advice.length === 0) advice.push('서로의 장점을 살리고 부족한 부분을 보완해 나가세요.');
  return advice;
}

function buildPalja(ganji: GanjiResult, includeTime: boolean): Palja {
  return {
    yearGan: ganji.year.gan,
    yearJi: ganji.year.ji,
    monthGan: ganji.month.gan,
    monthJi: ganji.month.ji,
    dayGan: ganji.day.gan,
    dayJi: ganji.day.ji,
    hourGan: includeTime ? ganji.hour.gan : '',
    hourJi: includeTime ? ganji.hour.ji : '',
  };
}

function assertSafeYear(year: number, label: string): void {
  if (!Number.isSafeInteger(year) || year < 1 || year > 9999) {
    throw new Error(`Invalid ${label} year: ${String(year)}`);
  }
}

function assertYearInRange(year: number, range: YearRange, label: string): void {
  assertSafeYear(year, label);
  if (year < range.startYear || year > range.endYear) {
    throw new Error(`Unsupported ${label} year: ${year} (supported ${range.startYear}-${range.endYear})`);
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function assertManifest(value: unknown): asserts value is BrowserDataManifest {
  if (!isRecord(value) || value.version !== MANIFEST_VERSION) {
    throw new Error(`Unsupported browser data manifest version: ${isRecord(value) ? String(value.version) : 'invalid'}`);
  }
  if (!isRecord(value.lunarSolar) || !isRecord(value.solarTerms)) {
    throw new Error('Invalid browser data manifest');
  }
}

function getDefaultFetch(): BrowserShardFetch {
  const fetchImplementation = globalThis.fetch;
  if (typeof fetchImplementation !== 'function') {
    throw new Error('No fetch implementation available; pass options.fetch');
  }
  return (url) => fetchImplementation(url) as Promise<BrowserShardFetchResponse>;
}

function normalizeBaseUrl(baseUrl: string): string {
  if (typeof baseUrl !== 'string' || baseUrl.trim() === '') {
    throw new Error('baseUrl must be a non-empty public URL');
  }
  return baseUrl.replace(/\/+$/, '');
}

export function createBrowserShardedCalendar(
  options: BrowserShardedCalendarOptions,
): BrowserShardedCalendar {
  const baseUrl = normalizeBaseUrl(options.baseUrl);
  const fetchImplementation = options.fetch ?? getDefaultFetch();
  const memoryCache = new Map<string, unknown>();
  const inFlight = new Map<string, Promise<unknown>>();
  let cacheGeneration = 0;

  function publicUrl(relativePath: string): string {
    return `${baseUrl}/${relativePath}`;
  }

  async function loadJson<T>(relativePath: string): Promise<T> {
    if (memoryCache.has(relativePath)) {
      return memoryCache.get(relativePath) as T;
    }

    const pending = inFlight.get(relativePath);
    if (pending) return pending as Promise<T>;

    const generation = cacheGeneration;
    const request = (async () => {
      const response = await fetchImplementation(publicUrl(relativePath));
      if (!response.ok) {
        throw new Error(`Failed to load browser data shard ${relativePath}: HTTP ${response.status}`);
      }
      const value = await response.json();
      if (generation === cacheGeneration) memoryCache.set(relativePath, value);
      return value as T;
    })();

    inFlight.set(relativePath, request);
    try {
      return await request;
    } finally {
      if (inFlight.get(relativePath) === request) inFlight.delete(relativePath);
    }
  }

  async function loadManifest(): Promise<BrowserDataManifest> {
    const manifest = await loadJson<unknown>('manifest.json');
    assertManifest(manifest);
    return manifest;
  }

  async function loadLunarSolarShard(
    year: number,
    rangeKind: 'solarToLunarRange' | 'lunarToSolarRange',
    label: string,
  ): Promise<LunarSolarShard> {
    assertSafeYear(year, label);
    const manifest = await loadManifest();
    assertYearInRange(year, manifest.lunarSolar[rangeKind], label);
    const metadata = manifest.lunarSolar.shards[String(year)];
    if (!metadata) throw new Error(`Missing lunar/solar shard metadata for year ${year}`);

    const shard = await loadJson<unknown>(`lunar-solar/${year}.json`);
    if (!isRecord(shard) || !isRecord(shard.solarToLunar) || !isRecord(shard.lunarToSolar)) {
      throw new Error(`Invalid lunar/solar shard for year ${year}`);
    }
    if (
      Object.keys(shard.solarToLunar).length !== metadata.count.solarToLunar
      || Object.keys(shard.lunarToSolar).length !== metadata.count.lunarToSolar
    ) {
      throw new Error(`Lunar/solar shard record count mismatch for year ${year}`);
    }
    return shard as unknown as LunarSolarShard;
  }

  async function solarToLunarAsync(input: SolarDateTime): Promise<LunarDateTime> {
    const key = solarKey(input);
    const shard = await loadLunarSolarShard(input.year, 'solarToLunarRange', 'solar');
    const match = shard.solarToLunar[key];
    if (!match) throw new Error(`Unsupported solar date: ${key}`);

    return {
      year: match[0],
      month: match[1],
      day: match[2],
      isLeapMonth: Boolean(match[3]),
      ...timeParts(input),
    };
  }

  async function lunarToSolarAsync(input: LunarDateTime): Promise<SolarDateTime> {
    const key = lunarKey(input);
    const shard = await loadLunarSolarShard(input.year, 'lunarToSolarRange', 'lunar');
    const match = shard.lunarToSolar[key];
    if (!match) throw new Error(`Unsupported lunar date: ${key}`);

    return {
      year: match[0],
      month: match[1],
      day: match[2],
      ...timeParts(input),
    };
  }

  async function listSolarTermsForYearAsync(year: number): Promise<SolarTermInfo[]> {
    assertSafeYear(year, 'solar-term');
    const manifest = await loadManifest();
    assertYearInRange(year, manifest.solarTerms.range, 'solar-term');
    const metadata = manifest.solarTerms.shards[String(year)];
    if (!metadata) throw new Error(`Missing solar-term shard metadata for year ${year}`);

    const terms = await loadJson<unknown>(`solar-terms/${year}.json`);
    if (!Array.isArray(terms) || terms.length !== metadata.count) {
      throw new Error(`Solar-term shard record count mismatch for year ${year}`);
    }
    return (terms as SolarTermInfo[]).map(normalizeSolarTermToKst);
  }

  async function getEffectiveYear(input: ResolvedGanjiInput): Promise<number> {
    const context = input.yearMonthDateTime;
    const ipchun = (await listSolarTermsForYearAsync(context.year)).find((term) => term.koreanName === '입춘');
    if (!ipchun) throw new Error(`No 입춘 data for ${context.year}`);
    const effectiveTs = toKstTimestamp(context);
    const ipchunTs = toKstTimestamp(ipchun);
    return effectiveTs >= ipchunTs ? context.year : context.year - 1;
  }

  async function getLatestMajorSolarTerm(input: ResolvedGanjiInput): Promise<SolarTermInfo> {
    const context = input.yearMonthDateTime;
    const effectiveTs = toKstTimestamp(context);
    const candidates = [
      ...(await listSolarTermsForYearAsync(context.year - 1)),
      ...(await listSolarTermsForYearAsync(context.year)),
    ].filter((term) => term.koreanName in MAJOR_SOLAR_TERM_TO_MONTH_INDEX);

    let best: SolarTermInfo | null = null;
    for (const term of candidates) {
      const termTs = toKstTimestamp(term);
      if (termTs <= effectiveTs && (!best || termTs > toKstTimestamp(best))) {
        best = term;
      }
    }

    if (!best) throw new Error(`No major solar term found for ${context.year}-${context.month}-${context.day}`);
    return best;
  }

  async function getYearPillar(input: ResolvedGanjiInput): Promise<GanjiPillar> {
    const effectiveYear = await getEffectiveYear(input);
    return createPillar(effectiveYear - 1984);
  }

  async function getMonthPillar(input: ResolvedGanjiInput): Promise<GanjiPillar> {
    const [latestTerm, yearPillar] = await Promise.all([
      getLatestMajorSolarTerm(input),
      getYearPillar(input),
    ]);
    const monthIndex = MAJOR_SOLAR_TERM_TO_MONTH_INDEX[latestTerm.koreanName];
    const stemStart = TIGER_MONTH_STEM_START[yearPillar.gan];
    const stem = STEMS[mod(stemStart + monthIndex, 10)];
    const branch = BRANCHES[mod(MONTH_BRANCH_START_INDEX + monthIndex, 12)];

    return {
      gan: stem,
      ji: branch,
      ganji: `${stem}${branch}`,
    };
  }

  function getDayPillar(input: ResolvedGanjiInput): GanjiPillar {
    const context = input.dayHourDateTime;
    const baseDate =
      input.sect === 1 && context.hour === 23 && !input.dayHourDateTimeSchoolApplied
        ? shiftSolarDate(context.year, context.month, context.day, 1)
        : { year: context.year, month: context.month, day: context.day };

    return createPillar(getDayIndex(baseDate.year, baseDate.month, baseDate.day));
  }

  function getHourPillar(input: ResolvedGanjiInput): GanjiPillar {
    const context = input.dayHourDateTime;
    const hourBranchIndex = getHourBranchIndex(context.hour);
    const hourBaseDate =
      context.hour === 23 && !input.dayHourDateTimeSchoolApplied
        ? shiftSolarDate(context.year, context.month, context.day, 1)
        : { year: context.year, month: context.month, day: context.day };
    const hourBaseDayPillar = createPillar(
      getDayIndex(hourBaseDate.year, hourBaseDate.month, hourBaseDate.day),
    );
    const hourStemIndex = getHourStemIndex(hourBaseDayPillar.gan, hourBranchIndex);
    const gan = STEMS[hourStemIndex];
    const ji = BRANCHES[hourBranchIndex];

    return {
      gan,
      ji,
      ganji: `${gan}${ji}`,
    };
  }

  async function getGanjiAsync(input: BrowserGanjiInput): Promise<GanjiResult> {
    const resolved = resolveGanjiInput(input);
    const [year, month] = await Promise.all([
      getYearPillar(resolved),
      getMonthPillar(resolved),
    ]);

    return {
      year,
      month,
      day: getDayPillar(resolved),
      hour: getHourPillar(resolved),
    };
  }

  async function resolveBrowserBirthContext(
    input: BrowserBirthInput,
    options: BrowserCalculateOptions = {},
  ): Promise<BrowserBirthContext> {
    const resolvedOptions = {
      trueSolarTime: options.trueSolarTime ?? false,
      longitude: options.longitude ?? 127.0,
      midnightMode: options.midnightMode ?? 'yaja',
    };
    const internal: DateTimeParts = {
      year: input.year,
      month: input.month,
      day: input.day,
      hour: input.hour ?? 0,
      minute: input.minute ?? 0,
      second: 0,
    };
    const solarCivilDateTime = input.isLunar
      ? await lunarToSolarAsync({
          year: input.year,
          month: input.month,
          day: input.day,
          isLeapMonth: input.isLeapMonth ?? false,
          hour: internal.hour,
          minute: internal.minute,
          second: internal.second,
        })
      : internal;
    const solarCivil: DateTimeParts = {
      year: solarCivilDateTime.year,
      month: solarCivilDateTime.month,
      day: solarCivilDateTime.day,
      hour: solarCivilDateTime.hour ?? 0,
      minute: solarCivilDateTime.minute ?? 0,
      second: solarCivilDateTime.second ?? 0,
    };
    const legalTime = resolveKoreanLegalTime(solarCivil);
    const standardCivilDateTime = legalTime.daylightOffsetMinutes === 0
      ? solarCivil
      : shiftDateTimeUtc(solarCivil, -legalTime.daylightOffsetMinutes);
    const corrected = resolvedOptions.trueSolarTime
      ? correctToTrueSolarTime(
          standardCivilDateTime,
          resolvedOptions.longitude,
          { standardLongitude: legalTime.standardMeridianDegrees },
        )
      : undefined;
    const trueSolarDateTime = corrected
      ? shiftDateTimeUtc(
          {
            year: corrected.year,
            month: corrected.month,
            day: corrected.day,
            hour: corrected.hour,
            minute: corrected.minute,
            second: standardCivilDateTime.second,
          },
          corrected.dayOffset * 24 * 60,
        )
      : solarCivil;
    const schoolEvaluationDateTime = resolvedOptions.trueSolarTime ? trueSolarDateTime : solarCivil;
    const school = resolveSchool(
      resolvedOptions.midnightMode as MidnightMode,
      schoolEvaluationDateTime.hour,
      schoolEvaluationDateTime.minute,
    );
    const dayHourContextDateTime = school.useCurrentDay
      ? schoolEvaluationDateTime
      : shiftDateTimeUtc(schoolEvaluationDateTime, 24 * 60);

    return {
      yearMonthContextDateTime: schoolEvaluationDateTime,
      dayHourContextDateTime,
      dayHourDateTimeSchoolApplied: !school.useCurrentDay,
      sect: school.sect,
    };
  }

  async function getCalendarDayAsync(year: number, month: number, day: number): Promise<CalendarDay> {
    const solar = { year, month, day, hour: 0, minute: 0, second: 0 };
    const [lunar, ganji, terms] = await Promise.all([
      solarToLunarAsync(solar),
      getGanjiAsync(solar),
      listSolarTermsForYearAsync(year),
    ]);
    const dayGan = GAN_HANJA_TO_KOREAN[ganji.day.gan] ?? ganji.day.gan;
    const dayJi = JI_HANJA_TO_KOREAN[ganji.day.ji] ?? ganji.day.ji;
    const monthJi = JI_HANJA_TO_KOREAN[ganji.month.ji] ?? ganji.month.ji;
    const sinsal12 = getSinsal12(monthJi, dayJi);
    const exact = terms.find((term) => term.year === year && term.month === month && term.day === day);

    return {
      solarDate: `${year}-${pad2(month)}-${pad2(day)}`,
      lunarDate: `${lunar.year}-${pad2(lunar.month)}-${pad2(lunar.day)}`,
      lunarMonth: lunar.month,
      lunarDay: lunar.day,
      isLeapMonth: lunar.isLeapMonth,
      dayGan,
      dayJi,
      dayGanJi: `${dayGan}${dayJi}`,
      ohaeng: getGanOhaeng(dayGan),
      sinsal12,
      gilhyung: getGilhyung(sinsal12),
      taekil: TAEKIL_MAP[sinsal12] ?? '',
      ...(exact ? { jieqi: exact.koreanName } : {}),
    };
  }

  async function calculatePaljaAsync(
    input: BrowserBirthInput,
    options: BrowserCalculateOptions = input.calculateOptions ?? {},
  ): Promise<Palja> {
    const context = await resolveBrowserBirthContext(input, options);
    const ganji = await getGanjiAsync({
      ...context.yearMonthContextDateTime,
      sect: context.sect,
      yearMonthDateTime: context.yearMonthContextDateTime,
      dayHourDateTime: context.dayHourContextDateTime,
      dayHourDateTimeSchoolApplied: context.dayHourDateTimeSchoolApplied,
    });
    return buildPalja(ganji, input.hour !== null && input.minute !== null);
  }

  async function calculateCompatibilityAsync(
    person1: BrowserBirthInput,
    person2: BrowserBirthInput,
  ): Promise<CompatibilityResult> {
    const [palja1, palja2] = await Promise.all([
      calculatePaljaAsync(person1, person1.calculateOptions),
      calculatePaljaAsync(person2, person2.calculateOptions),
    ]);
    const dayGan = calculateDayGanScore(palja1.dayGan, palja2.dayGan);
    const dayJi = calculateDayJiScore(palja1.dayJi, palja2.dayJi);
    const ohaeng = calculateOhaengComplementScore(palja1, palja2);
    const bm1 = getBonmyeongseong(calculateHongguksu(calculateSeoncheonsu(palja1)));
    const bm2 = getBonmyeongseong(calculateHongguksu(calculateSeoncheonsu(palja2)));
    const guseong = calculateGuseongScore(bm1.ohaeng, bm2.ohaeng);
    const totalScore = dayGan.score + dayJi.score + ohaeng.score + guseong.score;
    const grade = getGrade(totalScore);
    const categories: CompatibilityCategory[] = [
      { key: 'dayGan', name: '성격 궁합', score: dayGan.score, maxScore: 30, description: dayGan.description, details: [`일간 관계: ${dayGan.type}`] },
      { key: 'dayJi', name: '감정 궁합', score: dayJi.score, maxScore: 25, description: dayJi.description, details: [`일지 관계: ${dayJi.type}`] },
      { key: 'ohaeng', name: '오행 균형', score: ohaeng.score, maxScore: 25, description: ohaeng.description, details: [] },
      { key: 'guseong', name: '기운 조화', score: guseong.score, maxScore: 20, description: guseong.description, details: [`${bm1.name} × ${bm2.name}`] },
    ];

    return {
      totalScore,
      grade,
      summary: getGradeSummary(grade),
      categories,
      dayGanRelation: { type: dayGan.type, description: dayGan.description },
      dayJiRelation: { type: dayJi.type, description: dayJi.description },
      ohaengComplement: { score: ohaeng.score, description: ohaeng.description },
      guseongRelation: { score: guseong.score, description: guseong.description },
      advice: buildAdvice(dayGan.type, dayJi.type, ohaeng.score, guseong.score),
      person1Palja: palja1,
      person2Palja: palja2,
    };
  }

  return {
    solarToLunarAsync,
    lunarToSolarAsync,
    listSolarTermsForYearAsync,
    getCalendarDayAsync,
    calculatePaljaAsync,
    calculateCompatibilityAsync,
    loadManifest,
    clearCache() {
      cacheGeneration += 1;
      memoryCache.clear();
      inFlight.clear();
    },
  };
}
