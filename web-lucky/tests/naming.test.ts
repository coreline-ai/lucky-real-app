import { describe, expect, it } from 'vitest';
import { parseGivenNameCandidates, runNaming } from '../src/domain/naming';

describe('naming domain (real engine)', () => {
  it('parses candidates and returns two scored rows for 김 + 민준,서연', () => {
    const names = parseGivenNameCandidates('민준, 서연');
    expect(names).toEqual(['민준', '서연']);
    const out = runNaming('김', names);
    expect(out.ok).toBe(true);
    if (!out.ok) return;
    expect(out.candidates).toHaveLength(2);
    for (const c of out.candidates) {
      expect(typeof c.totalScore).toBe('number');
      expect(Number.isFinite(c.totalScore)).toBe(true);
    }
    // Sorted desc by score
    expect(out.candidates[0].totalScore).toBeGreaterThanOrEqual(
      out.candidates[1].totalScore,
    );
  });

  it('rejects empty candidates', () => {
    const out = runNaming('김', []);
    expect(out.ok).toBe(false);
  });

  it('rejects non-Hangul surname and candidate text', () => {
    expect(runNaming('<', ['민준']).ok).toBe(false);
    expect(runNaming('김', ['a>']).ok).toBe(false);
  });
});
