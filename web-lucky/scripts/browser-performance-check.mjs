import { chromium } from 'playwright';

const base = process.env.BASE_URL || 'http://127.0.0.1:4173';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();

await page.addInitScript(() => {
  window.__WEB_LUCKY_LONG_TASKS__ = [];
  if ('PerformanceObserver' in window) {
    const observer = new PerformanceObserver((list) => {
      for (const entry of list.getEntries()) {
        window.__WEB_LUCKY_LONG_TASKS__.push(entry.duration);
      }
    });
    try {
      observer.observe({ type: 'longtask', buffered: true });
    } catch {
      // A browser without Long Tasks support reports latency only.
    }
  }
});

async function measure(mode, trigger, resultSelector) {
  await page.goto(`${base}/?mode=${mode}`, {
    waitUntil: 'networkidle',
    timeout: 30000,
  });
  const before = await page.evaluate(() => performance.now());
  await trigger();
  await page.waitForSelector(resultSelector, { timeout: 15000 });
  const after = await page.evaluate(() => performance.now());
  return Math.round((after - before) * 10) / 10;
}

const latencyMs = {
  tojeong: await measure(
    'tojeong',
    async () => {
      await page.fill('#birthDate', '1990-03-15');
      await page.fill('#targetYear', '2026');
      await page.click('[data-testid="tojeong-submit"]');
    },
    '[data-testid="result-hero"]',
  ),
  chemi: await measure(
    'chemi',
    () => page.click('[data-testid="chemi-submit"]'),
    '[data-testid="chemi-score"]',
  ),
  naming: await measure(
    'naming',
    () => page.click('[data-testid="naming-submit"]'),
    '[data-testid="naming-table"]',
  ),
};

const longTasks = await page.evaluate(() => window.__WEB_LUCKY_LONG_TASKS__ ?? []);
const maxLongTaskMs = longTasks.length === 0 ? 0 : Math.max(...longTasks);
const result = { latencyMs, longTaskCount: longTasks.length, maxLongTaskMs };
console.log(JSON.stringify(result, null, 2));

await browser.close();
if (Object.values(latencyMs).some((value) => value > 1000) || maxLongTaskMs > 200) {
  process.exit(2);
}
