const MCP_PROTOCOL_VERSION = '2025-11-25';
const DEFAULT_TIMEOUT_MS = 12_000;

export type AuthMode = 'none' | 'x-token' | 'bearer';
export type McpErrorKind =
  | 'network'
  | 'timeout'
  | 'auth'
  | 'cors'
  | 'endpoint'
  | 'http'
  | 'protocol'
  | 'tool'
  | 'size'
  | 'server';

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

export interface McpToolResult {
  isError?: boolean;
  content?: Array<{ type: string; text?: string }>;
  structuredContent?: Record<string, unknown>;
}

export interface McpTrace {
  label: string;
  method: string;
  toolName?: string;
  status?: number;
  ok: boolean;
  bytes: number;
  durationMs: number;
  structuredContent: boolean;
  errorKind?: McpErrorKind;
  message?: string;
}

export interface McpClientOptions {
  endpoint: string;
  authMode: AuthMode;
  authToken?: string;
  timeoutMs?: number;
  clientName?: string;
}

export interface ToolCallResponse {
  result: McpToolResult;
  trace: McpTrace;
}

export class McpClientError extends Error {
  readonly kind: McpErrorKind;
  readonly status?: number;
  readonly trace?: McpTrace;
  readonly details?: unknown;

  constructor(message: string, options: { kind: McpErrorKind; status?: number; trace?: McpTrace; details?: unknown }) {
    super(message);
    this.name = 'McpClientError';
    this.kind = options.kind;
    this.status = options.status;
    this.trace = options.trace;
    this.details = options.details;
  }
}

function byteLength(text: string): number {
  return new TextEncoder().encode(text).length;
}

function classifyHttp(status: number, message: string): McpErrorKind {
  if (status === 401) return 'auth';
  if (status === 403) return 'cors';
  if (status === 404) return 'endpoint';
  if (status === 405) return 'protocol';
  if (status === 413 || message.toLowerCase().includes('too large')) return 'size';
  if (status >= 500) return 'server';
  return 'http';
}

function summarizeJsonRpcError(method: string, toolName: string | undefined, code: number): McpErrorKind {
  if (code === -32001) return 'auth';
  if (method === 'tools/call' || toolName) return 'tool';
  if (code === -32000 || code === -32602 || code === -32601 || code === -32600) return 'protocol';
  if (code === -32603) return 'server';
  return 'protocol';
}

export class McpClient {
  readonly endpoint: string;
  readonly authMode: AuthMode;
  private readonly authToken: string;
  private readonly timeoutMs: number;
  private readonly clientName: string;
  private nextId = 1;
  private initialized = false;
  private traces: McpTrace[] = [];

  constructor(options: McpClientOptions) {
    this.endpoint = options.endpoint || '/mcp';
    this.authMode = options.authMode;
    this.authToken = options.authToken?.trim() ?? '';
    this.timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS;
    this.clientName = options.clientName ?? 'web-mcp-daily';
  }

  getTraces(): McpTrace[] {
    return [...this.traces];
  }

  async initialize(): Promise<void> {
    if (this.initialized) return;
    await this.sendRequest(
      'initialize',
      {
        protocolVersion: MCP_PROTOCOL_VERSION,
        capabilities: {},
        clientInfo: { name: this.clientName, version: '0.1.0' },
      },
      { includeProtocolHeader: false, label: 'initialize' },
    );
    await this.sendNotification('notifications/initialized', { label: 'notifications/initialized' });
    this.initialized = true;
  }

  async callTool(name: string, args: Record<string, unknown>): Promise<ToolCallResponse> {
    await this.initialize();
    const response = await this.sendRequest<McpToolResult>(
      'tools/call',
      { name, arguments: args },
      { includeProtocolHeader: true, label: `tools/call ${name}`, toolName: name },
    );
    return response;
  }

  private async sendNotification(method: string, options: { label: string }): Promise<void> {
    await this.fetchJson(
      { jsonrpc: '2.0', method },
      { method, label: options.label, includeProtocolHeader: true },
    );
  }

  private async sendRequest<T>(
    method: string,
    params: Record<string, unknown>,
    options: { includeProtocolHeader: boolean; label: string; toolName?: string },
  ): Promise<{ result: T; trace: McpTrace }> {
    const id = this.nextId++;
    const { data, trace } = await this.fetchJson<JsonRpcResponse<T>>(
      { jsonrpc: '2.0', id, method, params },
      { method, label: options.label, toolName: options.toolName, includeProtocolHeader: options.includeProtocolHeader },
    );

    if (!data || typeof data !== 'object') {
      const failedTrace = this.markTraceFailed(trace, 'protocol', 'JSON-RPC 응답이 비어 있습니다.');
      throw new McpClientError('JSON-RPC 응답이 비어 있습니다.', { kind: 'protocol', trace: failedTrace });
    }

    if ('error' in data) {
      const kind = summarizeJsonRpcError(method, options.toolName, data.error.code);
      const failedTrace = this.markTraceFailed(trace, kind, data.error.message);
      throw new McpClientError(data.error.message, {
        kind,
        trace: failedTrace,
        details: data.error.data,
      });
    }

    return { result: data.result, trace };
  }

  private async fetchJson<T>(
    body: unknown,
    options: { method: string; label: string; toolName?: string; includeProtocolHeader: boolean },
  ): Promise<{ data: T | undefined; trace: McpTrace }> {
    const controller = new AbortController();
    const timeout = window.setTimeout(() => controller.abort(), this.timeoutMs);
    const startedAt = performance.now();
    const trace: McpTrace = {
      label: options.label,
      method: options.method,
      toolName: options.toolName,
      ok: false,
      bytes: 0,
      durationMs: 0,
      structuredContent: false,
    };

    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        Accept: 'application/json, text/event-stream',
      };
      if (options.includeProtocolHeader) {
        headers['MCP-Protocol-Version'] = MCP_PROTOCOL_VERSION;
      }
      if (this.authMode === 'x-token' && this.authToken) {
        headers['X-MCP-Auth-Token'] = this.authToken;
      }
      if (this.authMode === 'bearer' && this.authToken) {
        headers.Authorization = `Bearer ${this.authToken}`;
      }

      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers,
        body: JSON.stringify(body),
        signal: controller.signal,
      });
      const text = await response.text();
      trace.status = response.status;
      trace.bytes = byteLength(text);
      trace.durationMs = Math.round(performance.now() - startedAt);

      if (!response.ok) {
        const kind = classifyHttp(response.status, text);
        trace.errorKind = kind;
        trace.message = text || `HTTP ${response.status}`;
        this.recordTrace(trace);
        throw new McpClientError(trace.message, { kind, status: response.status, trace });
      }

      if (!text) {
        trace.ok = true;
        this.recordTrace(trace);
        return { data: undefined, trace };
      }

      let parsed: unknown;
      try {
        parsed = JSON.parse(text);
      } catch (error) {
        trace.errorKind = 'protocol';
        trace.message = error instanceof Error ? error.message : String(error);
        this.recordTrace(trace);
        throw new McpClientError('MCP 응답 JSON을 파싱할 수 없습니다.', { kind: 'protocol', trace });
      }

      const maybeResult = (parsed as { result?: { structuredContent?: unknown } }).result;
      trace.structuredContent =
        typeof maybeResult === 'object' &&
        maybeResult !== null &&
        'structuredContent' in maybeResult &&
        typeof maybeResult.structuredContent === 'object' &&
        maybeResult.structuredContent !== null;
      trace.ok = true;
      this.recordTrace(trace);
      return { data: parsed as T, trace };
    } catch (error) {
      if (error instanceof McpClientError) throw error;
      trace.durationMs = Math.round(performance.now() - startedAt);
      if (error instanceof DOMException && error.name === 'AbortError') {
        trace.errorKind = 'timeout';
        trace.message = 'MCP 응답 시간이 초과되었습니다.';
        this.recordTrace(trace);
        throw new McpClientError(trace.message, { kind: 'timeout', trace });
      }
      trace.errorKind = 'network';
      trace.message = error instanceof Error ? error.message : String(error);
      this.recordTrace(trace);
      throw new McpClientError('MCP 서버에 연결할 수 없습니다.', { kind: 'network', trace, details: trace.message });
    } finally {
      window.clearTimeout(timeout);
    }
  }

  private markTraceFailed(trace: McpTrace, kind: McpErrorKind, message: string): McpTrace {
    trace.ok = false;
    trace.errorKind = kind;
    trace.message = message;
    return trace;
  }

  private recordTrace(trace: McpTrace): void {
    const alreadyRecorded = this.traces.includes(trace);
    if (!alreadyRecorded) this.traces.push(trace);
  }
}
