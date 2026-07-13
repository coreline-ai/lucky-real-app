#!/usr/bin/env node
import { TOOL_SMOKE_FIXTURES } from '../dist/dashboard.js';

const rawTarget = process.env.MCP_PREFLIGHT_BASE_URL || process.env.MCP_SMOKE_BASE_URL || 'http://127.0.0.1:3100';
const authToken = process.env.MCP_PREFLIGHT_AUTH_TOKEN || process.env.MCP_SMOKE_AUTH_TOKEN || process.env.MCP_AUTH_TOKEN || '';
const representativeTool = process.env.MCP_PREFLIGHT_TOOL || 'calendar_day_info';
let okThresholdBytes = 0;
let largeThresholdBytes = 0;
let maxBodyBytes = 0;
const protocolVersion = '2025-11-25';
let nextId = 1;
const rows = [];

function parsePositiveInteger(value, name) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer: ${value}`);
  }
  return parsed;
}

function validateConfiguration() {
  okThresholdBytes = parsePositiveInteger(process.env.MCP_SIZE_OK_BYTES || 32 * 1024, 'MCP_SIZE_OK_BYTES');
  largeThresholdBytes = parsePositiveInteger(process.env.MCP_SIZE_LARGE_BYTES || 100 * 1024, 'MCP_SIZE_LARGE_BYTES');
  maxBodyBytes = parsePositiveInteger(
    process.env.MCP_PREFLIGHT_MAX_BODY_BYTES || process.env.MCP_MAX_BODY_BYTES || 1024 * 1024,
    'MCP_PREFLIGHT_MAX_BODY_BYTES',
  );
  if (okThresholdBytes >= largeThresholdBytes) {
    throw new Error('MCP_SIZE_OK_BYTES must be smaller than MCP_SIZE_LARGE_BYTES');
  }
}

function normalizeTarget(value) {
  const trimmed = value.replace(/\/$/, '');
  if (trimmed.endsWith('/mcp')) {
    return { baseUrl: trimmed.slice(0, -4).replace(/\/$/, ''), mcpUrl: trimmed };
  }
  return { baseUrl: trimmed, mcpUrl: `${trimmed}/mcp` };
}

const { baseUrl, mcpUrl } = normalizeTarget(rawTarget);

function byteLength(value) {
  return Buffer.byteLength(String(value || ''), 'utf8');
}

function formatBytes(bytes) {
  if (bytes >= 1024 * 1024) return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
  if (bytes >= 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${bytes} B`;
}

function sizeStatus(bytes) {
  if (bytes > largeThresholdBytes) return 'LARGE';
  if (bytes > okThresholdBytes) return 'WATCH';
  return 'OK';
}

function authHeaders(mode, token = authToken) {
  if (!token || mode === 'none') return {};
  if (mode === 'bearer') return { Authorization: `Bearer ${token}` };
  return { 'X-MCP-Auth-Token': token };
}

function classifyFailure(status, body, text, error) {
  if (error?.name === 'AbortError') return 'timeout';
  if (error) return 'network';
  const message = String(body?.error?.message || text || '');
  const code = body?.error?.code;
  if (status === 401 || code === -32001) return 'auth';
  if (status === 403) return 'cors';
  if (status === 404) return 'endpoint';
  if (status === 405) return 'protocol';
  if (status === 413 || message.toLowerCase().includes('too large')) return 'size';
  if (status >= 500 || code === -32603) return 'server';
  if (code === -32600 || code === -32601 || code === -32602 || code === -32000) return 'protocol';
  if (body?.error) return 'json-rpc';
  return 'unknown';
}

function record(ok, label, details = {}) {
  const row = { ok, label, ...details };
  rows.push(row);
  const mark = ok ? 'OK ' : 'FAIL';
  const suffix = details.message
    ? ` — ${details.message}`
    : details.classification
      ? ` — ${details.classification}`
      : '';
  console.log(`[${mark}] ${label}${suffix}`);
}

async function fetchText(url, init = {}, timeoutMs = 12_000) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(url, { ...init, signal: controller.signal });
    const text = await response.text();
    let json = null;
    try {
      json = text ? JSON.parse(text) : null;
    } catch {
      json = null;
    }
    return { response, text, json, bytes: byteLength(text) };
  } finally {
    clearTimeout(timer);
  }
}

async function rpc(method, params, mode, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
    ...authHeaders(mode),
  };
  if (options.protocolHeader !== false) headers['MCP-Protocol-Version'] = protocolVersion;

  const id = options.notification ? undefined : nextId++;
  const body = options.notification
    ? { jsonrpc: '2.0', method, params: params || {} }
    : { jsonrpc: '2.0', id, method, params };
  const { response, text, json, bytes } = await fetchText(mcpUrl, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
  if (!response.ok || json?.error) {
    const classification = classifyFailure(response.status, json, text);
    throw Object.assign(
      new Error(`${method} HTTP ${response.status}: ${JSON.stringify(json?.error || json || text).slice(0, 260)}`),
      { classification, status: response.status, bytes, details: json?.error || json || text },
    );
  }
  return { result: json?.result, status: response.status, bytes };
}

async function checkHealth() {
  try {
    const { response, json, bytes } = await fetchText(`${baseUrl}/health`);
    const ok = response.status === 200 && json?.ok === true && json?.transport === 'streamable-http';
    record(ok, '/health', {
      status: response.status,
      bytes,
      message: ok ? `${json.name}@${json.version} ${json.transport}` : `HTTP ${response.status}`,
    });
  } catch (error) {
    record(false, '/health', { classification: classifyFailure(0, null, '', error), message: error.message });
  }
}

async function infoLoad(mode) {
  const initialize = await rpc(
    'initialize',
    {
      protocolVersion,
      capabilities: {},
      clientInfo: { name: `playmcp-preflight-${mode}`, version: '0.1.0' },
    },
    mode,
    { protocolHeader: false },
  );
  await rpc('notifications/initialized', {}, mode, { notification: true });
  const list = await rpc('tools/list', {}, mode);
  const tools = list.result?.tools || [];
  const expectedNames = Object.keys(TOOL_SMOKE_FIXTURES).sort();
  const listedNames = tools.map((tool) => tool.name).sort();
  const namesMatch = JSON.stringify(listedNames) === JSON.stringify(expectedNames);
  const listStatus = sizeStatus(list.bytes);
  const descMissing = tools.filter((tool) => !tool.description || typeof tool.description !== 'string');
  const descNotEnglishFirst = tools.filter((tool) => !/^[A-Za-z0-9]/.test(String(tool.description || '').trim()));
  const ok =
    initialize.result?.serverInfo &&
    tools.length === expectedNames.length &&
    namesMatch &&
    descMissing.length === 0 &&
    descNotEnglishFirst.length === 0 &&
    listStatus !== 'LARGE';
  record(Boolean(ok), `정보 불러오기 (${mode})`, {
    status: list.status,
    bytes: list.bytes,
    sizeStatus: listStatus,
    message:
      `${tools.length} tools · tools/list ${formatBytes(list.bytes)} ${listStatus}` +
      (descNotEnglishFirst.length ? ` · non-English-first descriptions=${descNotEnglishFirst.length}` : ''),
  });
  return { tools, listBytes: list.bytes, listStatus };
}

async function representativeCall(mode) {
  const fixture = TOOL_SMOKE_FIXTURES[representativeTool];
  if (!fixture) {
    record(false, `대표 tools/call (${representativeTool})`, { message: 'fixture not found' });
    return;
  }
  try {
    const call = await rpc('tools/call', { name: representativeTool, arguments: fixture.args }, mode);
    const result = call.result || {};
    const ok = call.status === 200 && result.isError !== true && result.structuredContent && sizeStatus(call.bytes) !== 'LARGE';
    record(Boolean(ok), `대표 tools/call (${representativeTool}, ${mode})`, {
      status: call.status,
      bytes: call.bytes,
      sizeStatus: sizeStatus(call.bytes),
      message: `${formatBytes(call.bytes)} ${sizeStatus(call.bytes)} · structured=${Boolean(result.structuredContent)}`,
    });
  } catch (error) {
    record(false, `대표 tools/call (${representativeTool}, ${mode})`, {
      classification: error.classification || 'unknown',
      message: error.message,
    });
  }
}

async function checkAuthNegative() {
  if (!authToken) {
    record(true, 'auth negative paths skipped', { message: 'no MCP_PREFLIGHT_AUTH_TOKEN/MCP_AUTH_TOKEN' });
    return;
  }
  const body = JSON.stringify({ jsonrpc: '2.0', id: nextId++, method: 'tools/list', params: {} });
  const baseHeaders = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
    'MCP-Protocol-Version': protocolVersion,
  };
  const cases = [
    ['missing token', {}],
    ['wrong bearer token', { Authorization: 'Bearer wrong-token' }],
    ['wrong X-MCP-Auth-Token', { 'X-MCP-Auth-Token': 'wrong-token' }],
  ];
  for (const [label, headers] of cases) {
    const { response, text, json } = await fetchText(mcpUrl, {
      method: 'POST',
      headers: { ...baseHeaders, ...headers },
      body,
    });
    const classification = classifyFailure(response.status, json, text);
    record(response.status === 401 && classification === 'auth', `auth rejects ${label}`, {
      status: response.status,
      classification,
      message: `HTTP ${response.status} · ${classification}`,
    });
  }
}

async function checkClassifiedFailures(mode) {
  const endpoint = await fetchText(`${baseUrl}/not-found-for-playmcp-preflight`);
  record(endpoint.response.status === 404, '404 endpoint classification', {
    status: endpoint.response.status,
    classification: classifyFailure(endpoint.response.status, endpoint.json, endpoint.text),
    message: `HTTP ${endpoint.response.status}`,
  });

  const method = await fetchText(mcpUrl, { method: 'GET', headers: authHeaders(mode) });
  record(method.response.status === 405 && classifyFailure(method.response.status, method.json, method.text) === 'protocol', '405 protocol classification', {
    status: method.response.status,
    classification: classifyFailure(method.response.status, method.json, method.text),
    message: `HTTP ${method.response.status}`,
  });

  const cors = await fetchText(mcpUrl, {
    method: 'OPTIONS',
    headers: {
      Origin: 'http://evil.example',
      'Access-Control-Request-Method': 'POST',
      'Access-Control-Request-Headers': 'content-type,accept,mcp-protocol-version',
    },
  });
  record(cors.response.status === 403 && classifyFailure(cors.response.status, cors.json, cors.text) === 'cors', '403 CORS classification', {
    status: cors.response.status,
    classification: classifyFailure(cors.response.status, cors.json, cors.text),
    message: `HTTP ${cors.response.status}`,
  });

  const tooLargeBody = JSON.stringify({
    jsonrpc: '2.0',
    id: nextId++,
    method: 'tools/list',
    params: { padding: 'x'.repeat(maxBodyBytes + 256) },
  });
  const size = await fetchText(mcpUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json, text/event-stream',
      'MCP-Protocol-Version': protocolVersion,
      ...authHeaders(mode),
    },
    body: tooLargeBody,
  });
  record(size.response.status === 413 && classifyFailure(size.response.status, size.json, size.text) === 'size', '413 size classification', {
    status: size.response.status,
    classification: classifyFailure(size.response.status, size.json, size.text),
    message: `HTTP ${size.response.status}`,
  });
}

async function runAuthMode(mode) {
  try {
    await infoLoad(mode);
    await representativeCall(mode);
  } catch (error) {
    record(false, `정보 불러오기 (${mode})`, {
      classification: error.classification || 'unknown',
      message: error.message,
    });
  }
}

async function main() {
  validateConfiguration();
  const modes = authToken ? ['x-header', 'bearer'] : ['none'];
  console.log(`[playmcp-preflight] target=${mcpUrl}`);
  console.log(`[playmcp-preflight] authModes=${modes.join(', ')} representative=${representativeTool}`);

  await checkHealth();
  await checkAuthNegative();
  for (const mode of modes) {
    await runAuthMode(mode);
  }
  await checkClassifiedFailures(modes[0]);

  const failed = rows.filter((row) => !row.ok);
  const largest = rows
    .filter((row) => typeof row.bytes === 'number')
    .sort((a, b) => b.bytes - a.bytes)[0];
  if (largest) {
    console.log(`[playmcp-preflight] largest=${largest.label} ${formatBytes(largest.bytes)} ${largest.sizeStatus || sizeStatus(largest.bytes)}`);
  }
  if (failed.length > 0) {
    console.error(`[playmcp-preflight] failed ${failed.length}/${rows.length} gate(s)`);
    process.exit(1);
  }
  console.log(`[playmcp-preflight] passed ${rows.length}/${rows.length} gates`);
}

main().catch((error) => {
  console.error('[playmcp-preflight] fatal:', error instanceof Error ? error.message : String(error));
  process.exit(1);
});
