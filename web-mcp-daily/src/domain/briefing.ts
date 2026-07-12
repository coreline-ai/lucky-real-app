import type { McpTrace, McpToolResult } from '../mcp/client';
import type { KstDateParts } from './kst';

export interface BirthInput {
  year: number;
  month: number;
  day: number;
  hour: number | null;
  minute: number | null;
  gender: 'male' | 'female';
  calendarType: 'solar';
  isLeapMonth: false;
  midnightMode: 'yaja';
  trueSolarTime: false;
  birthPlace: null;
}

export interface DailyBriefing {
  mode: '안정형' | '확장형' | '관찰형' | '정리형';
  modeLine: string;
  dateLabel: string;
  todayGanji: string;
  todayElement: string;
  personalDayPillar: string;
  energyKeywords: string[];
  cautionKeywords: string[];
  flow: string;
  actions: string[];
  evidence: string[];
  meta: {
    engineVersion?: string;
    ruleVersion?: string;
    sections: string[];
    birthTimeKnown?: boolean;
  };
}

export interface DailyBriefingSource {
  today: KstDateParts;
  calendar: McpToolResult;
  palja: McpToolResult;
  reading: McpToolResult;
  traces: McpTrace[];
}

interface CalendarDay {
  dayGan?: string;
  dayJi?: string;
  dayGanJi?: string;
  ohaeng?: string;
  sinsal12?: string;
  gilhyung?: string;
  taekil?: string;
  jieqi?: string;
}

interface Palja {
  yearGan?: string;
  yearJi?: string;
  monthGan?: string;
  monthJi?: string;
  dayGan?: string;
  dayJi?: string;
  hourGan?: string;
  hourJi?: string;
}

function asRecord(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    throw new Error(`${label} structuredContent가 올바르지 않습니다.`);
  }
  return value as Record<string, unknown>;
}

function optionalString(value: unknown): string | undefined {
  return typeof value === 'string' && value.trim() ? value.trim() : undefined;
}

function stringValue(value: unknown, fallback: string): string {
  return optionalString(value) ?? fallback;
}

function unique(values: string[]): string[] {
  return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
}

function collectStrings(value: unknown, limit = 18): string[] {
  const out: string[] = [];
  const visit = (input: unknown): void => {
    if (out.length >= limit) return;
    if (typeof input === 'string') {
      const normalized = input.trim();
      if (normalized) out.push(normalized);
      return;
    }
    if (Array.isArray(input)) {
      for (const item of input) visit(item);
      return;
    }
    if (typeof input === 'object' && input !== null) {
      for (const item of Object.values(input as Record<string, unknown>)) visit(item);
    }
  };
  visit(value);
  return unique(out).slice(0, limit);
}

function getStructured(result: McpToolResult, label: string): Record<string, unknown> {
  if (result.isError) {
    const text = result.content?.find((item) => item.type === 'text')?.text;
    throw new Error(text || `${label} tool이 오류를 반환했습니다.`);
  }
  if (!result.structuredContent) {
    throw new Error(`${label} 응답에 structuredContent가 없습니다.`);
  }
  return result.structuredContent;
}

function elementKeywords(element: string): string[] {
  if (element.includes('목')) return ['성장', '시작', '정리된 확장'];
  if (element.includes('화')) return ['표현', '소통', '가벼운 실행'];
  if (element.includes('토')) return ['균형', '점검', '기반 다지기'];
  if (element.includes('금')) return ['정돈', '판단', '기준 세우기'];
  if (element.includes('수')) return ['관찰', '정보', '흐름 읽기'];
  return ['관찰', '정리', '균형'];
}

function cautionKeywords(element: string, day: CalendarDay, readingStrings: string[]): string[] {
  const text = `${day.gilhyung ?? ''} ${day.taekil ?? ''} ${readingStrings.join(' ')}`;
  const cautions: string[] = [];
  if (/충|형|파|해|원진|공망|흉/.test(text)) cautions.push('성급한 판단 보류');
  if (element.includes('화')) cautions.push('말의 속도 조절');
  if (element.includes('수')) cautions.push('정보 과몰입 주의');
  if (element.includes('금')) cautions.push('기준을 너무 좁히지 않기');
  if (element.includes('목')) cautions.push('시작 전 범위 확인');
  if (element.includes('토')) cautions.push('미루던 일 쌓지 않기');
  return unique(cautions).slice(0, 4);
}

function chooseMode(element: string, day: CalendarDay, readingStrings: string[]): DailyBriefing['mode'] {
  const text = `${day.gilhyung ?? ''} ${day.taekil ?? ''} ${readingStrings.join(' ')}`;
  if (/충|형|파|해|원진|공망|흉/.test(text)) return '정리형';
  if (element.includes('수')) return '관찰형';
  if (element.includes('목') || element.includes('화')) return '확장형';
  if (element.includes('금')) return '정리형';
  return '안정형';
}

function modeLine(mode: DailyBriefing['mode'], dayGanji: string, element: string): string {
  const common = `오늘 일진 ${dayGanji}의 ${element || '기운'} 흐름을 기준으로 정리했습니다.`;
  if (mode === '확장형') return `${common} 작게 시작하고 반응을 보며 넓히기 좋은 날입니다.`;
  if (mode === '관찰형') return `${common} 바로 결정하기보다 정보와 감정의 흐름을 먼저 보는 쪽이 어울립니다.`;
  if (mode === '정리형') return `${common} 새 판단보다 기준 정리와 리스크 점검에 힘을 주기 좋습니다.`;
  return `${common} 속도를 높이기보다 균형을 맞추며 안정적으로 움직이기 좋습니다.`;
}

function actionLines(mode: DailyBriefing['mode'], keywords: string[]): string[] {
  const first = keywords[0] ?? '관찰';
  if (mode === '확장형') {
    return [
      `${first} 키워드와 맞는 일을 작은 단위로 먼저 실행해 보세요.`,
      '새 약속이나 연락은 한 번에 크게 벌리기보다 반응을 확인하며 조절하세요.',
      '중요한 결정은 기록을 남기고 오후에 한 번 더 점검하세요.',
    ];
  }
  if (mode === '관찰형') {
    return [
      `${first}에 맞춰 들어오는 정보의 출처와 맥락을 먼저 확인하세요.`,
      '답을 바로 내기보다 체크리스트를 채우듯 사실을 모아 보세요.',
      '감정적으로 끌리는 선택은 잠깐 거리를 두고 다시 보세요.',
    ];
  }
  if (mode === '정리형') {
    return [
      `${first}을 기준으로 미뤄둔 판단과 할 일을 정돈하세요.`,
      '새로운 일을 늘리기보다 이미 벌어진 일을 줄이고 마감선을 정하세요.',
      '민감한 대화는 결론보다 확인 질문을 먼저 두세요.',
    ];
  }
  return [
    `${first} 흐름을 살려 루틴과 약속을 안정적으로 맞춰 보세요.`,
    '무리해서 방향을 바꾸기보다 이미 잡은 기준을 지키는 쪽이 좋습니다.',
    '오늘의 판단은 작은 확인을 거친 뒤 실행하세요.',
  ];
}

export function createBriefing(source: DailyBriefingSource): DailyBriefing {
  const calendar = getStructured(source.calendar, 'calendar_day_info');
  const paljaRoot = getStructured(source.palja, 'saju_palja');
  const readingRoot = getStructured(source.reading, 'saju_full_reading');
  const day = asRecord(calendar.day, 'calendar_day_info.day') as CalendarDay;
  const palja = asRecord(paljaRoot.palja, 'saju_palja.palja') as Palja;
  const reading = asRecord(readingRoot.reading, 'saju_full_reading.reading');
  const readingStrings = collectStrings(reading);
  const meta = asRecord(calendar.meta, 'calendar_day_info.meta');
  const sections = Array.isArray(readingRoot.sections)
    ? readingRoot.sections.filter((value): value is string => typeof value === 'string')
    : [];
  const dayGanji = stringValue(day.dayGanJi, `${day.dayGan ?? ''}${day.dayJi ?? ''}` || '일진 미상');
  const element = stringValue(day.ohaeng, '오행 미상');
  const personalDay = `${stringValue(palja.dayGan, '?')}${stringValue(palja.dayJi, '?')}`;
  const keywords = unique([
    ...elementKeywords(element),
    ...collectStrings(day.sinsal12, 2),
    ...collectStrings(day.jieqi, 1),
  ]).slice(0, 5);
  const cautions = cautionKeywords(element, day, readingStrings);
  const mode = chooseMode(element, day, readingStrings);
  const evidence = unique([
    `${source.today.label} KST 기준`,
    `오늘 일진 ${dayGanji}, 오행 ${element}`,
    `개인 일주 ${personalDay}`,
    sections.length > 0 ? `include 섹션 ${sections.join(', ')}` : 'include 섹션 확인 안 됨',
    `MCP tool ${source.traces.filter((trace) => trace.toolName).map((trace) => trace.toolName).join(', ')}`,
  ]).slice(0, 5);

  return {
    mode,
    modeLine: modeLine(mode, dayGanji, element),
    dateLabel: source.today.label,
    todayGanji: dayGanji,
    todayElement: element,
    personalDayPillar: personalDay,
    energyKeywords: keywords,
    cautionKeywords: cautions.length > 0 ? cautions : ['무리한 확정 판단 피하기'],
    flow: `내 일주 ${personalDay} 위에 오늘 ${dayGanji} 흐름이 들어옵니다. ${keywords.slice(0, 2).join(', ')}를 중심으로 하루의 우선순위를 가볍게 정리해 보세요.`,
    actions: actionLines(mode, keywords),
    evidence,
    meta: {
      engineVersion: optionalString(meta.engineVersion),
      ruleVersion: optionalString(meta.ruleVersion),
      sections,
      birthTimeKnown: typeof readingRoot.birthTimeKnown === 'boolean' ? readingRoot.birthTimeKnown : undefined,
    },
  };
}
