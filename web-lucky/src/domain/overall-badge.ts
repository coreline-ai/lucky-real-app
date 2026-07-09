export type OverallTone = 'good' | 'mid' | 'caution' | 'neutral';

/** Loose heuristic only for badge color — never invent a new fortune grade. */
export function overallTone(overall: string): OverallTone {
  if (/상길|대길/.test(overall)) return 'good';
  if (/중길|평/.test(overall)) return 'mid';
  if (/흉|신중|주의/.test(overall)) return 'caution';
  return 'neutral';
}
