import {
  createBrowserShardedCalendar,
  type BrowserShardFetch,
} from 'manseryeok-engine/engine/browser';
import lunarSolarRaw from '../../engine/src/engine/core/data/lunar-solar.generated.json?raw';
import solarTermsRaw from '../../engine/src/engine/core/data/solar-terms.generated.json?raw';

type LunarSolarData = {
  solarToLunar: Record<string, [number, number, number, number]>;
  lunarToSolar: Record<string, [number, number, number]>;
};

const lunarSolar = JSON.parse(lunarSolarRaw) as LunarSolarData;
const solarTerms = JSON.parse(solarTermsRaw) as Record<string, unknown[]>;

function lunarShard(year: string) {
  return {
    solarToLunar: Object.fromEntries(
      Object.entries(lunarSolar.solarToLunar).filter(([key]) => key.startsWith(`${year}-`)),
    ),
    lunarToSolar: Object.fromEntries(
      Object.entries(lunarSolar.lunarToSolar).filter(([key]) => key.startsWith(`${year}-`)),
    ),
  };
}

function manifest() {
  const solarYears = Array.from(
    new Set(Object.keys(lunarSolar.solarToLunar).map((key) => Number(key.slice(0, 4)))),
  ).sort((a, b) => a - b);
  const lunarKeyYears = Array.from(
    new Set(Object.keys(lunarSolar.lunarToSolar).map((key) => Number(key.slice(0, 4)))),
  ).sort((a, b) => a - b);
  const lunarYears = Array.from(
    new Set([
      ...solarYears,
      ...lunarKeyYears,
    ]),
  ).sort((a, b) => a - b);
  const termYears = Object.keys(solarTerms).map(Number).sort((a, b) => a - b);
  const lunarShards = Object.fromEntries(lunarYears.map((year) => {
    const shard = lunarShard(String(year));
    return [String(year), {
      path: `lunar-solar/${year}.json`, bytes: 0, sha256: 'test',
      count: {
        solarToLunar: Object.keys(shard.solarToLunar).length,
        lunarToSolar: Object.keys(shard.lunarToSolar).length,
        total: Object.keys(shard.solarToLunar).length + Object.keys(shard.lunarToSolar).length,
      },
    }];
  }));
  return {
    version: 1,
    lunarSolar: {
      range: { startYear: lunarYears[0], endYear: lunarYears.at(-1) },
      solarToLunarRange: { startYear: solarYears[0], endYear: solarYears.at(-1) },
      lunarToSolarRange: { startYear: lunarKeyYears[0], endYear: lunarKeyYears.at(-1) },
      count: {
        solarToLunar: Object.keys(lunarSolar.solarToLunar).length,
        lunarToSolar: Object.keys(lunarSolar.lunarToSolar).length,
      },
      shards: lunarShards,
    },
    solarTerms: {
      range: { startYear: termYears[0], endYear: termYears.at(-1) },
      count: Object.values(solarTerms).reduce((sum, rows) => sum + rows.length, 0),
      shards: Object.fromEntries(termYears.map((year) => [String(year), {
        path: `solar-terms/${year}.json`, bytes: 0, sha256: 'test',
        count: solarTerms[String(year)].length,
      }])),
    },
  };
}

const testManifest = manifest();

export function createFixtureCalendar(requests: string[] = []) {
  const fetch: BrowserShardFetch = async (url) => {
    requests.push(url);
    const relativePath = url.replace(/^.*\/manseryeok-data\//, '');
    let json: unknown;
    if (relativePath === 'manifest.json') json = testManifest;
    else if (relativePath.startsWith('lunar-solar/')) {
      json = lunarShard(relativePath.match(/(\d{4})/)?.[1] ?? '');
    } else if (relativePath.startsWith('solar-terms/')) {
      json = solarTerms[relativePath.match(/(\d{4})/)?.[1] ?? ''];
    }
    if (json === undefined) return { ok: false, status: 404, json: async () => null };
    return { ok: true, status: 200, json: async () => json };
  };

  return createBrowserShardedCalendar({
    baseUrl: '/manseryeok-data',
    fetch,
  });
}
