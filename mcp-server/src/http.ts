import { createServer as createNodeHttpServer, type IncomingMessage, type RequestListener, type Server, type ServerResponse } from 'node:http';
import { pathToFileURL } from 'node:url';

import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';

import { TOOL_DASHBOARD_HTML, TOOL_SMOKE_FIXTURES } from './dashboard.js';
import { ENGINE_META, SERVER_NAME, SERVER_VERSION } from './meta.js';
import { createServer } from './server.js';

const DEFAULT_HOST = '127.0.0.1';
const DEFAULT_PORT = 3100;
const DEFAULT_CORS_ORIGINS = ['http://localhost:5173', 'http://127.0.0.1:5173'] as const;
const DEFAULT_MAX_BODY_BYTES = 1024 * 1024;
const DEFAULT_REQUEST_TIMEOUT_MS = 30_000;
const DEFAULT_HEADERS_TIMEOUT_MS = 35_000;
const DEFAULT_RATE_LIMIT_WINDOW_MS = 60_000;
const DEFAULT_RATE_LIMIT_MAX = 120;

interface HttpServerOptions {
  host?: string;
  port?: number;
  corsOrigins?: readonly string[];
  maxBodyBytes?: number;
  requestTimeoutMs?: number;
  headersTimeoutMs?: number;
  dashboardEnabled?: boolean;
  authToken?: string;
  rateLimitWindowMs?: number;
  rateLimitMax?: number;
}

interface JsonRpcErrorBody {
  jsonrpc: '2.0';
  error: { code: number; message: string };
  id: null;
}

interface HttpMetrics {
  startedAt: string;
  startedAtMs: number;
  requestsTotal: number;
  mcpRequestsTotal: number;
  errorsTotal: number;
}

interface RateLimitBucket {
  windowStartMs: number;
  count: number;
}

interface RateLimitState {
  buckets: Map<string, RateLimitBucket>;
  lastCleanupMs: number;
}

function parsePort(value: string | undefined): number {
  if (value === undefined || value.trim() === '') return DEFAULT_PORT;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0 || parsed > 65535) {
    throw new Error(`PORT는 1~65535 정수여야 합니다: ${value}`);
  }
  return parsed;
}

function parseCorsOrigins(value: string | undefined): string[] {
  if (value === undefined || value.trim() === '') return [...DEFAULT_CORS_ORIGINS];
  return value
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function parsePositiveIntegerEnv(name: string, value: string | undefined, defaultValue: number): number {
  if (value === undefined || value.trim() === '') return defaultValue;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${name}는 양의 정수여야 합니다: ${value}`);
  }
  return parsed;
}

function parseBooleanEnv(name: string, value: string | undefined): boolean | undefined {
  if (value === undefined || value.trim() === '') return undefined;
  const normalized = value.trim().toLowerCase();
  if (['1', 'true', 'yes', 'on'].includes(normalized)) return true;
  if (['0', 'false', 'no', 'off'].includes(normalized)) return false;
  throw new Error(`${name}는 true/false 형식이어야 합니다: ${value}`);
}

function parseOptionalToken(value: string | undefined): string | undefined {
  if (value === undefined || value.trim() === '') return undefined;
  return value;
}

function isLocalHost(host: string): boolean {
  const normalized = host.trim().toLowerCase();
  return normalized === '127.0.0.1' || normalized === 'localhost' || normalized === '::1' || normalized === '[::1]';
}

function assertAuthPolicy(host: string, authToken: string | undefined): void {
  if (isLocalHost(host) || authToken !== undefined) return;
  throw new Error(`MCP_AUTH_TOKEN is required when HOST is non-local: ${host}`);
}

function createMetrics(): HttpMetrics {
  const now = new Date();
  return {
    startedAt: now.toISOString(),
    startedAtMs: now.getTime(),
    requestsTotal: 0,
    mcpRequestsTotal: 0,
    errorsTotal: 0,
  };
}

function createRateLimitState(): RateLimitState {
  return { buckets: new Map(), lastCleanupMs: Date.now() };
}

function head(res: ServerResponse, statusCode: number, contentType: string): void {
  if (!res.headersSent) {
    res.statusCode = statusCode;
    res.setHeader('Content-Type', contentType);
  }
  res.end();
}

function html(res: ServerResponse, statusCode: number, body: string): void {
  if (!res.headersSent) {
    res.statusCode = statusCode;
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
  }
  res.end(body);
}

function json(res: ServerResponse, statusCode: number, body: unknown): void {
  if (!res.headersSent) {
    res.statusCode = statusCode;
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
  }
  res.end(JSON.stringify(body));
}

function jsonRpcError(code: number, message: string): JsonRpcErrorBody {
  return { jsonrpc: '2.0', error: { code, message }, id: null };
}

function requestPath(req: IncomingMessage, host: string): string {
  const rawUrl = req.url ?? '/';
  return new URL(rawUrl, `http://${req.headers.host ?? host}`).pathname;
}

function attachRequestLogging(
  req: IncomingMessage,
  res: ServerResponse,
  metrics: HttpMetrics,
  pathname: string,
): void {
  const startedNs = process.hrtime.bigint();
  res.once('finish', () => {
    const durationMs = Number((process.hrtime.bigint() - startedNs) / 1_000_000n);
    if (res.statusCode >= 400) {
      metrics.errorsTotal += 1;
    }
    console.error(
      `[manseryeok-mcp:http] ${req.method ?? 'GET'} ${pathname} ${res.statusCode} ${durationMs}ms`,
    );
  });
}

function applyCors(req: IncomingMessage, res: ServerResponse, corsOrigins: readonly string[]): boolean {
  const origin = req.headers.origin;
  if (origin === undefined) return true;

  const requestHost = req.headers.host;
  const isSameOrigin =
    requestHost !== undefined && (origin === `http://${requestHost}` || origin === `https://${requestHost}`);

  if (!isSameOrigin && !corsOrigins.includes(origin)) {
    json(res, 403, { ok: false, error: 'CORS origin denied' });
    return false;
  }

  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Accept, Authorization, X-MCP-Auth-Token, MCP-Protocol-Version, Mcp-Session-Id',
  );
  res.setHeader('Access-Control-Expose-Headers', 'MCP-Protocol-Version, Mcp-Session-Id');
  return true;
}

function isAuthorizedHeader(req: IncomingMessage, authToken: string): boolean {
  const authorization = req.headers.authorization;
  if (typeof authorization !== 'string') return false;
  return authorization === `Bearer ${authToken}`;
}

function isCustomTokenHeader(req: IncomingMessage, authToken: string): boolean {
  const token = req.headers['x-mcp-auth-token'];
  return typeof token === 'string' && token === authToken;
}

function isAuthorized(req: IncomingMessage, authToken: string | undefined): boolean {
  if (authToken === undefined) return true;
  return isAuthorizedHeader(req, authToken) || isCustomTokenHeader(req, authToken);
}

function clientKey(req: IncomingMessage): string {
  return req.socket.remoteAddress ?? 'unknown';
}

function checkRateLimit(
  req: IncomingMessage,
  state: RateLimitState,
  windowMs: number,
  max: number,
): { ok: true; remaining: number } | { ok: false; retryAfterSeconds: number } {
  const now = Date.now();
  if (now - state.lastCleanupMs > windowMs) {
    for (const [key, bucket] of state.buckets) {
      if (now - bucket.windowStartMs >= windowMs) {
        state.buckets.delete(key);
      }
    }
    state.lastCleanupMs = now;
  }

  const key = clientKey(req);
  const current = state.buckets.get(key);
  const bucket =
    current === undefined || now - current.windowStartMs >= windowMs
      ? { windowStartMs: now, count: 0 }
      : current;
  bucket.count += 1;
  state.buckets.set(key, bucket);

  if (bucket.count > max) {
    const retryAfterMs = Math.max(0, windowMs - (now - bucket.windowStartMs));
    return { ok: false, retryAfterSeconds: Math.max(1, Math.ceil(retryAfterMs / 1000)) };
  }

  return { ok: true, remaining: Math.max(0, max - bucket.count) };
}

function checkContentLength(
  req: IncomingMessage,
  maxBodyBytes: number,
): { ok: true } | { ok: false; statusCode: number; body: JsonRpcErrorBody } {
  const value = req.headers['content-length'];
  if (value === undefined) return { ok: true };
  if (Array.isArray(value)) {
    return { ok: false, statusCode: 400, body: jsonRpcError(-32600, 'Invalid Content-Length header.') };
  }

  const normalized = value.trim();
  if (!/^\d+$/.test(normalized)) {
    return { ok: false, statusCode: 400, body: jsonRpcError(-32600, 'Invalid Content-Length header.') };
  }

  const contentLength = Number(normalized);
  if (!Number.isSafeInteger(contentLength)) {
    return { ok: false, statusCode: 400, body: jsonRpcError(-32600, 'Invalid Content-Length header.') };
  }

  if (contentLength > maxBodyBytes) {
    return { ok: false, statusCode: 413, body: jsonRpcError(-32000, 'Request body too large.') };
  }

  return { ok: true };
}

async function handleMcpPost(req: IncomingMessage, res: ServerResponse): Promise<void> {
  const mcpServer = createServer();
  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined,
    enableJsonResponse: true,
  });

  transport.onerror = (error) => {
    console.error('[manseryeok-mcp:http] transport error:', error.message);
  };

  res.on('close', () => {
    void transport.close();
    void mcpServer.close();
  });

  try {
    await mcpServer.connect(transport);
    await transport.handleRequest(req, res);
  } catch (error) {
    console.error('[manseryeok-mcp:http] request failed:', error instanceof Error ? error.message : String(error));
    if (!res.headersSent) {
      json(res, 500, jsonRpcError(-32603, 'Internal server error'));
    }
  }
}

export function createHttpRequestListener(options: HttpServerOptions = {}): RequestListener {
  const host = options.host ?? DEFAULT_HOST;
  const corsOrigins = options.corsOrigins ?? DEFAULT_CORS_ORIGINS;
  const maxBodyBytes = options.maxBodyBytes ?? DEFAULT_MAX_BODY_BYTES;
  const dashboardEnabled = options.dashboardEnabled ?? isLocalHost(host);
  const authToken = parseOptionalToken(options.authToken);
  assertAuthPolicy(host, authToken);
  const rateLimitWindowMs = options.rateLimitWindowMs ?? DEFAULT_RATE_LIMIT_WINDOW_MS;
  const rateLimitMax = options.rateLimitMax ?? DEFAULT_RATE_LIMIT_MAX;
  const metrics = createMetrics();
  const rateLimitState = createRateLimitState();

  return (req, res) => {
    const pathname = requestPath(req, host);
    const method = req.method ?? 'GET';
    const routeMethod = method === 'HEAD' ? 'GET' : method;
    metrics.requestsTotal += 1;
    if (pathname === '/mcp' && method === 'POST') {
      metrics.mcpRequestsTotal += 1;
    }
    attachRequestLogging(req, res, metrics, pathname);

    if (!applyCors(req, res, corsOrigins)) return;

    if (method === 'OPTIONS') {
      res.statusCode = 204;
      res.end();
      return;
    }

    if (pathname === '/health' && routeMethod === 'GET') {
      if (method === 'HEAD') {
        head(res, 200, 'application/json; charset=utf-8');
        return;
      }
      json(res, 200, {
        ok: true,
        name: SERVER_NAME,
        version: SERVER_VERSION,
        engineVersion: ENGINE_META.engineVersion,
        ruleVersion: ENGINE_META.ruleVersion,
        transport: 'streamable-http',
        mode: 'stateless-json',
        startedAt: metrics.startedAt,
        uptimeMs: Date.now() - metrics.startedAtMs,
        pid: process.pid,
        requestsTotal: metrics.requestsTotal,
        mcpRequestsTotal: metrics.mcpRequestsTotal,
        errorsTotal: metrics.errorsTotal,
      });
      return;
    }

    if ((pathname === '/dashboard' || pathname === '/dashboard/') && routeMethod === 'GET') {
      if (!dashboardEnabled) {
        if (method === 'HEAD') {
          head(res, 404, 'application/json; charset=utf-8');
          return;
        }
        json(res, 404, { ok: false, error: 'Dashboard disabled' });
        return;
      }
      if (method === 'HEAD') {
        head(res, 200, 'text/html; charset=utf-8');
        return;
      }
      html(res, 200, TOOL_DASHBOARD_HTML);
      return;
    }

    if (pathname === '/dashboard/fixtures' && routeMethod === 'GET') {
      if (!dashboardEnabled) {
        if (method === 'HEAD') {
          head(res, 404, 'application/json; charset=utf-8');
          return;
        }
        json(res, 404, { ok: false, error: 'Dashboard disabled' });
        return;
      }
      if (method === 'HEAD') {
        head(res, 200, 'application/json; charset=utf-8');
        return;
      }
      json(res, 200, { tools: TOOL_SMOKE_FIXTURES, count: Object.keys(TOOL_SMOKE_FIXTURES).length });
      return;
    }

    if (pathname === '/mcp' && method === 'POST') {
      const contentLengthCheck = checkContentLength(req, maxBodyBytes);
      if (!contentLengthCheck.ok) {
        res.setHeader('Connection', 'close');
        json(res, contentLengthCheck.statusCode, contentLengthCheck.body);
        req.resume();
        return;
      }
      if (!isAuthorized(req, authToken)) {
        res.setHeader('WWW-Authenticate', 'Bearer realm="manseryeok-mcp"');
        json(res, 401, jsonRpcError(-32001, 'Unauthorized.'));
        req.resume();
        return;
      }
      const rateLimitCheck = checkRateLimit(req, rateLimitState, rateLimitWindowMs, rateLimitMax);
      if (!rateLimitCheck.ok) {
        res.setHeader('Retry-After', String(rateLimitCheck.retryAfterSeconds));
        json(res, 429, jsonRpcError(-32029, 'Rate limit exceeded.'));
        req.resume();
        return;
      }
      res.setHeader('X-RateLimit-Limit', String(rateLimitMax));
      res.setHeader('X-RateLimit-Remaining', String(rateLimitCheck.remaining));
      void handleMcpPost(req, res);
      return;
    }

    if (pathname === '/mcp') {
      res.setHeader('Allow', 'POST');
      json(res, 405, jsonRpcError(-32000, 'Method not allowed.'));
      return;
    }

    if (pathname === '/favicon.ico' && routeMethod === 'GET') {
      res.statusCode = 204;
      res.end();
      return;
    }

    json(res, 404, { ok: false, error: 'Not found' });
  };
}

export function createHttpServer(options: HttpServerOptions = {}): Server {
  const requestTimeoutMs = options.requestTimeoutMs ?? DEFAULT_REQUEST_TIMEOUT_MS;
  const headersTimeoutMs = options.headersTimeoutMs ?? DEFAULT_HEADERS_TIMEOUT_MS;
  const server = createNodeHttpServer(createHttpRequestListener(options));
  server.requestTimeout = requestTimeoutMs;
  server.headersTimeout = headersTimeoutMs;
  return server;
}

export async function startHttpServer(options: HttpServerOptions = {}): Promise<Server> {
  const host = options.host ?? process.env.HOST ?? DEFAULT_HOST;
  const port = options.port ?? parsePort(process.env.PORT);
  const corsOrigins = options.corsOrigins ?? parseCorsOrigins(process.env.CORS_ORIGIN);
  const maxBodyBytes =
    options.maxBodyBytes ?? parsePositiveIntegerEnv('MCP_MAX_BODY_BYTES', process.env.MCP_MAX_BODY_BYTES, DEFAULT_MAX_BODY_BYTES);
  const requestTimeoutMs =
    options.requestTimeoutMs ??
    parsePositiveIntegerEnv('MCP_REQUEST_TIMEOUT_MS', process.env.MCP_REQUEST_TIMEOUT_MS, DEFAULT_REQUEST_TIMEOUT_MS);
  const headersTimeoutMs =
    options.headersTimeoutMs ??
    parsePositiveIntegerEnv('MCP_HEADERS_TIMEOUT_MS', process.env.MCP_HEADERS_TIMEOUT_MS, DEFAULT_HEADERS_TIMEOUT_MS);
  const dashboardEnabled =
    options.dashboardEnabled ?? parseBooleanEnv('ENABLE_DASHBOARD', process.env.ENABLE_DASHBOARD);
  const authToken = options.authToken ?? parseOptionalToken(process.env.MCP_AUTH_TOKEN);
  const rateLimitWindowMs =
    options.rateLimitWindowMs ??
    parsePositiveIntegerEnv('MCP_RATE_LIMIT_WINDOW_MS', process.env.MCP_RATE_LIMIT_WINDOW_MS, DEFAULT_RATE_LIMIT_WINDOW_MS);
  const rateLimitMax =
    options.rateLimitMax ?? parsePositiveIntegerEnv('MCP_RATE_LIMIT_MAX', process.env.MCP_RATE_LIMIT_MAX, DEFAULT_RATE_LIMIT_MAX);
  // createHttpRequestListener treats undefined as "local host only"
  const dashboardWillServe = dashboardEnabled ?? isLocalHost(host);
  const server = createHttpServer({
    host,
    port,
    corsOrigins,
    maxBodyBytes,
    requestTimeoutMs,
    headersTimeoutMs,
    dashboardEnabled,
    authToken,
    rateLimitWindowMs,
    rateLimitMax,
  });

  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(port, host, () => {
      server.off('error', reject);
      const base = `http://${host}:${port}`;
      console.error(`[manseryeok-mcp:http] ${SERVER_NAME}@${SERVER_VERSION} listening on ${base}`);
      console.error(`[manseryeok-mcp:http] health    ${base}/health`);
      if (dashboardWillServe) {
        console.error(`[manseryeok-mcp:http] dashboard ${base}/dashboard`);
      } else {
        console.error(
          `[manseryeok-mcp:http] dashboard disabled (set ENABLE_DASHBOARD=true for non-local bind)`,
        );
      }
      console.error(`[manseryeok-mcp:http] mcp       POST ${base}/mcp`);
      resolve();
    });
  });

  return server;
}

function closeServer(server: Server): Promise<void> {
  return new Promise((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  });
}

function installGracefulShutdown(server: Server): void {
  let shuttingDown = false;
  const shutdown = (signal: NodeJS.Signals): void => {
    if (shuttingDown) return;
    shuttingDown = true;
    console.error(`[manseryeok-mcp:http] received ${signal}; shutting down`);
    server.closeIdleConnections?.();
    const forceClose = setTimeout(() => {
      console.error('[manseryeok-mcp:http] forcing active connection close');
      server.closeAllConnections?.();
    }, 5_000);
    forceClose.unref();

    closeServer(server)
      .then(() => {
        clearTimeout(forceClose);
        console.error('[manseryeok-mcp:http] shutdown complete');
        process.exit(0);
      })
      .catch((error) => {
        clearTimeout(forceClose);
        console.error('[manseryeok-mcp:http] shutdown failed:', error instanceof Error ? error.message : String(error));
        process.exit(1);
      });
  };

  process.once('SIGINT', shutdown);
  process.once('SIGTERM', shutdown);
}

function isEntrypoint(): boolean {
  return process.argv[1] !== undefined && import.meta.url === pathToFileURL(process.argv[1]).href;
}

if (isEntrypoint()) {
  startHttpServer()
    .then((server) => {
      installGracefulShutdown(server);
    })
    .catch((error) => {
      console.error('[manseryeok-mcp:http] failed to start:', error instanceof Error ? error.message : String(error));
      process.exit(1);
    });
}
