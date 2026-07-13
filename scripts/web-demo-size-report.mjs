#!/usr/bin/env node
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const targets = [
  { name: 'web-lucky', assetsDir: path.join(repoRoot, 'web-lucky', 'dist', 'assets') },
  { name: 'web-mcp-daily', assetsDir: path.join(repoRoot, 'web-mcp-daily', 'dist', 'assets') },
];

const metricDefinitions = {
  totalRawBytes: { label: 'total raw', env: 'TOTAL_RAW_BYTES' },
  totalGzipBytes: { label: 'total gzip', env: 'TOTAL_GZIP_BYTES' },
  largestRawBytes: { label: 'largest raw', env: 'LARGEST_RAW_BYTES' },
  largestGzipBytes: { label: 'largest gzip', env: 'LARGEST_GZIP_BYTES' },
};

function isTruthy(value) {
  return typeof value === 'string' && ['1', 'true', 'yes', 'on'].includes(value.trim().toLowerCase());
}

function optionValue(argv, index, name) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) throw new Error(`${name} requires a value`);
  return value;
}

function parseSize(value, label) {
  const match = String(value)
    .trim()
    .match(/^(\d+(?:\.\d+)?)\s*(B|KB|KIB|MB|MIB)?$/i);
  if (!match) throw new Error(`${label} must be bytes or a size such as 800KiB/5MiB: ${value}`);
  const unit = (match[2] || 'B').toUpperCase();
  const multiplier = { B: 1, KB: 1000, KIB: 1024, MB: 1000 ** 2, MIB: 1024 ** 2 }[unit];
  return Math.round(Number(match[1]) * multiplier);
}

function parseBudget(value, budgets, source = '--budget') {
  const separator = value.indexOf('=');
  if (separator < 1) throw new Error(`${source} must use <target>.<metric>=<size>`);
  const selector = value.slice(0, separator);
  const size = value.slice(separator + 1);
  const dot = selector.indexOf('.');
  const targetName = selector.slice(0, dot);
  const metric = selector.slice(dot + 1);
  if (!targets.some((target) => target.name === targetName)) {
    throw new Error(`${source} has unknown target: ${targetName}`);
  }
  if (!Object.hasOwn(metricDefinitions, metric)) {
    throw new Error(`${source} has unknown metric: ${metric}`);
  }
  budgets[targetName] ??= {};
  budgets[targetName][metric] = parseSize(size, source);
}

function envPrefix(targetName) {
  return `WEB_SIZE_${targetName.replaceAll('-', '_').toUpperCase()}_`;
}

function parseArgs(argv) {
  const args = {
    baselinePath: '',
    writeBaselinePath: '',
    budgets: {},
    failOnBudget: isTruthy(process.env.WEB_SIZE_FAIL_ON_BUDGET),
  };

  for (const target of targets) {
    for (const [metric, definition] of Object.entries(metricDefinitions)) {
      const envName = `${envPrefix(target.name)}${definition.env}`;
      if (process.env[envName]) {
        args.budgets[target.name] ??= {};
        args.budgets[target.name][metric] = parseSize(process.env[envName], envName);
      }
    }
  }

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--baseline') {
      args.baselinePath = optionValue(argv, index, arg);
      index += 1;
    } else if (arg.startsWith('--baseline=')) {
      args.baselinePath = arg.slice('--baseline='.length);
    } else if (arg === '--write-baseline') {
      args.writeBaselinePath = optionValue(argv, index, arg);
      index += 1;
    } else if (arg.startsWith('--write-baseline=')) {
      args.writeBaselinePath = arg.slice('--write-baseline='.length);
    } else if (arg === '--budget') {
      parseBudget(optionValue(argv, index, arg), args.budgets);
      index += 1;
    } else if (arg.startsWith('--budget=')) {
      parseBudget(arg.slice('--budget='.length), args.budgets);
    } else if (arg === '--fail-on-budget') {
      args.failOnBudget = true;
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
  console.log(`Usage: node scripts/web-demo-size-report.mjs [options]

Options:
  --baseline <file>        Compare current metrics with a JSON baseline.
  --write-baseline <file>  Write current metrics as a JSON baseline.
  --budget <rule>          Set a budget as <target>.<metric>=<size>; repeatable.
  --fail-on-budget         Exit non-zero when any configured budget is exceeded.
  --help                   Show this help.

Targets: web-lucky, web-mcp-daily
Metrics: totalRawBytes, totalGzipBytes, largestRawBytes, largestGzipBytes
Sizes: bytes by default; B, KB, KiB, MB, and MiB suffixes are supported.

Environment:
  WEB_SIZE_FAIL_ON_BUDGET=true
  WEB_SIZE_WEB_LUCKY_{TOTAL_RAW,TOTAL_GZIP,LARGEST_RAW,LARGEST_GZIP}_BYTES
  WEB_SIZE_WEB_MCP_DAILY_{TOTAL_RAW,TOTAL_GZIP,LARGEST_RAW,LARGEST_GZIP}_BYTES

Example:
  node scripts/web-demo-size-report.mjs --fail-on-budget \\
    --budget web-lucky.totalRawBytes=5.25MiB \\
    --budget web-mcp-daily.totalGzipBytes=24KiB
`);
}

function formatBytes(bytes) {
  if (bytes >= 1024 * 1024) return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
  if (bytes >= 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${bytes} B`;
}

function fileRows(assetsDir) {
  return readdirSync(assetsDir)
    .filter((name) => /\.(js|css|json|html|wasm)$/.test(name))
    .map((name) => {
      const file = path.join(assetsDir, name);
      const bytes = statSync(file).size;
      const gzipBytes = gzipSync(readFileSync(file)).length;
      return { name, bytes, gzipBytes };
    })
    .sort((a, b) => b.bytes - a.bytes);
}

function measureTarget(target) {
  const rows = fileRows(target.assetsDir);
  const totalRawBytes = rows.reduce((sum, row) => sum + row.bytes, 0);
  const totalGzipBytes = rows.reduce((sum, row) => sum + row.gzipBytes, 0);
  const largest = rows[0] ?? null;
  return {
    name: target.name,
    assets: rows.length,
    totalRawBytes,
    totalGzipBytes,
    largestRawBytes: largest?.bytes ?? 0,
    largestGzipBytes: largest?.gzipBytes ?? 0,
    largest: largest ? { ...largest } : null,
    files: rows,
  };
}

function printTarget(report) {
  console.log(`\n[web-size-report] ${report.name}`);
  console.log(`assets=${report.assets} total=${formatBytes(report.totalRawBytes)} gzip=${formatBytes(report.totalGzipBytes)}`);
  if (report.largest) {
    console.log(
      `largest=${report.largest.name} ${formatBytes(report.largest.bytes)} gzip=${formatBytes(report.largest.gzipBytes)}`,
    );
  }
  console.log('file'.padEnd(48), 'raw'.padStart(10), 'gzip'.padStart(10));
  console.log('-'.repeat(72));
  for (const row of report.files.slice(0, 12)) {
    console.log(row.name.padEnd(48), formatBytes(row.bytes).padStart(10), formatBytes(row.gzipBytes).padStart(10));
  }
}

function readBaseline(file) {
  if (!file) return null;
  if (!existsSync(file)) throw new Error(`Baseline file not found: ${file}`);
  const baseline = JSON.parse(readFileSync(file, 'utf8'));
  if (!Array.isArray(baseline.targets)) throw new Error(`Invalid baseline (targets array missing): ${file}`);
  return baseline;
}

function printBaselineDelta(reports, baseline) {
  if (!baseline) return;
  const previousTargets = new Map(baseline.targets.map((target) => [target.name, target]));
  console.log(`\n[web-size-report] baseline=${baseline.generatedAt || 'unknown'}`);
  console.log('target.metric'.padEnd(42), 'previous'.padStart(12), 'current'.padStart(12), 'delta'.padStart(12));
  console.log('-'.repeat(82));
  for (const report of reports) {
    const previous = previousTargets.get(report.name);
    for (const metric of Object.keys(metricDefinitions)) {
      const previousBytes = typeof previous?.[metric] === 'number' ? previous[metric] : null;
      const deltaBytes = previousBytes === null ? null : report[metric] - previousBytes;
      const delta = deltaBytes === null ? 'new' : `${deltaBytes >= 0 ? '+' : '-'}${formatBytes(Math.abs(deltaBytes))}`;
      console.log(
        `${report.name}.${metric}`.padEnd(42),
        (previousBytes === null ? '-' : formatBytes(previousBytes)).padStart(12),
        formatBytes(report[metric]).padStart(12),
        delta.padStart(12),
      );
    }
  }
}

function evaluateBudgets(reports, budgets) {
  const failures = [];
  const configured = [];
  for (const report of reports) {
    for (const [metric, limitBytes] of Object.entries(budgets[report.name] ?? {})) {
      const actualBytes = report[metric];
      const passed = actualBytes <= limitBytes;
      configured.push({ target: report.name, metric, actualBytes, limitBytes, passed });
      if (!passed) failures.push({ target: report.name, metric, actualBytes, limitBytes });
    }
  }
  if (configured.length > 0) {
    console.log('\n[web-size-report] budgets');
    for (const row of configured) {
      console.log(
        `${row.passed ? 'PASS' : 'FAIL'} ${row.target}.${row.metric} actual=${formatBytes(row.actualBytes)} limit=${formatBytes(row.limitBytes)}`,
      );
    }
  }
  return failures;
}

function baselineReport(reports) {
  return {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    targets: reports.map(({ files: _files, ...report }) => report),
  };
}

function writeBaseline(file, report) {
  if (!file) return;
  mkdirSync(path.dirname(path.resolve(file)), { recursive: true });
  writeFileSync(file, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`[web-size-report] wrote baseline ${file}`);
}

try {
  const cli = parseArgs(process.argv.slice(2));
  const reports = targets.map(measureTarget);
  for (const report of reports) printTarget(report);
  printBaselineDelta(reports, readBaseline(cli.baselinePath));
  const budgetFailures = evaluateBudgets(reports, cli.budgets);

  if (cli.failOnBudget && budgetFailures.length > 0) {
    console.error(`[web-size-report] ${budgetFailures.length} budget(s) exceeded; baseline not updated`);
    process.exitCode = 1;
  } else {
    writeBaseline(cli.writeBaselinePath, baselineReport(reports));
  }
} catch (error) {
  console.error('[web-size-report] fatal:', error instanceof Error ? error.message : String(error));
  console.error('[web-size-report] run web builds first: npm --prefix web-lucky run build && npm --prefix web-mcp-daily run build');
  process.exit(1);
}
