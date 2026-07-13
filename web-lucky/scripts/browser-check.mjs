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
const tojeongRequests = [];
page.on('request', (request) => tojeongRequests.push(request.url()));
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
const tojeongDataRequests = tojeongRequests.filter((url) =>
  url.includes('/manseryeok-data/'),
);
log.push('tojeong_data_requests=' + tojeongDataRequests.join(','));
const tojeongUnexpectedData = tojeongDataRequests.filter(
  (url) =>
    !url.endsWith('/manifest.json') &&
    !url.endsWith('/lunar-solar/1990.json'),
);
const tojeongMonolith = tojeongRequests.filter((url) =>
  /\/assets\/(?:manseryeok-engine|lunar-solar|solar-terms)-[^/]+\.js(?:\?|$)/.test(url),
);

const solarPage = await browser.newPage();
const solarRequests = [];
solarPage.on('request', (request) => solarRequests.push(request.url()));
await solarPage.goto(base + '/?mode=solar-terms', {
  waitUntil: 'networkidle',
  timeout: 30000,
});
await solarPage.waitForSelector('[data-testid="term-list"]', { timeout: 15000 });
const solarYearText = await solarPage.locator('[data-testid="solar-year"]').innerText();
const solarYear = Number.parseInt(solarYearText, 10);
const solarDataRequests = solarRequests.filter((url) =>
  url.includes('/manseryeok-data/'),
);
const solarUnexpectedData = solarDataRequests.filter(
  (url) =>
    !url.endsWith('/manifest.json') &&
    !url.endsWith(`/solar-terms/${solarYear}.json`),
);
const solarMonolith = solarRequests.filter((url) =>
  /\/assets\/(?:manseryeok-engine|lunar-solar)-[^/]+\.js(?:\?|$)/.test(url),
);
log.push('solar_data_requests=' + solarDataRequests.join(','));

const delayedYear = solarYear + 1;
await solarPage.route(`**/solar-terms/${delayedYear}.json`, async (route) => {
  await new Promise((resolve) => setTimeout(resolve, 300));
  await route.continue();
});
await solarPage.click('#year-next');
await solarPage.waitForSelector('[data-testid="loading"]');
await solarPage.click('#year-next');
await solarPage.waitForFunction(
  (expected) =>
    document.querySelector('[data-testid="solar-year"]')?.textContent?.includes(String(expected)),
  solarYear + 2,
  { timeout: 15000 },
);
await solarPage.waitForTimeout(400);
const rapidYearText = await solarPage.locator('[data-testid="solar-year"]').innerText();
const rapidYear = Number.parseInt(rapidYearText, 10);
log.push('rapid_solar_year=' + rapidYear);

const iljinPage = await browser.newPage();
await iljinPage.route('**/lunar-solar/*.json', async (route) => {
  await new Promise((resolve) => setTimeout(resolve, 300));
  await route.continue();
});
await iljinPage.goto(base + '/?mode=iljin', {
  waitUntil: 'domcontentloaded',
  timeout: 30000,
});
await iljinPage.waitForSelector('[data-testid="iljin-loading"]');
await iljinPage.click('[data-testid="nav-home"]');
await iljinPage.waitForSelector('[data-testid="hub-grid"]');
await iljinPage.waitForTimeout(400);
const iljinStayedHome = await iljinPage.locator('[data-testid="hub-grid"]').count() === 1;
log.push('iljin_stayed_home=' + iljinStayedHome);

const chemiPage = await browser.newPage();
await chemiPage.goto(base + '/?mode=chemi', {
  waitUntil: 'networkidle',
  timeout: 30000,
});
await chemiPage.route('**/lunar-solar/*.json', async (route) => {
  await new Promise((resolve) => setTimeout(resolve, 300));
  await route.continue();
});
await chemiPage.click('[data-testid="chemi-submit"]');
await chemiPage.waitForSelector('[data-testid="chemi-loading"]');
await chemiPage.click('[data-testid="nav-home"]');
await chemiPage.waitForSelector('[data-testid="hub-grid"]');
await chemiPage.waitForTimeout(400);
const chemiStayedHome = await chemiPage.locator('[data-testid="hub-grid"]').count() === 1;
log.push('chemi_stayed_home=' + chemiStayedHome);

await page.screenshot({ path: `${scratch}/web-lucky-result.png`, fullPage: true });
fs.writeFileSync(`${scratch}/web-lucky-browser.log`, log.join('\n') + '\n');
await browser.close();
if (
  monthCells !== 12 ||
  disclaimer < 1 ||
  hasForm < 1 ||
  !tojeongDataRequests.some((url) => url.endsWith('/lunar-solar/1990.json')) ||
  tojeongUnexpectedData.length > 0 ||
  tojeongMonolith.length > 0 ||
  !solarDataRequests.some((url) => url.endsWith(`/solar-terms/${solarYear}.json`)) ||
  solarUnexpectedData.length > 0 ||
  solarMonolith.length > 0 ||
  rapidYear !== solarYear + 2 ||
  !iljinStayedHome ||
  !chemiStayedHome
) {
  console.error('browser assertion failed', log.join(' | '));
  process.exit(2);
}
console.log('browser ok', log.join(' | '));
