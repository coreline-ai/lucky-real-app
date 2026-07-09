// 표시용 한 줄 요약(content 텍스트) 전용. 계산값을 가공하지 않는다(계산·문구 분리 원칙).
import type {
  CalendarDay,
  KoreanLegalTimeResolution,
  MonthlyCalendar,
  Palja,
  SolarTermInfo,
} from 'manseryeok-engine';

export function summarizeCalendarDay(day: CalendarDay): string {
  const leap = day.isLeapMonth ? '윤' : '';
  const jieqi = day.jieqi ? ` · 절기 ${day.jieqi}` : '';
  return `${day.solarDate}(음 ${leap}${day.lunarMonth}.${day.lunarDay}) ${day.dayGanJi}일 · ${day.ohaeng} · ${day.sinsal12} · ${day.gilhyung}${jieqi}`;
}

export function summarizeCalendarMonth(calendar: MonthlyCalendar, compact: boolean): string {
  const mode = compact ? ' · compact' : '';
  return `${calendar.year}년 ${calendar.month}월(${calendar.monthGanJi}월) · ${calendar.days.length}일${mode}`;
}

export function summarizeDateConvert(
  direction: 'solar_to_lunar' | 'lunar_to_solar',
  input: { year: number; month: number; day: number; isLeapMonth?: boolean },
  result: { year: number; month: number; day: number; isLeapMonth?: boolean },
): string {
  const fmt = (d: { year: number; month: number; day: number; isLeapMonth?: boolean }) =>
    `${d.year}-${d.month}-${d.day}${d.isLeapMonth ? '(윤달)' : ''}`;
  return direction === 'solar_to_lunar'
    ? `양력 ${fmt(input)} → 음력 ${fmt(result)}`
    : `음력 ${fmt(input)} → 양력 ${fmt(result)}`;
}

export function summarizeSolarTerms(
  query: { year: number; month?: number; day?: number },
  terms: SolarTermInfo[],
): string {
  if (query.month !== undefined && query.day !== undefined) {
    const names = terms.map((t) => t.koreanName).join(', ');
    return terms.length > 0
      ? `${query.year}-${query.month}-${query.day} 절기: ${names}`
      : `${query.year}-${query.month}-${query.day}에는 절기가 없습니다`;
  }
  const first = terms[0]?.koreanName ?? '';
  const last = terms[terms.length - 1]?.koreanName ?? '';
  return `${query.year}년 절기 ${terms.length}개 (${first} ~ ${last})`;
}

export function summarizeLegalTime(
  input: { year: number; month: number; day: number; hour: number; minute: number },
  resolution: KoreanLegalTimeResolution,
): string {
  const hours = resolution.totalOffsetMinutes / 60;
  const dst = resolution.daylightOffsetMinutes > 0 ? ` (DST +${resolution.daylightOffsetMinutes}분)` : '';
  return `${input.year}-${input.month}-${input.day} ${input.hour}:${String(input.minute).padStart(2, '0')} KST 법정시: UTC+${hours}h${dst} · ${resolution.transitionStatus}`;
}

// --- B·C그룹: 사주·궁합 ---

export function summarizePalja(palja: Palja, birthTimeKnown: boolean): string {
  const hour = birthTimeKnown && palja.hourGan !== '' ? `${palja.hourGan}${palja.hourJi}시` : '시주 미상';
  return `${palja.yearGan}${palja.yearJi}년 ${palja.monthGan}${palja.monthJi}월 ${palja.dayGan}${palja.dayJi}일 ${hour} · 일간 ${palja.dayGan}`;
}

export function summarizeSajuReading(
  palja: Palja,
  birthTimeKnown: boolean,
  gyeokguk?: { name: string },
  yongsin?: { yongsin: string; ohaeng: string },
): string {
  const parts = [summarizePalja(palja, birthTimeKnown)];
  if (gyeokguk) parts.push(`격국 ${gyeokguk.name}`);
  if (yongsin) parts.push(`용신 ${yongsin.yongsin}(${yongsin.ohaeng})`);
  return parts.join(' · ');
}

export function summarizeDaeun(daeun: Array<{ age: number; gan: string; ji: string; isCurrent: boolean }>): string {
  if (daeun.length === 0) return '대운 0개';
  const first = daeun[0];
  const current = daeun.find((d) => d.isCurrent);
  const currentText = current ? ` · 현재 ${current.age}세 ${current.gan}${current.ji} 대운` : '';
  return `대운 ${daeun.length}개 · ${first.age}세 ${first.gan}${first.ji} 시작${currentText}`;
}

export function summarizeCompatibility(
  totalScore: number,
  grade: string,
  dayGanType: string,
  dayJiType: string,
): string {
  return `${totalScore}점 ${grade}등급 · 일간 ${dayGanType} · 일지 ${dayJiType}`;
}

// --- D~G그룹: 역술 확장 ---

const HOUR_UNKNOWN_SUFFIX = ' · 시주 미상(3주) 기준';

export function summarizeTojeong(
  lunarBirth: { year: number; month: number; day: number },
  targetYear: number,
  gwae: { gwaeNumber: number; gwaeCode: string },
  title: string,
): string {
  return `토정비결 ${targetYear}년 (음력 ${lunarBirth.year}-${lunarBirth.month}-${lunarBirth.day}생): ${gwae.gwaeNumber}괘(${gwae.gwaeCode}) · ${title}`;
}

export function summarizeZiwei(
  chart: { fiveElementsClass: string; soulPalaceBranch: string; bodyPalaceBranch: string },
  school?: string,
): string {
  const schoolText = school ? ` · ${school} 분석 포함` : '';
  return `자미두수 명반: ${chart.fiveElementsClass} · 명궁 ${chart.soulPalaceBranch} · 신궁 ${chart.bodyPalaceBranch}${schoolText}`;
}

export function summarizeQimen(
  chart: { solarDate: string; dunType: string; bureauNumber: number; solarTerm: string; yuan: string },
  hour: number,
  school?: string,
): string {
  const schoolText = school ? ` · ${school} 분석 포함` : '';
  return `기문둔갑 ${chart.solarDate} ${hour}시: ${chart.dunType} ${chart.bureauNumber}국 (${chart.solarTerm} ${chart.yuan})${schoolText}`;
}

export function summarizeDaeyukim(chart: { solarDate: string; gwaMyeong: string; wolJang: string }, hour: number): string {
  return `대육임 ${chart.solarDate} ${hour}시: ${chart.gwaMyeong} · 월장 ${chart.wolJang}`;
}

export function summarizeGuseong(
  bonmyeongseong: { name: string; number: number },
  target: { year: number; month: number; day: number },
): string {
  return `구성기학: 본명성 ${bonmyeongseong.name}(${bonmyeongseong.number}) · 기준일 ${target.year}-${target.month}-${target.day}`;
}

export function summarizeHarak(result: { hexagramNumber: number; hexagramName: string; hadosu: number; nakseosu: number }): string {
  return `하락이수: ${result.hexagramNumber}괘 ${result.hexagramName} (하도수 ${result.hadosu} · 낙서수 ${result.nakseosu})`;
}

export function summarizeDaejeongReading(
  result: { hexagramNumber: number; hexagramName: string; changingLine: number },
  hourKnown: boolean,
): string {
  return `대정수: ${result.hexagramNumber}괘 ${result.hexagramName} · 변효 ${result.changingLine}${hourKnown ? '' : HOUR_UNKNOWN_SUFFIX}`;
}

export function summarizeHongyeonReading(
  result: { hongguksu: number; bonmyeongseong: string; bonmyeongOhaeng: string },
  hourKnown: boolean,
): string {
  return `홍연: 홍국수 ${result.hongguksu} · 본명성 ${result.bonmyeongseong}(${result.bonmyeongOhaeng})${hourKnown ? '' : HOUR_UNKNOWN_SUFFIX}`;
}

export function summarizeMaehwa(
  method: string,
  result: { hexagramName: string; changingLine: number; cheYongRelation: string },
): string {
  return `매화역수(${method}): ${result.hexagramName} · 변효 ${result.changingLine} · 체용 ${result.cheYongRelation}`;
}

export function summarizeNaming(
  surname: string,
  school: string,
  candidates: Array<{ name: string; totalScore: number }>,
): string {
  const best = candidates.reduce((a, b) => (b.totalScore > a.totalScore ? b : a));
  return `작명 분석(${school}): ${surname}씨 후보 ${candidates.length}개 · 최고 ${surname}${best.name} ${best.totalScore}점`;
}

export function summarizeGanjiInfo(
  items: Array<{ hanja: string; korean: string | null; ohaeng: string | null }>,
): string {
  return items
    .map((item) => `${item.hanja}(${item.korean ?? '?'}·${item.ohaeng ?? '?'})`)
    .join(' ');
}
