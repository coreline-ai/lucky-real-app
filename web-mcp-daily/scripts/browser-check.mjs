import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { chromium } from 'playwright';

const appRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = path.resolve(appRoot, '..');
const mcpRoot = path.join(repoRoot, 'mcp-server');
const appPort = 5198;
const authAppPort = 5199;
const mcpPort = 3198;
const authMcpPort = 3199;
const authToken = 'browser-check-token';

function spawnProcess(command, args, options = {}) {
  const child = spawn(command, args, {
    cwd: options.cwd ?? repoRoot,
    env: { ...process.env, ...options.env },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  child.stdout.on('data', (chunk) => {
    if (process.env.BROWSER_CHECK_VERBOSE) process.stdout.write(chunk);
  });
  child.stderr.on('data', (chunk) => {
    if (process.env.BROWSER_CHECK_VERBOSE) process.stderr.write(chunk);
  });
  return child;
}

async function waitForHttp(url, timeoutMs = 30_000) {
  const startedAt = Date.now();
  while (Date.now() - startedAt < timeoutMs) {
    try {
      await new Promise((resolve, reject) => {
        const request = http.get(url, (response) => {
          response.resume();
          if (response.statusCode && response.statusCode >= 200 && response.statusCode < 500) {
            resolve();
          } else {
            reject(new Error(`HTTP ${response.statusCode}`));
          }
        });
        request.on('error', reject);
        request.setTimeout(1200, () => {
          request.destroy(new Error('timeout'));
        });
      });
      return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 300));
    }
  }
  throw new Error(`Timed out waiting for ${url}`);
}

async function stopProcess(child) {
  if (!child || child.killed) return;
  child.kill('SIGTERM');
  await new Promise((resolve) => {
    const timer = setTimeout(() => {
      if (!child.killed) child.kill('SIGKILL');
      resolve();
    }, 2500);
    child.once('exit', () => {
      clearTimeout(timer);
      resolve();
    });
  });
}

const tabChecks = [
  {
    id: 'daily',
    label: '오늘 운세 브리핑',
    expected: [
      '오늘 운세 브리핑',
      '오늘 모드',
      'calendar_day_info',
      'saju_palja',
      'saju_full_reading',
      'structured',
      '기본: palja + sipsin + sinsal + relations',
    ],
  },
  {
    id: 'weekly',
    label: '주간 운세',
    expected: ['주간 운세', '7일 일진 타임라인', 'calendar_day_info', 'saju_palja', 'saju_full_reading'],
  },
  {
    id: 'monthly',
    label: '월간 운세',
    expected: ['월간 운세', '월간 요약', 'calendar_month', 'saju_palja', 'saju_full_reading'],
  },
  {
    id: 'tojeong',
    label: '토정비결 연간 운세',
    expected: ['토정비결', '12개월 운세', 'tojeong_yearly'],
  },
  {
    id: 'deep',
    label: '대운/세운 깊이 분석',
    expected: ['대운/세운', '현재 대운', 'saju_daeun', 'saju_full_reading'],
  },
];

async function clickTab(page, tabId) {
  await page.locator(`[data-tab="${tabId}"]`).click();
  await page.waitForSelector('[data-status="idle"]', { timeout: 5000 });
}

async function runTabSuccessCheck(page, tab) {
  await clickTab(page, tab.id);
  await page.click('#topQuickTest');
  await page.waitForSelector('[data-status="success"]', { timeout: 30_000 });
  const text = await page.locator('body').innerText();
  for (const expected of ['로컬 MCP 테스트 모드', ...tab.expected]) {
    if (!text.includes(expected)) throw new Error(`Missing ${tab.label} success text: ${expected}`);
  }
}

async function runSuccessCheck(page, baseUrl) {
  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  for (const tab of tabChecks) {
    await runTabSuccessCheck(page, tab);
  }
}

async function openSettings(page) {
  await page.locator('#authSettings').evaluate((node) => {
    if (node instanceof HTMLDetailsElement) node.open = true;
  });
}

async function runCompactCheck(page, baseUrl) {
  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  await clickTab(page, 'daily');
  await openSettings(page);
  await page.selectOption('#includeMode', 'compact');
  await page.click('#submitBriefing');
  await page.waitForSelector('[data-status="success"]', { timeout: 20_000 });
  const text = await page.locator('body').innerText();
  for (const expected of ['compact: palja + sipsin', 'include sipsin', 'saju_full_reading']) {
    if (!text.includes(expected)) throw new Error(`Missing compact text: ${expected}`);
  }
}

async function runFailureCheck(page, baseUrl) {
  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  for (const tab of tabChecks) {
    await clickTab(page, tab.id);
    await page.click('#topQuickTest');
    await page.waitForSelector('[data-status="error"]', { timeout: 20_000 });
    const text = await page.locator('body').innerText();
    if (!text.includes(`${tab.label} 생성 실패`) && !text.includes('입력 또는 응답 처리 실패')) {
      throw new Error(`${tab.label} server off state did not show failure UI`);
    }
    if (text.includes('MCP 서버를 통해 생성됨')) {
      throw new Error(`${tab.label} server off state unexpectedly produced a briefing`);
    }
  }
}

async function runAuthFailureCheck(page, baseUrl) {
  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  await openSettings(page);
  await page.selectOption('#authMode', 'x-token');
  await page.fill('#authToken', 'wrong-token');
  await page.click('#submitBriefing');
  await page.waitForSelector('[data-status="error"]', { timeout: 20_000 });
  const text = await page.locator('body').innerText();
  if (!text.includes('auth')) throw new Error('Bad token state was not classified as auth');
}

async function runAuthSuccessCheck(page, baseUrl, token) {
  await openSettings(page);
  await page.selectOption('#authMode', 'x-token');
  await page.fill('#authToken', token);
  await page.click('#submitBriefing');
  await page.waitForSelector('[data-status="success"]', { timeout: 20_000 });
  const text = await page.locator('body').innerText();
  for (const expected of ['MCP 서버를 통해 생성됨', 'X-Token 인증', 'calendar_day_info']) {
    if (!text.includes(expected)) throw new Error(`Missing auth success text: ${expected}`);
  }
}

async function main() {
  if (!existsSync(path.join(mcpRoot, 'dist', 'http.js'))) {
    throw new Error('mcp-server/dist/http.js가 없습니다. 먼저 mcp-server build를 실행해 주세요.');
  }

  let mcpServer;
  let appServer;
  let authMcpServer;
  let authAppServer;
  let browser;

  try {
    mcpServer = spawnProcess('node', ['dist/http.js'], {
      cwd: mcpRoot,
      env: { PORT: String(mcpPort), HOST: '127.0.0.1', CORS_ORIGIN: `http://127.0.0.1:${appPort}` },
    });
    appServer = spawnProcess('npm', ['run', 'dev', '--', '--host', '127.0.0.1', '--port', String(appPort)], {
      cwd: appRoot,
      env: { MCP_HTTP_TARGET: `http://127.0.0.1:${mcpPort}`, VITE_MCP_URL: '/mcp' },
    });
    await waitForHttp(`http://127.0.0.1:${mcpPort}/health`);
    await waitForHttp(`http://127.0.0.1:${appPort}`);

    browser = await chromium.launch();
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
    await runSuccessCheck(page, `http://127.0.0.1:${appPort}`);
    await runCompactCheck(page, `http://127.0.0.1:${appPort}`);

    await stopProcess(mcpServer);
    mcpServer = undefined;
    await runFailureCheck(page, `http://127.0.0.1:${appPort}`);

    await stopProcess(appServer);
    appServer = undefined;

    authMcpServer = spawnProcess('node', ['dist/http.js'], {
      cwd: mcpRoot,
      env: {
        PORT: String(authMcpPort),
        HOST: '127.0.0.1',
        MCP_AUTH_TOKEN: authToken,
        CORS_ORIGIN: `http://127.0.0.1:${authAppPort}`,
      },
    });
    await waitForHttp(`http://127.0.0.1:${authMcpPort}/health`);

    authAppServer = spawnProcess('npm', ['run', 'dev', '--', '--host', '127.0.0.1', '--port', String(authAppPort)], {
      cwd: appRoot,
      env: {
        MCP_HTTP_TARGET: `http://127.0.0.1:${authMcpPort}`,
        VITE_MCP_URL: '/mcp',
      },
    });
    await waitForHttp(`http://127.0.0.1:${authAppPort}`);
    await runAuthFailureCheck(page, `http://127.0.0.1:${authAppPort}`);
    await runAuthSuccessCheck(page, `http://127.0.0.1:${authAppPort}`, authToken);

    console.log('web-mcp-daily browser check passed');
  } finally {
    if (browser) await browser.close();
    await stopProcess(authAppServer);
    await stopProcess(authMcpServer);
    await stopProcess(appServer);
    await stopProcess(mcpServer);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
