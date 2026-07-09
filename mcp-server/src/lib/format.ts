// 날짜 문자열 조립 단일화 (D13) — 엔진 입력 포맷이 모듈별로 다르다:
// - ziwei: "YYYY-M-D" (제로패딩 없음)
// - qimen/daeyukim: "YYYY-MM-DD"
// KST '오늘' 계산도 여기서만 한다 (서버 프로세스 타임존 비의존, guseong 기본값용).

const KST_OFFSET_MS = 9 * 60 * 60 * 1000;

export function pad2(value: number): string {
  return String(value).padStart(2, '0');
}

/** "YYYY-MM-DD" — qimen/daeyukim 계열 입력 포맷 */
export function formatDateDashed(year: number, month: number, day: number): string {
  return `${year}-${pad2(month)}-${pad2(day)}`;
}

/** "YYYY-M-D" — ziwei 계열 입력 포맷 (제로패딩 없음) */
export function formatDateLoose(year: number, month: number, day: number): string {
  return `${year}-${month}-${day}`;
}

export interface KstDate {
  year: number;
  month: number;
  day: number;
}

/** KST(UTC+9) 기준 오늘 날짜. 프로세스 로컬 타임존에 의존하지 않는다. */
export function todayKst(now: Date = new Date()): KstDate {
  const kst = new Date(now.getTime() + KST_OFFSET_MS);
  return {
    year: kst.getUTCFullYear(),
    month: kst.getUTCMonth() + 1,
    day: kst.getUTCDate(),
  };
}
