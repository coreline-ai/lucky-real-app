export interface CalendarDateParts {
  year: number;
  month: number;
  day: number;
}

const KST_FORMATTER = new Intl.DateTimeFormat('en-US', {
  timeZone: 'Asia/Seoul',
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
});

export function kstToday(now = new Date()): CalendarDateParts {
  const parts = KST_FORMATTER.formatToParts(now);
  const value = (type: 'year' | 'month' | 'day'): number => {
    const part = parts.find((item) => item.type === type)?.value;
    if (part === undefined) throw new Error(`KST 날짜 파싱 실패: ${type}`);
    return Number(part);
  };

  return {
    year: value('year'),
    month: value('month'),
    day: value('day'),
  };
}
