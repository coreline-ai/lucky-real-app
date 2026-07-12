import type { BirthInput } from './briefing';
import type { KstDateParts } from './kst';
import type { McpToolResult } from '../mcp/client';

export interface WeeklyFortune {
  mode: string;
  rangeLabel: string;
  summary: string;
  keywords: string[];
  goodDays: Array<{ label: string; ganji: string; reason: string }>;
  cautionDays: Array<{ label: string; ganji: string; reason: string }>;
  timeline: Array<{ label: string; ganji: string; element: string; note: string }>;
  evidence: string[];
}

export interface MonthlyFortune {
  mode: string;
  monthLabel: string;
  summary: string;
  monthGanji: string;
  keywords: string[];
  goodDays: Array<{ date: string; ganji: string; reason: string }>;
  cautionDays: Array<{ date: string; ganji: string; reason: string }>;
  turningPoints: string[];
  evidence: string[];
}

export interface TojeongFortune {
  targetYear: number;
  title: string;
  gwae: string;
  overall: string;
  monthly: string[];
  keywords: string[];
  evidence: string[];
}

export interface DeepCycleFortune {
  mode: string;
  summary: string;
  currentDaeun: string;
  seun: string;
  wolun: string;
  yongsin: string;
  gyeokguk: string;
  cautions: string[];
  evidence: string[];
}

interface CalendarDay {
  solarDate?: string;
  dayGan?: string;
  dayJi?: string;
  dayGanJi?: string;
  ohaeng?: string;
  sinsal12?: string;
  gilhyung?: string;
  taekil?: string;
  jieqi?: string;
}

interface CompactMonthDay {
  solarDate?: string;
  dayGanJi?: string;
  gilhyung?: string;
}

interface Palja {
  dayGan?: string;
  dayJi?: string;
}

function asRecord(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    throw new Error(`${label} 구조가 올바르지 않습니다.`);
  }
  return value as Record<string, unknown>;
}

function text(value: unknown, fallback = '-'): string {
  return typeof value === 'string' && value.trim() ? value.trim() : fallback;
}

function unique(values: string[]): string[] {
  return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
}

function collectStrings(value: unknown, limit = 12): string[] {
  const out: string[] = [];
  const visit = (input: unknown): void => {
    if (out.length >= limit) return;
    if (typeof input === 'string') {
      if (input.trim()) out.push(input.trim());
      return;
    }
    if (Array.isArray(input)) {
      input.forEach(visit);
      return;
    }
    if (typeof input === 'object' && input !== null) {
      Object.values(input as Record<string, unknown>).forEach(visit);
    }
  };
  visit(value);
  return unique(out).slice(0, limit);
}

function structured(result: McpToolResult, label: string): Record<string, unknown> {
  if (result.isError) throw new Error(`${label} tool이 오류를 반환했습니다.`);
  if (!result.structuredContent) throw new Error(`${label} structuredContent가 없습니다.`);
  return result.structuredContent;
}

function dayFrom(result: McpToolResult): CalendarDay {
  return asRecord(structured(result, 'calendar_day_info').day, 'calendar_day_info.day') as CalendarDay;
}

function readingFrom(result: McpToolResult): Record<string, unknown> {
  return asRecord(structured(result, 'saju_full_reading').reading, 'saju_full_reading.reading');
}

function paljaFrom(result: McpToolResult): Palja {
  return asRecord(structured(result, 'saju_palja').palja, 'saju_palja.palja') as Palja;
}

function personalDay(palja: Palja): string {
  return `${text(palja.dayGan, '?')}${text(palja.dayJi, '?')}`;
}

function elementKeywords(element: string): string[] {
  if (element.includes('목')) return ['성장', '시작', '확장'];
  if (element.includes('화')) return ['표현', '소통', '실행'];
  if (element.includes('토')) return ['균형', '점검', '기반'];
  if (element.includes('금')) return ['정돈', '판단', '기준'];
  if (element.includes('수')) return ['관찰', '정보', '흐름'];
  return ['관찰', '정리', '균형'];
}

function risky(value: string): boolean {
  return /충|형|파|해|원진|공망|흉/.test(value);
}

function dayNote(day: CalendarDay): string {
  const element = text(day.ohaeng, '오행 미상');
  const base = elementKeywords(element).slice(0, 2).join(', ');
  if (risky(`${day.gilhyung ?? ''} ${day.taekil ?? ''}`)) return `${base} 중심, 판단은 한 번 더 점검`;
  return `${base} 흐름을 가볍게 활용`;
}

export function createWeeklyFortune(source: {
  dates: KstDateParts[];
  calendarDays: McpToolResult[];
  palja: McpToolResult;
  reading: McpToolResult;
}): WeeklyFortune {
  const palja = paljaFrom(source.palja);
  const reading = readingFrom(source.reading);
  const personal = personalDay(palja);
  const days = source.calendarDays.map(dayFrom);
  const timeline = days.map((day, index) => ({
    label: source.dates[index].label,
    ganji: text(day.dayGanJi, `${day.dayGan ?? ''}${day.dayJi ?? ''}` || '-'),
    element: text(day.ohaeng, '-'),
    note: dayNote(day),
  }));
  const goodDays = timeline
    .filter((_, index) => !risky(`${days[index].gilhyung ?? ''} ${days[index].taekil ?? ''}`))
    .slice(0, 3)
    .map((item) => ({ label: item.label, ganji: item.ganji, reason: `${item.element} 기운과 ${item.note}` }));
  const cautionDays = timeline
    .filter((_, index) => risky(`${days[index].gilhyung ?? ''} ${days[index].taekil ?? ''}`))
    .slice(0, 3)
    .map((item) => ({ label: item.label, ganji: item.ganji, reason: '충돌/주의 신호가 있어 확인 후 움직이기' }));
  const keywords = unique(days.flatMap((day) => elementKeywords(text(day.ohaeng, '')))).slice(0, 6);
  const mode = cautionDays.length >= 3 ? '정리형 주간' : goodDays.length >= 4 ? '확장형 주간' : '균형형 주간';
  return {
    mode,
    rangeLabel: `${source.dates[0].label} - ${source.dates[source.dates.length - 1].label}`,
    summary: `내 일주 ${personal} 기준으로 이번 주는 ${keywords.slice(0, 3).join(', ')} 흐름을 중심으로 봅니다. ${collectStrings(reading, 2).join(' ')}`,
    keywords,
    goodDays,
    cautionDays: cautionDays.length > 0 ? cautionDays : [{ label: '전체', ganji: '-', reason: '특정 위험일보다 일정 과밀을 주의' }],
    timeline,
    evidence: ['calendar_day_info 7회', 'saju_palja 1회', 'saju_full_reading compact 1회', `개인 일주 ${personal}`],
  };
}

export function createMonthlyFortune(source: {
  year: number;
  month: number;
  calendarMonth: McpToolResult;
  palja: McpToolResult;
  reading: McpToolResult;
}): MonthlyFortune {
  const monthRoot = structured(source.calendarMonth, 'calendar_month');
  const days = Array.isArray(monthRoot.days) ? (monthRoot.days as CompactMonthDay[]) : [];
  const palja = paljaFrom(source.palja);
  const reading = readingFrom(source.reading);
  const goodDays = days
    .filter((day) => !risky(text(day.gilhyung, '')))
    .slice(0, 5)
    .map((day) => ({ date: text(day.solarDate), ganji: text(day.dayGanJi), reason: '월간 흐름에서 부담이 적은 관찰 후보일' }));
  const cautionDays = days
    .filter((day) => risky(text(day.gilhyung, '')))
    .slice(0, 5)
    .map((day) => ({ date: text(day.solarDate), ganji: text(day.dayGanJi), reason: '일정과 판단을 보수적으로 둘 날' }));
  const keywords = unique([...collectStrings(reading, 4), '월간 점검', '흐름 관리']).slice(0, 6);
  return {
    mode: cautionDays.length >= 8 ? '방어적 월간' : '균형형 월간',
    monthLabel: `${source.year}년 ${source.month}월`,
    summary: `내 일주 ${personalDay(palja)} 기준으로 ${source.month}월은 ${text(monthRoot.monthGanJi, '월간')} 흐름을 보며 좋은 날과 주의 날을 나눠 보는 구성이 적합합니다.`,
    monthGanji: text(monthRoot.monthGanJi, '-'),
    keywords,
    goodDays,
    cautionDays: cautionDays.length > 0 ? cautionDays : [{ date: '전체', ganji: '-', reason: '특정 위험일보다 누적 피로를 점검' }],
    turningPoints: days.filter((day) => text(day.gilhyung, '').includes('절')).map((day) => text(day.solarDate)).slice(0, 3),
    evidence: ['calendar_month compact=true', 'saju_palja 1회', 'saju_full_reading compact 1회'],
  };
}

export function createTojeongFortune(result: McpToolResult): TojeongFortune {
  const root = structured(result, 'tojeong_yearly');
  const data = asRecord(root.result, 'tojeong.result');
  const gwae = asRecord(data.gwae, 'tojeong.gwae');
  const interpretation = asRecord(data.interpretation, 'tojeong.interpretation');
  const monthly = Array.isArray(interpretation.monthly)
    ? interpretation.monthly.filter((item): item is string => typeof item === 'string')
    : [];
  const title = text(interpretation.title, '토정비결');
  const overall = text(interpretation.overall, '연간 해석이 없습니다.');
  return {
    targetYear: typeof root.targetYear === 'number' ? root.targetYear : new Date().getFullYear(),
    title,
    gwae: `${text(gwae.gwaeCode)} / ${String(gwae.gwaeNumber ?? '-')}`,
    overall,
    monthly,
    keywords: unique([title, ...collectStrings(overall, 4)]).slice(0, 5),
    evidence: ['tojeong_yearly 1회', `음력 생일 ${JSON.stringify(root.lunarBirth)}`],
  };
}

export function createDeepCycleFortune(source: {
  birth: BirthInput;
  fullReading: McpToolResult;
  daeun: McpToolResult;
  mode: string;
}): DeepCycleFortune {
  const full = structured(source.fullReading, 'saju_full_reading');
  const reading = asRecord(full.reading, 'saju_full_reading.reading');
  const daeunRoot = structured(source.daeun, 'saju_daeun');
  const daeun = Array.isArray(daeunRoot.daeun) ? daeunRoot.daeun.map((item) => asRecord(item, 'daeun.item')) : [];
  const current = daeun.find((item) => item.isCurrent === true) ?? daeun[0];
  const seun = asRecord(reading.seun ?? {}, 'reading.seun');
  const wolun = asRecord(reading.wolun ?? {}, 'reading.wolun');
  const yongsin = asRecord(reading.yongsin ?? {}, 'reading.yongsin');
  const gyeokguk = asRecord(reading.gyeokguk ?? {}, 'reading.gyeokguk');
  const relationText = collectStrings(reading.jijiRelations ?? reading.wonjin ?? reading.sinsal, 4);
  const currentDaeun = current
    ? `${String(current.age ?? '?')}세 ${text(current.gan)}${text(current.ji)}${current.isCurrent ? ' 현재' : ''}`
    : '대운 정보 없음';
  return {
    mode: `깊이 분석 ${source.mode}`,
    summary: `${source.birth.year}년생 기준 현재 대운과 세운/월운을 함께 봅니다. 판단보다 흐름의 강약과 반복 신호를 확인하는 화면입니다.`,
    currentDaeun,
    seun: `${text(seun.gan)}${text(seun.ji)}`,
    wolun: `${text(wolun.gan)}${text(wolun.ji)}`,
    yongsin: `${text(yongsin.yongsin)} / 기신 ${text(yongsin.gisin)} / ${text(yongsin.reasoning, '근거 없음')}`,
    gyeokguk: `${text(gyeokguk.name)} ${text(gyeokguk.description, '')}`,
    cautions: relationText.length > 0 ? relationText : ['대형 결정 전 기록과 확인을 먼저 두기'],
    evidence: ['saju_daeun 1회', 'saju_full_reading 1회', `include ${Array.isArray(full.sections) ? full.sections.join(', ') : '-'}`],
  };
}
