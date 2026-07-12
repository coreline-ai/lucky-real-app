#!/usr/bin/env node
import { request as httpRequest } from 'node:http';

import { TOOL_SMOKE_FIXTURES } from '../dist/dashboard.js';

const baseUrl = (process.env.MCP_SMOKE_BASE_URL || 'http://127.0.0.1:3100').replace(/\/$/, '');
const authToken = process.env.MCP_SMOKE_AUTH_TOKEN || process.env.MCP_AUTH_TOKEN || '';
const expectDashboardDisabled = isTruthy(process.env.MCP_SMOKE_EXPECT_DASHBOARD_DISABLED);
const maxBodyBytes = Number(process.env.MCP_SMOKE_MAX_BODY_BYTES || process.env.MCP_MAX_BODY_BYTES || 1024 * 1024);
const protocolVersion = '2025-11-25';
let nextId = 1;
const failures = [];

function isTruthy(value) {
  return typeof value === 'string' && ['1', 'true', 'yes', 'on'].includes(value.trim().toLowerCase());
}

function log(ok, label, details = '') {
  const mark = ok ? 'OK ' : 'FAIL';
  const line = `[${mark}] ${label}${details ? ` — ${details}` : ''}`;
  console.log(line);
  if (!ok) failures.push(line);
}

function authHeaders(token = authToken) {
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function fetchJson(path, init = {}) {
  const response = await fetch(`${baseUrl}${path}`, init);
  const text = await response.text();
  let json;
  try {
    json = text ? JSON.parse(text) : null;
  } catch {
    json = null;
  }
  return { response, text, json };
}

async function rpc(method, params, token = authToken) {
  const { response, json, text } = await fetchJson('/mcp', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json, text/event-stream',
      'MCP-Protocol-Version': protocolVersion,
      ...authHeaders(token),
    },
    body: JSON.stringify({ jsonrpc: '2.0', id: nextId++, method, params }),
  });
  if (!response.ok || json?.error) {
    throw new Error(`${method} HTTP ${response.status}: ${JSON.stringify(json?.error || json || text).slice(0, 220)}`);
  }
  return json.result;
}

async function rawPostTooLarge() {
  const url = new URL(baseUrl);
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
    'MCP-Protocol-Version': protocolVersion,
    'Content-Length': String(maxBodyBytes + 1),
    ...authHeaders(),
  };
  return await new Promise((resolve, reject) => {
    const req = httpRequest(
      {
        protocol: url.protocol,
        hostname: url.hostname,
        port: url.port,
        path: '/mcp',
        method: 'POST',
        headers,
      },
      (res) => {
        let body = '';
        res.setEncoding('utf8');
        res.on('data', (chunk) => {
          body += chunk;
        });
        res.on('end', () => resolve({ status: res.statusCode, body }));
      },
    );
    req.on('error', reject);
    req.end();
  });
}

async function checkHealth() {
  const { response, json, text } = await fetchJson('/health');
  const ok = response.status === 200 && json?.ok === true && typeof json?.startedAt === 'string' && typeof json?.uptimeMs === 'number';
  log(ok, '/health metrics', ok ? `${json.name}@${json.version} pid=${json.pid}` : `HTTP ${response.status}`);
  if (authToken) {
    log(!text.includes(authToken), '/health does not expose auth token');
  }
}

async function checkDashboard() {
  if (expectDashboardDisabled) {
    const dashboard = await fetch(`${baseUrl}/dashboard`);
    const fixtures = await fetch(`${baseUrl}/dashboard/fixtures`);
    log(dashboard.status === 404, 'dashboard disabled gate', `GET /dashboard => ${dashboard.status}`);
    log(fixtures.status === 404, 'fixtures disabled gate', `GET /dashboard/fixtures => ${fixtures.status}`);
    return;
  }

  const { response, json } = await fetchJson('/dashboard/fixtures');
  const fixtureNames = Object.keys(TOOL_SMOKE_FIXTURES).sort();
  const remoteNames = Object.keys(json?.tools || {}).sort();
  log(response.status === 200 && json?.count === fixtureNames.length, '/dashboard/fixtures count', `count=${json?.count}`);
  log(JSON.stringify(remoteNames) === JSON.stringify(fixtureNames), '/dashboard/fixtures names match dist fixtures');
}

async function checkAuthIfConfigured() {
  if (!authToken) {
    log(true, 'auth negative checks skipped', 'no MCP_SMOKE_AUTH_TOKEN/MCP_AUTH_TOKEN');
    return;
  }

  const body = JSON.stringify({ jsonrpc: '2.0', id: nextId++, method: 'tools/list', params: {} });
  const baseHeaders = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
    'MCP-Protocol-Version': protocolVersion,
  };
  const missing = await fetch(`${baseUrl}/mcp`, { method: 'POST', headers: baseHeaders, body });
  const wrong = await fetch(`${baseUrl}/mcp`, {
    method: 'POST',
    headers: { ...baseHeaders, Authorization: 'Bearer wrong-token' },
    body,
  });
  const wrongCustomHeader = await fetch(`${baseUrl}/mcp`, {
    method: 'POST',
    headers: { ...baseHeaders, 'X-MCP-Auth-Token': 'wrong-token' },
    body,
  });
  const customHeaderAuthorized = await fetch(`${baseUrl}/mcp`, {
    method: 'POST',
    headers: { ...baseHeaders, 'X-MCP-Auth-Token': authToken },
    body,
  });
  log(missing.status === 401, 'auth rejects missing token', `HTTP ${missing.status}`);
  log(wrong.status === 401, 'auth rejects wrong token', `HTTP ${wrong.status}`);
  log(wrongCustomHeader.status === 401, 'auth rejects wrong X-MCP-Auth-Token', `HTTP ${wrongCustomHeader.status}`);
  log(customHeaderAuthorized.status === 200, 'auth accepts X-MCP-Auth-Token', `HTTP ${customHeaderAuthorized.status}`);
}

async function checkCorsAndBodyLimit() {
  const cors = await fetch(`${baseUrl}/mcp`, {
    method: 'OPTIONS',
    headers: {
      Origin: 'http://evil.example',
      'Access-Control-Request-Method': 'POST',
    },
  });
  log(cors.status === 403, 'unknown CORS origin rejected', `HTTP ${cors.status}`);

  const tooLarge = await rawPostTooLarge();
  log(tooLarge.status === 413, 'Content-Length over limit rejected', `HTTP ${tooLarge.status}`);
}

async function checkTools() {
  const list = await rpc('tools/list', {});
  const listed = (list.tools || []).map((tool) => tool.name).sort();
  const fixtureNames = Object.keys(TOOL_SMOKE_FIXTURES).sort();
  log(listed.length === 20, 'tools/list count', `count=${listed.length}`);
  log(JSON.stringify(listed) === JSON.stringify(fixtureNames), 'tools/list matches smoke fixtures');

  let ok = 0;
  const failed = [];
  for (const name of listed) {
    try {
      const result = await rpc('tools/call', { name, arguments: TOOL_SMOKE_FIXTURES[name].args });
      if (result?.isError === true || !result?.structuredContent) {
        throw new Error('isError=true or structuredContent missing');
      }
      ok += 1;
    } catch (error) {
      failed.push(`${name}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
  log(ok === listed.length && failed.length === 0, '20 MCP tool HTTP smoke', `${ok} OK / ${failed.length} FAIL`);
  for (const item of failed) log(false, item);
}

async function main() {
  console.log(`[mcp-prod-smoke] target=${baseUrl}`);
  await checkHealth();
  await checkDashboard();
  await checkAuthIfConfigured();
  await checkCorsAndBodyLimit();
  await checkTools();

  if (failures.length > 0) {
    console.error(`[mcp-prod-smoke] failed ${failures.length} gate(s)`);
    process.exit(1);
  }
  console.log('[mcp-prod-smoke] all gates passed');
}

main().catch((error) => {
  console.error('[mcp-prod-smoke] fatal:', error instanceof Error ? error.message : String(error));
  process.exit(1);
});
