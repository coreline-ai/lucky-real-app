/**
 * Human one-line summary for dashboard tool results (pure, unit-testable).
 * Prefer content text; fall back to structured keys. Never invent fortune copy.
 */
export function clipText(text: string, max: number): string {
  const s = String(text ?? '');
  if (s.length <= max) return s;
  return `${s.slice(0, Math.max(0, max - 1))}…`;
}

export type McpToolCallResultLike = {
  isError?: boolean;
  content?: Array<{ type?: string; text?: string }>;
  structuredContent?: Record<string, unknown> | null;
};

export function formatResultSummary(
  result: McpToolCallResultLike,
  ms: number | null,
): string {
  const timing = ms != null ? ` · ${ms}ms` : '';
  if (result.isError) {
    const text = result.content?.[0]?.text ?? 'MCP error';
    return `FAIL${timing} · ${clipText(text, 120)}`;
  }
  if (!result.structuredContent) {
    return `FAIL${timing} · structuredContent missing`;
  }
  const firstText = result.content?.[0]?.text?.trim() ?? '';
  if (firstText) {
    return `OK${timing} · ${clipText(firstText, 140)}`;
  }
  const keys = Object.keys(result.structuredContent).filter((k) => k !== 'meta');
  return `OK${timing} · keys: ${keys.slice(0, 6).join(', ') || '(meta only)'}`;
}

export function formatRawDebug(result: McpToolCallResultLike): string {
  const structured = result.structuredContent || {};
  const keys = Object.keys(structured).filter((key) => key !== 'meta');
  const meta = (structured as { meta?: unknown }).meta ?? {};
  const firstText =
    result.content && result.content[0] && result.content[0].text
      ? result.content[0].text
      : '';
  return JSON.stringify(
    { keys, meta, text: clipText(firstText, 180) },
    null,
    2,
  );
}
