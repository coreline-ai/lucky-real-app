import { chromium } from 'playwright';
import fs from 'node:fs';

const scratch =
  process.env.SCRATCH ||
  '/var/folders/z6/f_c51l451gb8xyydfbxy92hh0000gn/T/grok-goal-163a45f86bcb/implementer';
const log = [];
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
page.on('pageerror', (e) => log.push('pageerror: ' + e.message));
page.on('console', (m) => {
  if (m.type() === 'error') log.push('console.error: ' + m.text());
});
await page.goto('http://127.0.0.1:4173/', {
  waitUntil: 'networkidle',
  timeout: 30000,
});
const hasForm = await page.locator('#tojeong-form').count();
log.push('form_count=' + hasForm);
await page.fill('#birthDate', '1990-03-15');
await page.fill('#targetYear', '2026');
await page.click('#submit-btn');
await page.waitForSelector('[data-testid="result-hero"]', { timeout: 15000 });
const monthCells = await page.locator('[data-testid^="month-cell-"]').count();
const disclaimer = await page.locator('[data-testid="disclaimer-result"]').count();
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
