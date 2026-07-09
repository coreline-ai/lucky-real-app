// 오류 계약 (dev-plan "공용 스키마 사양"):
// - 오류는 `isError: true` + content(JSON 텍스트 { code, message, details? })로 반환한다.
// - structuredContent는 성공 응답 전용 (D10 — outputSchema와의 충돌 방지).
// - ManseryeokError 5종 코드는 그대로 전달하고, zod 실패는 INVALID_INPUT으로 매핑한다.
import type { CallToolResult } from '@modelcontextprotocol/sdk/types.js';
import { ManseryeokError } from 'manseryeok-engine';
import { ZodError } from 'zod';

/** 엔진이 정의한 공식 오류 코드 5종 (engine/src/engine/core/errors.ts) */
const MANSERYEOK_CODES: ReadonlySet<string> = new Set([
  'MANSERYEOK_RANGE_ERROR',
  'MANSERYEOK_DATA_ERROR',
  'AMBIGUOUS_CIVIL_TIME',
  'NONEXISTENT_CIVIL_TIME',
  'MANSERYEOK_POLICY_ERROR',
]);

/**
 * P1·P2 실측(이슈 기록): 엔진 core는 데이터 테이블(음양력·절기) 조회 실패 시
 * code 없는 plain Error를 던진다. 전부 데이터 조회 실패 의미론이므로
 * MANSERYEOK_DATA_ERROR로 정규화해 오류 계약을 유지한다.
 * - lunar-solar.ts:56,76  "Unsupported solar|lunar date: ..."
 * - ganji.ts:174,211      "No 입춘 data for ..." / "No major solar term found for ..."
 * - solar-terms.ts:206,229,248  "No (jeol )solar term found for ..."
 * - manseryeok-engine.ts:303    "No target jeol found for ..."
 */
const DATA_LOOKUP_ERROR_PATTERNS: readonly RegExp[] = [
  /^Unsupported (solar|lunar) date: /,
  /^No 입춘 data for /,
  /^No (major |jeol )?solar term found for /,
  /^No target jeol found for /,
];

export interface ToolErrorPayload {
  code: string;
  message: string;
  details?: unknown;
}

function isManseryeokError(error: unknown): error is ManseryeokError {
  if (error instanceof ManseryeokError) return true;
  // 모듈 이중 로드 등으로 instanceof가 깨질 때의 덕타이핑 폴백
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    MANSERYEOK_CODES.has(String((error as { code: unknown }).code))
  );
}

export function normalizeError(error: unknown): ToolErrorPayload {
  if (isManseryeokError(error)) {
    return { code: error.code, message: error.message, details: error.details };
  }
  if (error instanceof ZodError) {
    return { code: 'INVALID_INPUT', message: '입력값 검증에 실패했습니다.', details: error.issues };
  }
  if (error instanceof Error && DATA_LOOKUP_ERROR_PATTERNS.some((pattern) => pattern.test(error.message))) {
    return {
      code: 'MANSERYEOK_DATA_ERROR',
      message: error.message,
      details: { normalizedFrom: 'plain-error' },
    };
  }
  return {
    code: 'INTERNAL_ERROR',
    message: error instanceof Error ? error.message : String(error),
  };
}

export function toErrorResult(error: unknown): CallToolResult {
  return errorResult(normalizeError(error));
}

/** 핸들러 내부 교차 필드 검증 등에서 직접 반환하는 INVALID_INPUT */
export function invalidInput(message: string, details?: unknown): CallToolResult {
  return errorResult({ code: 'INVALID_INPUT', message, ...(details !== undefined ? { details } : {}) });
}

function errorResult(payload: ToolErrorPayload): CallToolResult {
  return {
    isError: true,
    content: [{ type: 'text', text: JSON.stringify(payload) }],
  };
}

/** 툴 핸들러 공용 래퍼: throw를 오류 계약 응답으로 변환한다. */
export function withErrorMapping<Args extends unknown[]>(
  handler: (...args: Args) => Promise<CallToolResult> | CallToolResult,
): (...args: Args) => Promise<CallToolResult> {
  return async (...args: Args): Promise<CallToolResult> => {
    try {
      return await handler(...args);
    } catch (error) {
      return toErrorResult(error);
    }
  };
}
