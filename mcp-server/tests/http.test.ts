import { request as rawHttpRequest, type Server } from 'node:http';
import { connect as connectSocket, type AddressInfo } from 'node:net';

import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { TOOL_SMOKE_FIXTURES } from '../src/dashboard.js';
import { createHttpServer } from '../src/http.js';

const MCP_HEADERS = {
  'Content-Type': 'application/json',
  Accept: 'application/json, text/event-stream',
  'MCP-Protocol-Version': '2025-11-25',
};

type HttpServerOptions = Parameters<typeof createHttpServer>[0];

let server: Server;
let baseUrl: string;

async function listen(serverToListen: Server): Promise<string> {
  return await new Promise<string>((resolve, reject) => {
    serverToListen.once('error', reject);
    serverToListen.listen(0, '127.0.0.1', () => {
      serverToListen.off('error', reject);
      const address = serverToListen.address() as AddressInfo;
      resolve(`http://127.0.0.1:${address.port}`);
    });
  });
}

async function close(serverToClose: Server): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    serverToClose.close((error) => (error ? reject(error) : resolve()));
  });
}

async function withTempServer<T>(options: HttpServerOptions, run: (url: string, tempServer: Server) => Promise<T>): Promise<T> {
  const tempServer = createHttpServer(options);
  const tempBaseUrl = await listen(tempServer);
  try {
    return await run(tempBaseUrl, tempServer);
  } finally {
    await close(tempServer);
  }
}

async function postMcp(
  body: unknown,
  targetBaseUrl = baseUrl,
  headers: Record<string, string> = {},
): Promise<Response> {
  return fetch(`${targetBaseUrl}/mcp`, {
    method: 'POST',
    headers: { ...MCP_HEADERS, ...headers },
    body: JSON.stringify(body),
  });
}

async function postRaw(targetBaseUrl: string, path: string, headers: Record<string, string>, body: string): Promise<Response> {
  const url = new URL(targetBaseUrl);
  return await new Promise<Response>((resolve, reject) => {
    const req = rawHttpRequest(
      {
        host: url.hostname,
        port: Number(url.port),
        path,
        method: 'POST',
        headers,
      },
      (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (chunk: Buffer) => chunks.push(chunk));
        res.on('end', () => {
          resolve(
            new Response(Buffer.concat(chunks), {
              status: res.statusCode,
              headers: res.headers as Record<string, string>,
            }),
          );
        });
      },
    );
    req.on('error', reject);
    req.end(body);
  });
}

async function rawSocketRequest(targetBaseUrl: string, rawRequest: string): Promise<string> {
  const url = new URL(targetBaseUrl);
  return await new Promise((resolve, reject) => {
    const socket = connectSocket({ host: url.hostname, port: Number(url.port) });
    let response = '';
    let settled = false;
    const done = (value: string): void => {
      if (settled) return;
      settled = true;
      resolve(value);
    };
    socket.setEncoding('utf8');
    socket.on('connect', () => {
      socket.write(rawRequest);
    });
    socket.on('data', (chunk) => {
      response += chunk;
    });
    socket.on('end', () => {
      done(response);
    });
    socket.on('error', (error) => {
      if (response.length > 0) {
        done(response);
        return;
      }
      reject(error);
    });
    socket.setTimeout(2_000, () => {
      socket.destroy();
      done(response);
    });
  });
}

beforeAll(async () => {
  server = createHttpServer({ corsOrigins: ['http://localhost:5173', 'http://127.0.0.1:5173'] });
  baseUrl = await listen(server);
});

afterAll(async () => {
  await close(server);
});

describe('Streamable HTTP transport', () => {
  it('applies default request/header timeouts', () => {
    expect(server.requestTimeout).toBe(30_000);
    expect(server.headersTimeout).toBe(35_000);
  });

  it('/health returns server and engine metadata', async () => {
    const response = await fetch(`${baseUrl}/health`);
    expect(response.status).toBe(200);
    const body = (await response.json()) as Record<string, unknown>;
    expect(body).toMatchObject({
      ok: true,
      name: 'manseryeok',
      transport: 'streamable-http',
      mode: 'stateless-json',
      ruleVersion: 'krlt-yaja-2026.07',
    });
    expect(body.engineVersion).toBeTypeOf('string');
    expect(body.startedAt).toBeTypeOf('string');
    expect(body.uptimeMs).toBeTypeOf('number');
    expect(body.pid).toBe(process.pid);
    expect(body.requestsTotal).toBeTypeOf('number');
    expect(body.mcpRequestsTotal).toBeTypeOf('number');
    expect(body.errorsTotal).toBeTypeOf('number');
  });

  it('allows demo origins and rejects unknown CORS origins', async () => {
    const allowed = await fetch(`${baseUrl}/mcp`, {
      method: 'OPTIONS',
      headers: {
        Origin: 'http://localhost:5173',
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'content-type,accept,mcp-protocol-version',
      },
    });
    expect(allowed.status).toBe(204);
    expect(allowed.headers.get('access-control-allow-origin')).toBe('http://localhost:5173');

    const sameOrigin = await fetch(`${baseUrl}/mcp`, {
      method: 'OPTIONS',
      headers: {
        Origin: baseUrl,
        'Access-Control-Request-Method': 'POST',
        'Access-Control-Request-Headers': 'content-type,accept,mcp-protocol-version',
      },
    });
    expect(sameOrigin.status).toBe(204);
    expect(sameOrigin.headers.get('access-control-allow-origin')).toBe(baseUrl);

    const denied = await fetch(`${baseUrl}/mcp`, {
      method: 'OPTIONS',
      headers: {
        Origin: 'http://evil.example',
        'Access-Control-Request-Method': 'POST',
      },
    });
    expect(denied.status).toBe(403);
  });

  it('requires Authorization bearer token only when MCP_AUTH_TOKEN is configured', async () => {
    const listRequest = { jsonrpc: '2.0', id: 101, method: 'tools/list', params: {} };

    await withTempServer({}, async (tempBaseUrl) => {
      const open = await postMcp(listRequest, tempBaseUrl);
      expect(open.status).toBe(200);
    });

    await withTempServer({ authToken: 'test-secret' }, async (tempBaseUrl) => {
      const preflight = await fetch(`${tempBaseUrl}/mcp`, {
        method: 'OPTIONS',
        headers: {
          Origin: tempBaseUrl,
          'Access-Control-Request-Method': 'POST',
          'Access-Control-Request-Headers': 'authorization,x-mcp-auth-token,content-type',
        },
      });
      expect(preflight.status).toBe(204);
      expect(preflight.headers.get('access-control-allow-headers')).toContain('Authorization');
      expect(preflight.headers.get('access-control-allow-headers')).toContain('X-MCP-Auth-Token');

      const missing = await postMcp(listRequest, tempBaseUrl);
      expect(missing.status).toBe(401);
      expect(missing.headers.get('www-authenticate')).toContain('Bearer');
      const missingPayload = (await missing.json()) as { error?: { code?: number; message?: string } };
      expect(missingPayload.error).toMatchObject({ code: -32001, message: 'Unauthorized.' });

      const wrong = await postMcp(listRequest, tempBaseUrl, { Authorization: 'Bearer wrong-secret' });
      expect(wrong.status).toBe(401);

      const wrongCustomHeader = await postMcp(listRequest, tempBaseUrl, { 'X-MCP-Auth-Token': 'wrong-secret' });
      expect(wrongCustomHeader.status).toBe(401);

      const authorized = await postMcp(listRequest, tempBaseUrl, { Authorization: 'Bearer test-secret' });
      expect(authorized.status).toBe(200);
      const payload = (await authorized.json()) as { result?: { tools?: unknown[] }; error?: unknown };
      expect(payload.error).toBeUndefined();
      expect(payload.result?.tools).toHaveLength(20);

      const customHeaderAuthorized = await postMcp(listRequest, tempBaseUrl, { 'X-MCP-Auth-Token': 'test-secret' });
      expect(customHeaderAuthorized.status).toBe(200);

      const health = await fetch(`${tempBaseUrl}/health`);
      expect(await health.text()).not.toContain('test-secret');
    });
  });

  it('fails closed for non-local bind without an MCP auth token', () => {
    expect(() => createHttpServer({ host: '0.0.0.0' })).toThrow(/MCP_AUTH_TOKEN is required/);
    expect(() => createHttpServer({ host: '::' })).toThrow(/MCP_AUTH_TOKEN is required/);
    expect(() => createHttpServer({ host: '0.0.0.0', authToken: 'test-secret' })).not.toThrow();
  });

  it('rate limits /mcp POST by remote address but excludes /health and OPTIONS', async () => {
    await withTempServer({ rateLimitWindowMs: 80, rateLimitMax: 2 }, async (tempBaseUrl) => {
      await fetch(`${tempBaseUrl}/health`);
      await fetch(`${tempBaseUrl}/health`);
      const preflight = await fetch(`${tempBaseUrl}/mcp`, { method: 'OPTIONS' });
      expect(preflight.status).toBe(204);

      const listRequest = { jsonrpc: '2.0', id: 201, method: 'tools/list', params: {} };
      const first = await postMcp(listRequest, tempBaseUrl);
      const second = await postMcp({ ...listRequest, id: 202 }, tempBaseUrl);
      const third = await postMcp({ ...listRequest, id: 203 }, tempBaseUrl);

      expect(first.status).toBe(200);
      expect(first.headers.get('x-ratelimit-limit')).toBe('2');
      expect(second.status).toBe(200);
      expect(third.status).toBe(429);
      expect(third.headers.get('retry-after')).toBeTruthy();
      const limited = (await third.json()) as { error?: { code?: number; message?: string } };
      expect(limited.error).toMatchObject({ code: -32029, message: 'Rate limit exceeded.' });

      await new Promise((resolve) => setTimeout(resolve, 100));
      const afterReset = await postMcp({ ...listRequest, id: 204 }, tempBaseUrl);
      expect(afterReset.status).toBe(200);
    });
  });


  it('/dashboard serves the browser tool status dashboard', async () => {
    const response = await fetch(`${baseUrl}/dashboard`);
    expect(response.status).toBe(200);
    expect(response.headers.get('content-type')).toContain('text/html');
    const html = await response.text();
    expect(html).toContain('manseryeok-mcp Tool Dashboard');
    expect(html).toContain('툴 상태 점검');
    expect(html).toContain('전체 툴 테스트');
    expect(html).toContain('calendar_day_info');
    expect(html).toContain('tools/call');
    // Scanability landmarks (dashboard redesign)
    expect(html).toContain('one-line-summary');
    expect(html).toContain('filter-chip');
    expect(html).toContain('Failed only');
    expect(html).toContain('progress-bar');
    expect(html).toContain('kpi-fail');
    expect(html).toContain('view-cards');
    expect(html).toContain('details class="fold"');
    expect(html).toContain('PlayMCP Preflight');
    expect(html).toContain('X-MCP-Auth-Token');
    expect(html).toContain('id="infoLoadBtn"');
    expect(html).toContain('id="bodyLimitBtn"');
    expect(html).toContain('id="listSizeValue"');
    expect(html).toContain('error classification');


    const headResponse = await fetch(`${baseUrl}/dashboard`, { method: 'HEAD' });
    expect(headResponse.status).toBe(200);
    expect(headResponse.headers.get('content-type')).toContain('text/html');
  });

  it('/dashboard/fixtures covers every MCP tool exposed by tools/list and all fixtures smoke over HTTP', async () => {
    const fixturesResponse = await fetch(`${baseUrl}/dashboard/fixtures`);
    expect(fixturesResponse.status).toBe(200);
    const fixtures = (await fixturesResponse.json()) as { count: number; tools: Record<string, unknown> };

    const listResponse = await postMcp({ jsonrpc: '2.0', id: 9, method: 'tools/list', params: {} });
    expect(listResponse.status).toBe(200);
    const listPayload = (await listResponse.json()) as { result?: { tools?: Array<{ name: string }> } };
    const listed = (listPayload.result?.tools ?? []).map((tool) => tool.name).sort();
    const fixtureNames = Object.keys(fixtures.tools).sort();

    expect(fixtures.count).toBe(20);
    expect(fixtureNames).toEqual(Object.keys(TOOL_SMOKE_FIXTURES).sort());
    expect(fixtureNames).toEqual(listed);

    let id = 20;
    for (const toolName of listed) {
      const fixture = TOOL_SMOKE_FIXTURES[toolName];
      expect(fixture, `${toolName} fixture 누락`).toBeDefined();
      const callResponse = await postMcp({
        jsonrpc: '2.0',
        id: id++,
        method: 'tools/call',
        params: { name: toolName, arguments: fixture.args },
      });
      expect(callResponse.status, `${toolName} HTTP status`).toBe(200);
      const payload = (await callResponse.json()) as {
        error?: unknown;
        result?: { isError?: boolean; structuredContent?: unknown };
      };
      expect(payload.error, `${toolName} JSON-RPC error`).toBeUndefined();
      expect(payload.result, `${toolName} result 누락`).toBeDefined();
      expect(payload.result?.isError ?? false, `${toolName} isError`).toBe(false);
      expect(payload.result?.structuredContent, `${toolName} structuredContent 누락`).toBeDefined();
    }
  });

  it('rejects Content-Length over MCP_MAX_BODY_BYTES with 413 JSON-RPC error', async () => {
    await withTempServer({ maxBodyBytes: 8 }, async (tempBaseUrl) => {
      const response = await postRaw(
        tempBaseUrl,
        '/mcp',
        {
          ...MCP_HEADERS,
          'Content-Length': '9',
        },
        '123456789',
      );
      expect(response.status).toBe(413);
      const payload = (await response.json()) as { error?: { code?: number; message?: string } };
      expect(payload.error).toMatchObject({ code: -32000, message: 'Request body too large.' });
    });
  });

  it('malformed Content-Length is rejected with HTTP 400', async () => {
    const rawResponse = await rawSocketRequest(
      baseUrl,
      [
        'POST /mcp HTTP/1.1',
        'Host: 127.0.0.1',
        'Content-Type: application/json',
        'Accept: application/json, text/event-stream',
        'MCP-Protocol-Version: 2025-11-25',
        'Content-Length: not-a-number',
        '',
        '',
      ].join('\r\n'),
    );
    expect(rawResponse).toContain('400 Bad Request');
  });

  it('dashboard is local-by-default and blocked for external bind unless explicitly enabled', async () => {
    await withTempServer({ host: '0.0.0.0', authToken: 'test-secret' }, async (tempBaseUrl) => {
      const dashboard = await fetch(`${tempBaseUrl}/dashboard`);
      const fixtures = await fetch(`${tempBaseUrl}/dashboard/fixtures`);
      expect(dashboard.status).toBe(404);
      expect(fixtures.status).toBe(404);
    });

    await withTempServer({ host: '0.0.0.0', authToken: 'test-secret', dashboardEnabled: true }, async (tempBaseUrl) => {
      const dashboard = await fetch(`${tempBaseUrl}/dashboard`);
      expect(dashboard.status).toBe(200);
      expect(await dashboard.text()).toContain('manseryeok-mcp Tool Dashboard');
    });
  });

  it('initialize returns a JSON response, not an SSE stream', async () => {
    const response = await postMcp({
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2025-11-25',
        capabilities: {},
        clientInfo: { name: 'vitest-http', version: '0.0.0' },
      },
    });

    expect(response.status).toBe(200);
    expect(response.headers.get('content-type')).toContain('application/json');
    expect(response.headers.get('content-type')).not.toContain('text/event-stream');
    const payload = (await response.json()) as { result?: { serverInfo?: { name?: string } } };
    expect(payload.result?.serverInfo?.name).toBe('manseryeok');
  });

  it('tools/call calendar_day_info returns structuredContent over JSON response mode', async () => {
    const response = await postMcp({
      jsonrpc: '2.0',
      id: 2,
      method: 'tools/call',
      params: { name: 'calendar_day_info', arguments: { year: 2026, month: 7, day: 9 } },
    });

    expect(response.status).toBe(200);
    expect(response.headers.get('content-type')).toContain('application/json');
    const payload = (await response.json()) as { result?: { structuredContent?: { day?: { dayGanJi?: string } } } };
    expect(payload.result?.structuredContent?.day?.dayGanJi).toBe('갑신');
  });

  it('tools/call saju_palja returns player day pillar structuredContent', async () => {
    const response = await postMcp({
      jsonrpc: '2.0',
      id: 3,
      method: 'tools/call',
      params: {
        name: 'saju_palja',
        arguments: { birth: { year: 1990, month: 3, day: 15, hour: 14, minute: 30, gender: 'male' } },
      },
    });

    expect(response.status).toBe(200);
    const payload = (await response.json()) as { result?: { structuredContent?: { palja?: { dayGan?: string; dayJi?: string } } } };
    expect(payload.result?.structuredContent?.palja).toMatchObject({ dayGan: '己', dayJi: '卯' });
  });
});
