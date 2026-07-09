import type { TojeongResult } from 'manseryeok-engine';

/**
 * Clipboard share line: year + hexagram + overall excerpt only.
 * Never include solar/lunar birth numbers.
 */
export function buildShareText(input: {
  targetYear: number;
  result: TojeongResult;
}): string {
  const n = input.result.gwae.gwaeNumber;
  const title = input.result.interpretation.title.replace(/^제\d+괘\s*/, '').trim();
  const shortTitle = title.length > 24 ? `${title.slice(0, 24)}…` : title;
  const overall = input.result.interpretation.overall.trim();
  const overallShort =
    overall.length > 40 ? `${overall.slice(0, 40)}…` : overall;
  return `나는 ${input.targetYear} 토정 제${n}괘 「${shortTitle}」 — ${overallShort} (오락용)`;
}

/** True if text looks like it embeds a birth-like triple or ISO date (guard for tests/UI). */
export function shareTextLooksSafe(text: string): boolean {
  if (/\d{4}-\d{2}-\d{2}/.test(text)) return false;
  // Reject patterns like "1990년 3월 15일" or "음력 1990-2-19"
  if (/음력\s*\d{4}/.test(text)) return false;
  if (/\d{4}\s*년\s*\d{1,2}\s*월\s*\d{1,2}\s*일/.test(text)) return false;
  return true;
}
