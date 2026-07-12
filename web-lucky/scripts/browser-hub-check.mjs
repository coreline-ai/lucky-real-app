import { chromium } from 'playwright';
import fs from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';

const scratch =
  process.env.SCRATCH ||
  path.join(tmpdir(), 'web-lucky-browser-hub-check');
const base = process.env.BASE_URL || 'http://127.0.0.1:4173';
const log = [];
fs.mkdirSync(scratch, { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
page.on('pageerror', (e) => log.push('pageerror: ' + e.message));
page.on('console', (m) => {
  if (m.type() === 'error') log.push('console.error: ' + m.text());
});

await page.goto(base + '/', { waitUntil: 'networkidle', timeout: 30000 });
const hubCount = await page.locator('[data-testid^="hub-card-"]').count();
log.push('hub_cards=' + hubCount);

const modes = [
  {
    id: 'iljin',
    open: async () => {
      await page.click('[data-testid="hub-card-iljin"]');
      await page.waitForSelector('[data-testid="iljin-result"]', {
        timeout: 15000,
      });
      const ganji = await page.locator('[data-testid="iljin-ganji"]').innerText();
      log.push('iljin_ganji=' + ganji);
    },
  },
  {
    id: 'chemi',
    open: async () => {
      await page.goto(base + '/?mode=chemi', { waitUntil: 'networkidle' });
      await page.click('[data-testid="chemi-submit"]');
      await page.waitForSelector('[data-testid="chemi-score"]', {
        timeout: 15000,
      });
      log.push(
        'chemi_score=' +
          (await page.locator('[data-testid="chemi-score"]').innerText()),
      );
    },
  },
  {
    id: 'naming',
    open: async () => {
      await page.goto(base + '/?mode=naming', { waitUntil: 'networkidle' });
      await page.click('[data-testid="naming-submit"]');
      await page.waitForSelector('[data-testid="naming-table"]', {
        timeout: 15000,
      });
      const rows = await page.locator('[data-testid="naming-table"] tbody tr').count();
      log.push('naming_rows=' + rows);
    },
  },
  {
    id: 'solar-terms',
    open: async () => {
      await page.goto(base + '/?mode=solar-terms', {
        waitUntil: 'networkidle',
      });
      await page.waitForSelector('[data-testid="term-list"]', {
        timeout: 15000,
      });
      const n = await page.locator('[data-testid="term-list"] li').count();
      log.push('terms=' + n);
    },
  },
  {
    id: 'tojeong',
    open: async () => {
      await page.goto(base + '/?mode=tojeong', { waitUntil: 'networkidle' });
      await page.fill('#birthDate', '1990-03-15');
      await page.fill('#targetYear', '2026');
      await page.click('[data-testid="tojeong-submit"]');
      await page.waitForSelector('[data-testid="result-hero"]', {
        timeout: 15000,
      });
      const months = await page.locator('[data-testid^="month-cell-"]').count();
      log.push('tojeong_months=' + months);
    },
  },
];

for (const m of modes) {
  await m.open();
  const disc = await page.locator('[data-testid="disclaimer-shell"]').count();
  log.push(m.id + '_disclaimer=' + disc);
  await page.click('[data-testid="nav-home"]');
  await page.waitForSelector('[data-testid="hub-grid"]', { timeout: 10000 });
}

await page.screenshot({
  path: `${scratch}/web-lucky-hub-browser.png`,
  fullPage: true,
});
fs.writeFileSync(`${scratch}/web-lucky-hub-browser.log`, log.join('\n') + '\n');
await browser.close();

if (hubCount !== 5) process.exit(2);
if (!log.some((l) => l.startsWith('tojeong_months=12'))) process.exit(3);
if (!log.some((l) => l.startsWith('naming_rows=2'))) process.exit(4);
console.log('browser hub ok\n' + log.join('\n'));
