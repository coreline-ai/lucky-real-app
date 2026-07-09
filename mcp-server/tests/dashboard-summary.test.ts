import { describe, expect, it } from 'vitest';
import { clipText, formatResultSummary } from '../src/dashboard/summary.js';

describe('formatResultSummary', () => {
  it('formats OK with text and ms', () => {
    const line = formatResultSummary(
      {
        structuredContent: { meta: { engineVersion: '0.1.0' }, day: {} },
        content: [{ type: 'text', text: '2026-07-09 갑신일 · 목' }],
      },
      38,
    );
    expect(line.startsWith('OK · 38ms')).toBe(true);
    expect(line).toContain('갑신');
  });

  it('flags missing structuredContent as FAIL', () => {
    const line = formatResultSummary(
      { content: [{ type: 'text', text: 'hello' }] },
      10,
    );
    expect(line.startsWith('FAIL')).toBe(true);
    expect(line).toContain('structuredContent missing');
  });

  it('clips long text', () => {
    expect(clipText('a'.repeat(50), 10).endsWith('…')).toBe(true);
    expect(clipText('short', 10)).toBe('short');
  });
});
