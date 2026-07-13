import { execFileSync, spawnSync } from 'node:child_process';
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  createBrowserShardedCalendar,
  type BrowserShardFetch,
} from '@/engine/browser';
import lunarSolarData from '@/engine/core/data/lunar-solar.generated.json';
import solarTermsData from '@/engine/core/data/solar-terms.generated.json';
import { lunarToSolar, solarToLunar } from '@/engine/core/lunar-solar';
import { listSolarTermsForYear } from '@/engine/core/solar-terms';
import { getCalendarDay } from '@/engine/calendar';
import { calculateCompatibility } from '@/engine/compatibility';
import { calculatePalja } from '@/engine/saju/calculator';

const tempRoot = mkdtempSync(path.join(tmpdir(), 'manseryeok-browser-shards-'));
const outputA = path.join(tempRoot, 'a');
const outputB = path.join(tempRoot, 'b');
const baseUrl = 'https://example.test/manseryeok-data';

function generate(output: string) {
  return execFileSync(
    process.execPath,
    ['scripts/generate-browser-data-shards.mjs', '--output', output],
    { cwd: process.cwd(), encoding: 'utf8' },
  );
}

function listFiles(root: string, relative = ''): string[] {
  return readdirSync(path.join(root, relative))
    .flatMap((name) => {
      const child = path.join(relative, name);
      return statSync(path.join(root, child)).isDirectory() ? listFiles(root, child) : [child];
    })
    .sort();
}

function createFileFetch(
  counts = new Map<string, number>(),
  beforeRead?: (relativePath: string) => Promise<void>,
): BrowserShardFetch {
  return async (url) => {
    const relativePath = url.slice(`${baseUrl}/`.length);
    counts.set(relativePath, (counts.get(relativePath) ?? 0) + 1);
    await beforeRead?.(relativePath);
    try {
      const content = readFileSync(path.join(outputA, relativePath), 'utf8');
      return { ok: true, status: 200, json: async () => JSON.parse(content) };
    } catch {
      return { ok: false, status: 404, json: async () => ({}) };
    }
  };
}

beforeAll(() => {
  generate(outputA);
  generate(outputB);
});

afterAll(() => {
  rmSync(tempRoot, { recursive: true, force: true });
});

describe('browser data shard generator', () => {
  it('is deterministic and emits complete year/count/hash metadata', () => {
    const filesA = listFiles(outputA);
    const filesB = listFiles(outputB);
    expect(filesA).toEqual(filesB);
    for (const file of filesA) {
      expect(readFileSync(path.join(outputA, file))).toEqual(readFileSync(path.join(outputB, file)));
    }

    const manifest = JSON.parse(readFileSync(path.join(outputA, 'manifest.json'), 'utf8'));
    expect(manifest).toMatchObject({
      version: 1,
      lunarSolar: {
        range: { startYear: 1898, endYear: 2101 },
        solarToLunarRange: { startYear: 1899, endYear: 2101 },
        lunarToSolarRange: { startYear: 1898, endYear: 2101 },
        count: { solarToLunar: 74144, lunarToSolar: 74144 },
      },
      solarTerms: {
        range: { startYear: 1899, endYear: 2101 },
        count: 4872,
      },
    });
    expect(manifest.lunarSolar.shards['1898']).toMatchObject({
      path: 'lunar-solar/1898.json',
      count: { solarToLunar: 0, lunarToSolar: 40, total: 40 },
    });
    expect(manifest.lunarSolar.shards['2024'].sha256).toMatch(/^[a-f0-9]{64}$/);
    expect(manifest.lunarSolar.shards['2024'].bytes).toBeGreaterThan(0);
    expect(manifest.solarTerms.shards['2024']).toMatchObject({
      path: 'solar-terms/2024.json',
      count: 24,
    });
  }, 20_000);

  it('preserves every source record in the shard selected by key year', () => {
    const lunarSource = lunarSolarData as {
      solarToLunar: Record<string, unknown>;
      lunarToSolar: Record<string, unknown>;
    };
    let solarCount = 0;
    let lunarCount = 0;

    for (let year = 1898; year <= 2101; year += 1) {
      const shard = JSON.parse(readFileSync(path.join(outputA, 'lunar-solar', `${year}.json`), 'utf8'));
      for (const [key, value] of Object.entries(shard.solarToLunar)) {
        expect(key.startsWith(`${year}-`)).toBe(true);
        expect(value).toEqual(lunarSource.solarToLunar[key]);
        solarCount += 1;
      }
      for (const [key, value] of Object.entries(shard.lunarToSolar)) {
        expect(key.startsWith(`${year}-`)).toBe(true);
        expect(value).toEqual(lunarSource.lunarToSolar[key]);
        lunarCount += 1;
      }
    }

    expect(solarCount).toBe(Object.keys(lunarSource.solarToLunar).length);
    expect(lunarCount).toBe(Object.keys(lunarSource.lunarToSolar).length);
    expect(JSON.parse(readFileSync(path.join(outputA, 'solar-terms', '2024.json'), 'utf8')))
      .toEqual((solarTermsData as Record<string, unknown>)['2024']);
  });

  it('refuses to clean a non-generated output directory', () => {
    const unsafeOutput = path.join(tempRoot, 'unsafe-output');
    const sentinel = path.join(unsafeOutput, 'keep-me.txt');
    mkdirSync(unsafeOutput, { recursive: true });
    writeFileSync(sentinel, 'do not delete');

    const result = spawnSync(
      process.execPath,
      ['scripts/generate-browser-data-shards.mjs', '--output', unsafeOutput],
      { cwd: process.cwd(), encoding: 'utf8' },
    );
    expect(result.status).not.toBe(0);
    expect(result.stderr).toContain('unmanaged files');
    expect(existsSync(sentinel)).toBe(true);
    expect(readFileSync(sentinel, 'utf8')).toBe('do not delete');
  });
});

describe('browser sharded calendar loader', () => {
  it('matches sync conversion at normal, leap-month, and 1898/1899 boundaries', async () => {
    const calendar = createBrowserShardedCalendar({ baseUrl, fetch: createFileFetch() });
    const solarInputs = [
      { year: 1899, month: 1, day: 1, hour: 12 },
      { year: 2024, month: 2, day: 10, minute: 30 },
      { year: 2101, month: 12, day: 31 },
    ];
    const lunarInputs = [
      { year: 1898, month: 11, day: 20, isLeapMonth: false },
      { year: 2023, month: 2, day: 1, isLeapMonth: true, second: 45 },
      { year: 2101, month: 11, day: 12, isLeapMonth: false },
    ];

    for (const input of solarInputs) {
      await expect(calendar.solarToLunarAsync(input)).resolves.toEqual(solarToLunar(input));
    }
    for (const input of lunarInputs) {
      await expect(calendar.lunarToSolarAsync(input)).resolves.toEqual(lunarToSolar(input));
    }
  });

  it('matches normalized sync solar terms across the supported range', async () => {
    const calendar = createBrowserShardedCalendar({ baseUrl, fetch: createFileFetch() });
    for (const year of [1899, 2024, 2101]) {
      await expect(calendar.listSolarTermsForYearAsync(year)).resolves.toEqual(listSolarTermsForYear(year));
    }
  });

  it('matches sync calendar day, palja, and compatibility wrappers', async () => {
    const calendar = createBrowserShardedCalendar({ baseUrl, fetch: createFileFetch() });
    await expect(calendar.getCalendarDayAsync(2026, 7, 9)).resolves.toEqual(getCalendarDay(2026, 7, 9));

    const person1 = {
      year: 1990,
      month: 3,
      day: 15,
      hour: 14,
      minute: 30,
      gender: 'male' as const,
      isLunar: false,
      isLeapMonth: false,
    };
    const person2 = {
      year: 1992,
      month: 7,
      day: 21,
      hour: 9,
      minute: 0,
      gender: 'female' as const,
      isLunar: false,
      isLeapMonth: false,
    };

    await expect(calendar.calculatePaljaAsync(person1)).resolves.toEqual(
      calculatePalja({ ...person1, birthPlace: null }),
    );
    await expect(calendar.calculateCompatibilityAsync(person1, person2)).resolves.toEqual(
      calculateCompatibility({ person1, person2 }),
    );
  });

  it('uses memory caching and deduplicates concurrent requests', async () => {
    const counts = new Map<string, number>();
    let release2024: (() => void) | undefined;
    const waitForRelease = new Promise<void>((resolve) => { release2024 = resolve; });
    const calendar = createBrowserShardedCalendar({
      baseUrl,
      fetch: createFileFetch(counts, async (relativePath) => {
        if (relativePath === 'lunar-solar/2024.json') await waitForRelease;
      }),
    });

    const first = calendar.solarToLunarAsync({ year: 2024, month: 2, day: 10 });
    const second = calendar.solarToLunarAsync({ year: 2024, month: 3, day: 1 });
    await Promise.resolve();
    release2024?.();
    await Promise.all([first, second]);
    await calendar.solarToLunarAsync({ year: 2024, month: 4, day: 1 });

    expect(counts.get('manifest.json')).toBe(1);
    expect(counts.get('lunar-solar/2024.json')).toBe(1);

    calendar.clearCache();
    await calendar.solarToLunarAsync({ year: 2024, month: 5, day: 1 });
    expect(counts.get('manifest.json')).toBe(2);
    expect(counts.get('lunar-solar/2024.json')).toBe(2);
  });

  it('rejects unsafe or unsupported years before constructing a shard path', async () => {
    const counts = new Map<string, number>();
    const calendar = createBrowserShardedCalendar({ baseUrl, fetch: createFileFetch(counts) });

    await expect(calendar.solarToLunarAsync({
      year: '../../2024' as unknown as number,
      month: 1,
      day: 1,
    })).rejects.toThrow('Invalid solar year');
    await expect(calendar.lunarToSolarAsync({
      year: 1897,
      month: 12,
      day: 1,
      isLeapMonth: false,
    })).rejects.toThrow('Unsupported lunar year');
    await expect(calendar.listSolarTermsForYearAsync(2102)).rejects.toThrow('Unsupported solar-term year');

    expect([...counts.keys()].some((key) => key.includes('..'))).toBe(false);
  });
});
