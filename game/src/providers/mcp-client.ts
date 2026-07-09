import { kstToday } from '../domain/kst';
import type { BirthFormInput, DayPillar, PillarReading, SajuProvider } from './types';
import { ProviderError } from './types';

const MCP_PROTOCOL_VERSION = '2025-11-25';
const DEFAULT_TIMEOUT_MS = 10_000;

interface JsonRpcSuccess<T> {
  jsonrpc: '2.0';
  id: number;
  result: T;
}

interface JsonRpcFailure {
  jsonrpc: '2.0';
  id: number | null;
  error: { code: number; message: string; data?: unknown };
}

type JsonRpcResponse<T> = JsonRpcSuccess<T> | JsonRpcFailure;

interface ToolResult {
  isError?: boolean;
  content?: Array<{ type: string; text?: string }>;
  structuredContent?: Record<string, unknown>;
}

interface ErrorPayload {
  code?: string;
  message?: string;
  details?: unknown;
}

const GAN_NORMALIZE: Record<string, string> = {
  甲: '甲', 乙: '乙', 丙: '丙', 丁: '丁', 戊: '戊', 己: '己', 庚: '庚', 辛: '辛', 壬: '壬', 癸: '癸',
  갑: '甲', 을: '乙', 병: '丙', 정: '丁', 무: '戊', 기: '己', 경: '庚', 신: '辛', 임: '壬', 계: '癸',
};

const JI_NORMALIZE: Record<string, string> = {
  子: '子', 丑: '丑', 寅: '寅', 卯: '卯', 辰: '辰', 巳: '巳', 午: '午', 未: '未', 申: '申', 酉: '酉', 戌: '戌', 亥: '亥',
  자: '子', 축: '丑', 인: '寅', 묘: '卯', 진: '辰', 사: '巳', 오: '午', 미: '未', 신: '申', 유: '酉', 술: '戌', 해: '亥',
};

function asRecord(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    throw new ProviderError(`${label} 응답 구조가 올바르지 않습니다.`, { code: 'MCP_BAD_SHAPE' });
  }
  return value as Record<string, unknown>;
}

function asString(value: unknown, label: string): string {
  if (typeof value !== 'string' || value.length === 0) {
    throw new ProviderError(`${label} 값이 응답에 없습니다.`, { code: 'MCP_BAD_SHAPE' });
  }
  return value;
}

function normalizeGan(value: string): string {
  return GAN_NORMALIZE[value] ?? value;
}

function normalizeJi(value: string): string {
  return JI_NORMALIZE[value] ?? value;
}

function dayPillarFromParts(gan: unknown, ji: unknown): DayPillar {
  const normalizedGan = normalizeGan(asString(gan, 'dayGan'));
  const normalizedJi = normalizeJi(asString(ji, 'dayJi'));
  return { gan: normalizedGan, ji: normalizedJi, ganji: `${normalizedGan}${normalizedJi}` };
}

function dayPillarFromGanji(value: unknown): DayPillar {
  const chars = Array.from(asString(value, 'dayGanJi').trim());
  if (chars.length < 2) {
    throw new ProviderError('dayGanJi는 천간+지지 2글자여야 합니다.', { code: 'MCP_BAD_GANJI' });
  }
  return dayPillarFromParts(chars[0], chars[1]);
}

function parseMcpErrorText(text: string | undefined): ErrorPayload {
  if (!text) return { code: 'MCP_ERROR', message: 'MCP 도구 호출이 실패했습니다.' };
  try {
    const parsed = JSON.parse(text) as ErrorPayload;
    return {
      code: typeof parsed.code === 'string' ? parsed.code : 'MCP_ERROR',
      message: typeof parsed.message === 'string' ? parsed.message : text,
      details: parsed.details,
    };
  } catch {
    return { code: text.includes('-32602') ? 'MCP_VALIDATION_ERROR' : 'MCP_ERROR', message: text };
  }
}

function metaFromStructured(structured: Record<string, unknown>, tool: 'saju_palja' | 'calendar_day_info') {
  const meta = asRecord(structured.meta, 'meta');
  return {
    source: 'mcp' as const,
    tool,
    engineVersion: typeof meta.engineVersion === 'string' ? meta.engineVersion : undefined,
    ruleVersion: typeof meta.ruleVersion === 'string' ? meta.ruleVersion : undefined,
  };
}

function assertToolSuccess(result: ToolResult, tool: 'saju_palja' | 'calendar_day_info'): Record<string, unknown> {
  if (result.isError) {
    const firstText = result.content?.find((item) => item.type === 'text')?.text;
    const payload = parseMcpErrorText(firstText);
    throw new ProviderError(payload.message ?? 'MCP 도구 호출이 실패했습니다.', {
      code: payload.code,
      source: 'mcp',
      details: payload.details,
    });
  }

  if (!result.structuredContent) {
    throw new ProviderError(`${tool} 응답에 structuredContent가 없습니다.`, { code: 'MCP_NO_STRUCTURED_CONTENT' });
  }

  return result.structuredContent;
}

export class McpClientProvider implements SajuProvider {
  private readonly baseUrl: string;
  private readonly timeoutMs: number;
  private nextId = 1;
  private initializePromise?: Promise<void>;

  constructor(options: { baseUrl?: string; timeoutMs?: number } = {}) {
    this.baseUrl = options.baseUrl ?? '/mcp';
    this.timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS;
  }

  async getPlayerDayPillar(input: BirthFormInput): Promise<PillarReading> {
    const result = await this.callTool('saju_palja', {
      birth: {
        year: input.year,
        month: input.month,
        day: input.day,
        hour: input.hour,
        minute: input.hour === null ? null : input.minute,
        gender: input.gender,
        calendarType: 'solar',
      },
    });
    const structured = assertToolSuccess(result, 'saju_palja');
    const palja = asRecord(structured.palja, 'palja');
    return { pillar: dayPillarFromParts(palja.dayGan, palja.dayJi), meta: metaFromStructured(structured, 'saju_palja') };
  }

  async getTodayIljin(): Promise<PillarReading> {
    const result = await this.callTool('calendar_day_info', { ...kstToday() });
    const structured = assertToolSuccess(result, 'calendar_day_info');
    const day = asRecord(structured.day, 'day');
    return { pillar: dayPillarFromGanji(day.dayGanJi), meta: metaFromStructured(structured, 'calendar_day_info') };
  }

  private async ensureInitialized(): Promise<void> {
    if (!this.initializePromise) {
      this.initializePromise = this.initialize().catch((error) => {
        this.initializePromise = undefined;
        throw error;
      });
    }
    return this.initializePromise;
  }

  private async initialize(): Promise<void> {
    await this.sendRequest('initialize', {
      protocolVersion: MCP_PROTOCOL_VERSION,
      capabilities: {},
      clientInfo: { name: 'manseryeok-game', version: '0.1.0' },
    }, false);
    await this.sendNotification('notifications/initialized');
  }

  private async callTool(name: 'saju_palja' | 'calendar_day_info', args: Record<string, unknown>): Promise<ToolResult> {
    await this.ensureInitialized();
    return this.sendRequest<ToolResult>('tools/call', { name, arguments: args }, true);
  }

  private async sendNotification(method: string, params: Record<string, unknown> = {}): Promise<void> {
    await this.fetchJson({ jsonrpc: '2.0', method, params });
  }

  private async sendRequest<T>(method: string, params: Record<string, unknown>, includeProtocolHeader: boolean): Promise<T> {
    const id = this.nextId++;
    const response = await this.fetchJson<JsonRpcResponse<T>>(
      { jsonrpc: '2.0', id, method, params },
      includeProtocolHeader,
    );

    if ('error' in response) {
      throw new ProviderError(response.error.message, {
        code: `JSONRPC_${response.error.code}`,
        source: 'mcp-http',
        details: response.error.data,
      });
    }

    return response.result;
  }

  private async fetchJson<T = unknown>(body: unknown, includeProtocolHeader = true): Promise<T> {
    const controller = new AbortController();
    const timeout = window.setTimeout(() => controller.abort(), this.timeoutMs);
    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        Accept: 'application/json, text/event-stream',
      };
      if (includeProtocolHeader) headers['MCP-Protocol-Version'] = MCP_PROTOCOL_VERSION;

      const response = await fetch(this.baseUrl, {
        method: 'POST',
        headers,
        body: JSON.stringify(body),
        signal: controller.signal,
      });
      const text = await response.text();

      if (!response.ok) {
        throw new ProviderError(text || `HTTP ${response.status}`, {
          code: `MCP_HTTP_${response.status}`,
          source: 'mcp-http',
        });
      }
      if (!text) return undefined as T;
      return JSON.parse(text) as T;
    } catch (error) {
      if (error instanceof ProviderError) throw error;
      if (error instanceof DOMException && error.name === 'AbortError') {
        throw new ProviderError('MCP 응답 시간이 초과되었습니다.', { code: 'MCP_TIMEOUT', source: 'mcp-http' });
      }
      throw new ProviderError(error instanceof Error ? error.message : String(error), { code: 'MCP_CLIENT_ERROR', source: 'mcp-http' });
    } finally {
      window.clearTimeout(timeout);
    }
  }
}
