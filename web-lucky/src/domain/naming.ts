import { Naming } from 'manseryeok-engine';
import type { NamingAnalysis } from 'manseryeok-engine';

export type NamingOk = {
  ok: true;
  surname: string;
  candidates: NamingAnalysis[];
  truncated: boolean;
};

export type NamingErr = { ok: false; message: string };

export type NamingOutcome = NamingOk | NamingErr;

/** Parse comma / newline separated given names; trim empties. */
export function parseGivenNameCandidates(raw: string): string[] {
  return raw
    .split(/[\n,，]/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

export function runNaming(
  surname: string,
  givenNames: string[],
): NamingOutcome {
  const s = surname.trim();
  if (!s || [...s].length !== 1) {
    return { ok: false, message: '성은 한글 한 글자로 입력해 주세요.' };
  }
  if (givenNames.length === 0) {
    return { ok: false, message: '이름 후보를 한 개 이상 입력해 주세요.' };
  }
  const truncated = givenNames.length > 6;
  const limited = givenNames.slice(0, 6);
  for (const g of limited) {
    const len = [...g].length;
    if (len < 1 || len > 2) {
      return {
        ok: false,
        message: `이름 「${g}」은(는) 1~2글자여야 합니다.`,
      };
    }
  }
  try {
    const result = Naming.analyzeNames(s, limited);
    const candidates = [...result.candidates].sort(
      (a, b) => b.totalScore - a.totalScore,
    );
    return { ok: true, surname: s, candidates, truncated };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return { ok: false, message: `이름 분석에 실패했습니다. (${msg})` };
  }
}
