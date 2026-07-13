#!/usr/bin/env node
import { spawn } from 'node:child_process';
import { createRequire } from 'node:module';
import http from 'node:http';
import net from 'node:net';
import path from 'node:path';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import { CROSS_CHECK_FIXTURES } from './cross-check-fixtures.mjs';

const require = createRequire(import.meta.url);
const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const engineDist = path.join(repoRoot, 'engine', 'dist', 'index.js');
const mcpRoot = path.join(repoRoot, 'mcp-server');
const mcpHttp = path.join(mcpRoot, 'dist', 'http.js');
const protocolVersion = '2025-11-25';
const authToken = 'cross-check-local-token';

if (!existsSync(engineDist)) {
  throw new Error('engine/dist/index.js가 없습니다. 먼저 npm --prefix engine run build를 실행해 주세요.');
}
if (!existsSync(mcpHttp)) {
  throw new Error('mcp-server/dist/http.js가 없습니다. 먼저 npm --prefix mcp-server run build를 실행해 주세요.');
}

const engine = require(engineDist);
let nextId = 1;

class FixtureError extends Error {
  constructor(message) {
    super(message);
    this.name = 'FixtureError';
  }
}

function pick(value, keys) {
  const out = {};
  for (const key of keys) out[key] = value?.[key];
  return out;
}

function stable(value) {
  if (Array.isArray(value)) return value.map(stable);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([k, v]) => [k, stable(v)]));
  }
  return value;
}

function assertEqual(label, actual, expected) {
  const actualJson = JSON.stringify(stable(actual));
  const expectedJson = JSON.stringify(stable(expected));
  if (actualJson !== expectedJson) {
    throw new Error(`${label} mismatch\nactual:   ${actualJson}\nexpected: ${expectedJson}`);
  }
}

function birthToEngine(input) {
  return {
    year: input.year,
    month: input.month,
    day: input.day,
    hour: input.hour,
    minute: input.hour !== null ? (input.minute ?? 0) : null,
    gender: input.gender,
    isLunar: input.calendarType === 'lunar',
    isLeapMonth: Boolean(input.isLeapMonth),
    birthPlace: input.birthPlace ?? null,
    calculateOptions: {
      midnightMode: input.midnightMode ?? 'yaja',
      trueSolarTime: Boolean(input.trueSolarTime),
      ...(input.longitude !== undefined ? { longitude: input.longitude } : {}),
    },
  };
}

function directExpected(fixture) {
  const args = fixture.args;
  if (fixture.compare === 'calendarDay') {
    return pick(engine.Calendar.getCalendarDay(args.year, args.month, args.day), [
      'solarDate',
      'lunarDate',
      'lunarMonth',
      'lunarDay',
      'isLeapMonth',
      'dayGanJi',
      'ohaeng',
      'sinsal12',
      'gilhyung',
      'taekil',
      'jieqi',
    ]);
  }
  if (fixture.compare === 'dateConvert') {
    const result =
      args.direction === 'solar_to_lunar'
        ? engine.solarToLunar({ year: args.year, month: args.month, day: args.day })
        : engine.lunarToSolar({
            year: args.year,
            month: args.month,
            day: args.day,
            isLeapMonth: Boolean(args.isLeapMonth),
          });
    return pick(result, ['year', 'month', 'day', 'isLeapMonth']);
  }
  if (fixture.compare === 'solarTerms') {
    return engine.getSolarTermsOnDate(args.year, args.month, args.day).map((term) =>
      pick(term, ['sourceName', 'koreanName', 'year', 'month', 'day', 'hour', 'minute', 'second', 'julianDay']),
    );
  }
  if (fixture.compare === 'tojeongYearly') {
    const lunarBirth =
      args.birth.calendarType === 'lunar'
        ? pick(args.birth, ['year', 'month', 'day', 'isLeapMonth'])
        : pick(engine.solarToLunar({ year: args.birth.year, month: args.birth.month, day: args.birth.day }), [
            'year',
            'month',
            'day',
            'isLeapMonth',
          ]);
    const result = engine.Tojeong.analyzeTojeong(lunarBirth.year, lunarBirth.month, lunarBirth.day, args.targetYear);
    return {
      lunarBirth,
      targetYear: args.targetYear,
      gwae: pick(result.gwae, ['gwaeCode', 'gwaeNumber']),
      title: result.interpretation.title,
      monthlyCount: result.interpretation.monthly.length,
      firstMonth: result.interpretation.monthly[0],
    };
  }
  if (fixture.compare === 'compatibility') {
    const result = engine.Compatibility.calculateCompatibility({
      person1: birthToEngine(args.person1),
      person2: birthToEngine(args.person2),
    });
    return {
      totalScore: result.totalScore,
      grade: result.grade,
      dayGanRelation: result.dayGanRelation.type,
      dayJiRelation: result.dayJiRelation.type,
      person1Palja: result.person1Palja,
      person2Palja: result.person2Palja,
    };
  }
  if (fixture.compare === 'palja') {
    const birth = args.birth;
    const result = engine.calculatePalja(birthToEngine(birth), {
      midnightMode: birth.midnightMode ?? 'yaja',
      trueSolarTime: Boolean(birth.trueSolarTime),
      ...(birth.longitude !== undefined ? { longitude: birth.longitude } : {}),
    });
    return {
      birthTimeKnown: birth.hour !== null,
      palja: result,
    };
  }
  if (fixture.compare === 'naming') {
    const result = engine.Naming.analyzeNamesExtended(args.surname, args.candidates, args.school ?? 'kangxi');
    return {
      school: result.school,
      candidateCount: result.candidates.length,
      first: pick(result.candidates[0], ['fullName', 'totalScore', 'grade']),
    };
  }
  throw new FixtureError(`Unknown compare type: ${fixture.compare}`);
}

function mcpComparable(fixture, structuredContent) {
  if (fixture.compare === 'calendarDay') {
    return pick(structuredContent.day, [
      'solarDate',
      'lunarDate',
      'lunarMonth',
      'lunarDay',
      'isLeapMonth',
      'dayGanJi',
      'ohaeng',
      'sinsal12',
      'gilhyung',
      'taekil',
      'jieqi',
    ]);
  }
  if (fixture.compare === 'dateConvert') {
    return pick(structuredContent.result, ['year', 'month', 'day', 'isLeapMonth']);
  }
  if (fixture.compare === 'solarTerms') {
    return structuredContent.terms.map((term) =>
      pick(term, ['sourceName', 'koreanName', 'year', 'month', 'day', 'hour', 'minute', 'second', 'julianDay']),
    );
  }
  if (fixture.compare === 'tojeongYearly') {
    return {
      lunarBirth: pick(structuredContent.lunarBirth, ['year', 'month', 'day', 'isLeapMonth']),
      targetYear: structuredContent.targetYear,
      gwae: pick(structuredContent.result.gwae, ['gwaeCode', 'gwaeNumber']),
      title: structuredContent.result.interpretation.title,
      monthlyCount: structuredContent.result.interpretation.monthly.length,
      firstMonth: structuredContent.result.interpretation.monthly[0],
    };
  }
  if (fixture.compare === 'compatibility') {
    const result = structuredContent.result;
    return {
      totalScore: result.totalScore,
      grade: result.grade,
      dayGanRelation: result.dayGanRelation.type,
      dayJiRelation: result.dayJiRelation.type,
      person1Palja: result.person1Palja,
      person2Palja: result.person2Palja,
    };
  }
  if (fixture.compare === 'palja') {
    return {
      birthTimeKnown: structuredContent.birthTimeKnown,
      palja: structuredContent.palja,
    };
  }
  if (fixture.compare === 'naming') {
    const result = structuredContent.result;
    return {
      school: result.school,
      candidateCount: result.candidates.length,
      first: pick(result.candidates[0], ['fullName', 'totalScore', 'grade']),
    };
  }
  throw new FixtureError(`Unknown compare type: ${fixture.compare}`);
}

async function freePort() {
  return new Promise((resolve, reject) => {
    const server = net.createServer();
    server.listen(0, '127.0.0.1', () => {
      const address = server.address();
      server.close(() => {
        if (address && typeof address === 'object') resolve(address.port);
        else reject(new Error('Could not allocate free port'));
      });
    });
    server.on('error', reject);
  });
}

function spawnServer(port) {
  return spawn('node', ['dist/http.js'], {
    cwd: mcpRoot,
    env: {
      ...process.env,
      PORT: String(port),
      HOST: '127.0.0.1',
      ENABLE_DASHBOARD: 'false',
      MCP_AUTH_TOKEN: authToken,
    },
    stdio: process.env.CROSS_CHECK_VERBOSE ? 'inherit' : ['ignore', 'pipe', 'pipe'],
  });
}

async function waitForHealth(baseUrl, timeoutMs = 30_000) {
  const startedAt = Date.now();
  while (Date.now() - startedAt < timeoutMs) {
    try {
      await new Promise((resolve, reject) => {
        const req = http.get(`${baseUrl}/health`, (res) => {
          res.resume();
          if (res.statusCode === 200) resolve();
          else reject(new Error(`HTTP ${res.statusCode}`));
        });
        req.on('error', reject);
        req.setTimeout(1000, () => req.destroy(new Error('timeout')));
      });
      return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  }
  throw new Error(`Timed out waiting for ${baseUrl}/health`);
}

async function stopServer(child) {
  if (!child || child.exitCode !== null || child.signalCode !== null) return;
  child.kill('SIGTERM');
  await new Promise((resolve) => {
    const forceTimer = setTimeout(() => {
      if (child.exitCode === null && child.signalCode === null) child.kill('SIGKILL');
    }, 2500);
    const settleTimer = setTimeout(resolve, 5000);
    child.once('exit', () => {
      clearTimeout(forceTimer);
      clearTimeout(settleTimer);
      resolve();
    });
  });
}

async function callTool(baseUrl, name, args) {
  const response = await fetch(`${baseUrl}/mcp`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json, text/event-stream',
      'MCP-Protocol-Version': protocolVersion,
      Authorization: `Bearer ${authToken}`,
    },
    body: JSON.stringify({ jsonrpc: '2.0', id: nextId++, method: 'tools/call', params: { name, arguments: args } }),
  });
  const text = await response.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    throw new Error(`${name} returned non-JSON response: HTTP ${response.status} ${text.slice(0, 200)}`);
  }
  if (!response.ok || json.error) {
    throw new Error(`${name} failed: HTTP ${response.status} ${JSON.stringify(json.error ?? json).slice(0, 400)}`);
  }
  const structuredContent = json.result?.structuredContent;
  if (!structuredContent || typeof structuredContent !== 'object') {
    throw new Error(`${name} did not return structuredContent`);
  }
  return structuredContent;
}

async function main() {
  const port = await freePort();
  const baseUrl = `http://127.0.0.1:${port}`;
  const server = spawnServer(port);
  const rows = [];
  const failures = [];

  try {
    await waitForHealth(baseUrl);
    for (const fixture of CROSS_CHECK_FIXTURES) {
      let expected;
      let structuredContent;
      let actual;
      try {
        expected = directExpected(fixture);
      } catch (error) {
        failures.push({
          id: fixture.id,
          tool: fixture.tool,
          boundary: error instanceof FixtureError ? 'fixture' : 'engine',
          message: error instanceof Error ? error.message : String(error),
        });
        continue;
      }
      try {
        structuredContent = await callTool(baseUrl, fixture.tool, fixture.args);
        actual = mcpComparable(fixture, structuredContent);
      } catch (error) {
        failures.push({
          id: fixture.id,
          tool: fixture.tool,
          boundary: error instanceof FixtureError ? 'fixture' : 'mcp-wrapper',
          message: error instanceof Error ? error.message : String(error),
        });
        continue;
      }
      try {
        assertEqual(fixture.id, actual, expected);
        rows.push({ id: fixture.id, tool: fixture.tool, status: 'PASS' });
      } catch (error) {
        failures.push({
          id: fixture.id,
          tool: fixture.tool,
          boundary: 'mcp-wrapper',
          message: error instanceof Error ? error.message : String(error),
        });
      }
    }
  } finally {
    await stopServer(server);
  }

  console.log('[cross-check] engine direct vs MCP structuredContent');
  for (const row of rows) {
    console.log(`${row.status.padEnd(5)} ${row.tool.padEnd(22)} ${row.id}`);
  }
  for (const failure of failures) {
    console.error(`FAIL  ${failure.tool.padEnd(22)} ${failure.id} boundary=${failure.boundary}`);
    console.error(failure.message);
  }
  if (failures.length > 0) {
    console.error(`[cross-check] failed ${failures.length}/${CROSS_CHECK_FIXTURES.length}`);
    process.exit(1);
  }
  console.log(`[cross-check] passed ${rows.length}/${CROSS_CHECK_FIXTURES.length}`);
}

main().catch((error) => {
  console.error('[cross-check] fatal:', error instanceof Error ? error.message : String(error));
  process.exit(1);
});
