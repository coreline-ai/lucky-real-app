#!/usr/bin/env node
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';

import { TOOL_SMOKE_FIXTURES } from '../dist/dashboard.js';

const baseUrl = (process.env.MCP_SIZE_BASE_URL || process.env.MCP_SMOKE_BASE_URL || 'http://127.0.0.1:3100').replace(
  /\/$/,
  '',
);
const authToken = process.env.MCP_SIZE_AUTH_TOKEN || process.env.MCP_SMOKE_AUTH_TOKEN || process.env.MCP_AUTH_TOKEN || '';
const authMode = (process.env.MCP_SIZE_AUTH_MODE || 'x-header').trim().toLowerCase();
let okThresholdBytes = 0;
let largeThresholdBytes = 0;
const protocolVersion = '2025-11-25';
let nextId = 1;
const cli = parseArgs(process.argv.slice(2));

function isTruthy(value) {
  return typeof value === 'string' && ['1', 'true', 'yes', 'on'].includes(value.trim().toLowerCase());
}

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
  if (okThresholdBytes >= largeThresholdBytes) {
    throw new Error('MCP_SIZE_OK_BYTES must be smaller than MCP_SIZE_LARGE_BYTES');
  }
  if (authToken && authMode !== 'x-header' && authMode !== 'bearer') {
    throw new Error(`MCP_SIZE_AUTH_MODE must be x-header or bearer: ${authMode}`);
  }
}

function parseArgs(argv) {
  const args = {
    baselinePath: '',
    writeBaselinePath: '',
    failOnLarge: isTruthy(process.env.MCP_SIZE_FAIL_ON_LARGE),
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--baseline') {
      args.baselinePath = argv[index + 1] || '';
      index += 1;
    } else if (arg.startsWith('--baseline=')) {
      args.baselinePath = arg.slice('--baseline='.length);
    } else if (arg === '--write-baseline') {
      args.writeBaselinePath = argv[index + 1] || '';
      index += 1;
    } else if (arg.startsWith('--write-baseline=')) {
      args.writeBaselinePath = arg.slice('--write-baseline='.length);
    } else if (arg === '--fail-on-large') {
      args.failOnLarge = true;
    } else if (arg === '--help' || arg === '-h') {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return args;
}

function printHelp() {
  console.log(`Usage: node scripts/tool-response-size-report.mjs [options]

Options:
  --baseline <file>        Compare response sizes with a previous JSON baseline.
  --write-baseline <file>  Write the current response-size report as JSON.
  --fail-on-large          Exit non-zero if any response is LARGE.
  --help                   Show this help.

Environment:
  MCP_SIZE_OK_BYTES        OK threshold, default 32768.
  MCP_SIZE_LARGE_BYTES     LARGE threshold, default 102400.
  MCP_SIZE_AUTH_MODE       x-header(default) or bearer.
`);
}

function authHeaders(token = authToken) {
  if (!token) return {};
  if (authMode === 'bearer') return { Authorization: `Bearer ${token}` };
  return { 'X-MCP-Auth-Token': token };
}

function bytesOf(value) {
  if (value === undefined) return 0;
  if (typeof value === 'string') return Buffer.byteLength(value, 'utf8');
  return Buffer.byteLength(JSON.stringify(value), 'utf8');
}

function formatBytes(bytes) {
  if (bytes >= 1024 * 1024) return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
  if (bytes >= 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${bytes} B`;
}

function statusFor(bytes) {
  if (bytes > largeThresholdBytes) return 'LARGE';
  if (bytes > okThresholdBytes) return 'WATCH';
  return 'OK';
}

async function rpc(method, params) {
  const response = await fetch(`${baseUrl}/mcp`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json, text/event-stream',
      'MCP-Protocol-Version': protocolVersion,
      ...authHeaders(),
    },
    body: JSON.stringify({ jsonrpc: '2.0', id: nextId++, method, params }),
  });
  const text = await response.text();
  const responseBytes = Buffer.byteLength(text, 'utf8');
  let json;
  try {
    json = text ? JSON.parse(text) : null;
  } catch {
    json = null;
  }
  if (!response.ok || json?.error) {
    const error = JSON.stringify(json?.error || json || text).slice(0, 260);
    throw new Error(`${method} HTTP ${response.status}: ${error}`);
  }
  return { json, result: json.result, responseBytes };
}

function rowFor(name, responseBytes, result) {
  return {
    name,
    status: statusFor(responseBytes),
    responseBytes,
    resultBytes: bytesOf(result),
    structuredBytes: bytesOf(result?.structuredContent),
    contentBytes: bytesOf(result?.content),
  };
}

function printRows(rows) {
  const nameWidth = Math.max('tool'.length, ...rows.map((row) => row.name.length));
  const statusWidth = Math.max('status'.length, ...rows.map((row) => row.status.length));
  const header = [
    'tool'.padEnd(nameWidth),
    'status'.padEnd(statusWidth),
    'response'.padStart(10),
    'result'.padStart(10),
    'structured'.padStart(10),
    'content'.padStart(10),
  ].join('  ');
  console.log(header);
  console.log('-'.repeat(header.length));
  for (const row of rows) {
    console.log(
      [
        row.name.padEnd(nameWidth),
        row.status.padEnd(statusWidth),
        formatBytes(row.responseBytes).padStart(10),
        formatBytes(row.resultBytes).padStart(10),
        formatBytes(row.structuredBytes).padStart(10),
        formatBytes(row.contentBytes).padStart(10),
      ].join('  '),
    );
  }
}

function printSummary(rows) {
  const summary = rows.reduce(
    (acc, row) => {
      acc[row.status] += 1;
      return acc;
    },
    { OK: 0, WATCH: 0, LARGE: 0 },
  );
  const largest = rows[0];
  console.log('');
  console.log(
    `[mcp-size-report] summary OK=${summary.OK} WATCH=${summary.WATCH} LARGE=${summary.LARGE} largest=${largest.name} ${formatBytes(largest.responseBytes)}`,
  );
  console.log(
    `[mcp-size-report] thresholds OK<=${formatBytes(okThresholdBytes)} WATCH<=${formatBytes(largeThresholdBytes)} LARGE>${formatBytes(largeThresholdBytes)}`,
  );
}

function buildReport(rows, failures) {
  const summary = rows.reduce(
    (acc, row) => {
      acc[row.status] += 1;
      return acc;
    },
    { OK: 0, WATCH: 0, LARGE: 0 },
  );

  return {
    generatedAt: new Date().toISOString(),
    baseUrl,
    auth: authToken ? authMode : 'none',
    thresholds: {
      okBytes: okThresholdBytes,
      largeBytes: largeThresholdBytes,
    },
    summary,
    failures,
    rows,
  };
}

function readBaseline(file) {
  if (!file) return null;
  if (!existsSync(file)) throw new Error(`Baseline file not found: ${file}`);
  return JSON.parse(readFileSync(file, 'utf8'));
}

function printBaselineDelta(currentRows, baseline) {
  if (!baseline) return;
  const previousRows = new Map((baseline.rows || []).map((row) => [row.name, row]));
  const deltas = currentRows
    .map((row) => {
      const previous = previousRows.get(row.name);
      return {
        name: row.name,
        previousBytes: previous?.responseBytes ?? null,
        currentBytes: row.responseBytes,
        deltaBytes: previous ? row.responseBytes - previous.responseBytes : null,
      };
    })
    .sort((a, b) => Math.abs(b.deltaBytes ?? 0) - Math.abs(a.deltaBytes ?? 0));

  console.log('');
  console.log(`[mcp-size-report] baseline=${baseline.generatedAt || 'unknown'} rows=${baseline.rows?.length ?? 0}`);
  console.log('tool'.padEnd(28), 'previous'.padStart(10), 'current'.padStart(10), 'delta'.padStart(10));
  console.log('-'.repeat(64));
  for (const row of deltas.slice(0, 12)) {
    const previous = row.previousBytes == null ? '-' : formatBytes(row.previousBytes);
    const delta = row.deltaBytes == null ? 'new' : `${row.deltaBytes >= 0 ? '+' : '-'}${formatBytes(Math.abs(row.deltaBytes))}`;
    console.log(row.name.padEnd(28), previous.padStart(10), formatBytes(row.currentBytes).padStart(10), delta.padStart(10));
  }
}

function writeBaseline(file, report) {
  if (!file) return;
  mkdirSync(path.dirname(file), { recursive: true });
  writeFileSync(file, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`[mcp-size-report] wrote baseline ${file}`);
}

async function main() {
  validateConfiguration();
  console.log(`[mcp-size-report] target=${baseUrl}`);
  console.log(`[mcp-size-report] auth=${authToken ? authMode : 'none'} fixtures=${Object.keys(TOOL_SMOKE_FIXTURES).length}`);

  const rows = [];
  const failures = [];
  const list = await rpc('tools/list', {});
  rows.push(rowFor('tools/list', list.responseBytes, list.result));

  const listedNames = (list.result.tools || []).map((tool) => tool.name).sort();
  const fixtureNames = Object.keys(TOOL_SMOKE_FIXTURES).sort();
  if (JSON.stringify(listedNames) !== JSON.stringify(fixtureNames)) {
    throw new Error('tools/list does not match TOOL_SMOKE_FIXTURES');
  }

  for (const name of listedNames) {
    try {
      const result = await rpc('tools/call', { name, arguments: TOOL_SMOKE_FIXTURES[name].args });
      rows.push(rowFor(name, result.responseBytes, result.result));
    } catch (error) {
      failures.push(`${name}: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  rows.sort((a, b) => b.responseBytes - a.responseBytes);
  printRows(rows);
  printSummary(rows);
  const report = buildReport(rows, failures);
  printBaselineDelta(rows, readBaseline(cli.baselinePath));
  writeBaseline(cli.writeBaselinePath, report);

  if (cli.failOnLarge && rows.some((row) => row.status === 'LARGE')) {
    console.error('[mcp-size-report] LARGE response detected');
    process.exit(1);
  }

  if (failures.length > 0) {
    console.error('');
    for (const failure of failures) console.error(`[mcp-size-report] FAIL ${failure}`);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('[mcp-size-report] fatal:', error instanceof Error ? error.message : String(error));
  process.exit(1);
});
