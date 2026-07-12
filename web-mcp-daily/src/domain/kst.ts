export interface KstDateParts {
  year: number;
  month: number;
  day: number;
  isoDate: string;
  label: string;
}

const KST_FORMATTER = new Intl.DateTimeFormat('en-CA', {
  timeZone: 'Asia/Seoul',
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
});

function partValue(parts: Intl.DateTimeFormatPart[], type: Intl.DateTimeFormatPartTypes): string {
  const value = parts.find((part) => part.type === type)?.value;
  if (!value) throw new Error(`KST 날짜 파트가 없습니다: ${type}`);
  return value;
}

export function kstToday(now = new Date()): KstDateParts {
  const parts = KST_FORMATTER.formatToParts(now);
  const year = Number(partValue(parts, 'year'));
  const month = Number(partValue(parts, 'month'));
  const day = Number(partValue(parts, 'day'));
  const isoDate = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  return { year, month, day, isoDate, label: `${year}년 ${month}월 ${day}일` };
}

export function kstDateFromParts(year: number, month: number, day: number): KstDateParts {
  const isoDate = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  return { year, month, day, isoDate, label: `${year}년 ${month}월 ${day}일` };
}

export function addKstDays(base: KstDateParts, offsetDays: number): KstDateParts {
  const date = new Date(Date.UTC(base.year, base.month - 1, base.day + offsetDays, 12, 0, 0));
  return kstDateFromParts(date.getUTCFullYear(), date.getUTCMonth() + 1, date.getUTCDate());
}
