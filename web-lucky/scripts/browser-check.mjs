import { chromium } from 'playwright';
import fs from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';

const scratch =
  process.env.SCRATCH ||
  path.join(tmpdir(), 'web-lucky-browser-check');
const base = process.env.BASE_URL || 'http://127.0.0.1:4173';
const log = [];
fs.mkdirSync(scratch, { recursive: true });
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
page.on('pageerror', (e) => log.push('pageerror: ' + e.message));
page.on('console', (m) => {
  if (m.type() === 'error') log.push('console.error: ' + m.text());
});
await page.goto(base + '/?mode=tojeong', {
  waitUntil: 'networkidle',
  timeout: 30000,
});
const hasForm = await page.locator('#tojeong-form').count();
log.push('form_count=' + hasForm);
await page.fill('#birthDate', '1990-03-15');
await page.fill('#targetYear', '2026');
await page.click('[data-testid="tojeong-submit"]');
await page.waitForSelector('[data-testid="result-hero"]', { timeout: 15000 });
const monthCells = await page.locator('[data-testid^="month-cell-"]').count();
const disclaimer = await page.locator('[data-testid="disclaimer-shell"]').count();
const title = await page.locator('[data-testid="gwae-title"]').innerText();
log.push('month_cells=' + monthCells);
log.push('disclaimer=' + disclaimer);
log.push('title=' + title);
await page.screenshot({ path: `${scratch}/web-lucky-result.png`, fullPage: true });
fs.writeFileSync(`${scratch}/web-lucky-browser.log`, log.join('\n') + '\n');
await browser.close();
if (monthCells !== 12 || disclaimer < 1 || hasForm < 1) {
  console.error('browser assertion failed', log.join(' | '));
  process.exit(2);
}
console.log('browser ok', log.join(' | '));
