#!/usr/bin/env node
import { mkdtempSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const appRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const sourceExtensions = new Set(['.js', '.jsx', '.mjs', '.cjs', '.ts', '.tsx']);

const rules = [
  {
    id: 'engine-package-import',
    message: 'manseryeok-engine package imports are forbidden; call the MCP endpoint instead',
    pattern: /['"]manseryeok-engine(?:\/[^'"]*)?['"]/g,
  },
  {
    id: 'engine-relative-import',
    message: 'relative imports into ../engine are forbidden',
    pattern: /['"](?:\.\.\/)+engine(?:\/[^'"]*)?['"]/g,
  },
  {
    id: 'engine-source-import',
    message: 'engine/src imports are forbidden',
    pattern: /['"][^'"]*engine\/src(?:\/[^'"]*)?['"]/g,
  },
  {
    id: 'local-engine-fallback',
    message: 'local engine fallback symbols are forbidden; MCP failures must stay visible',
    pattern: /\b(?:localEngine|localFallback|engineFallback|fallbackToLocal|useLocalEngine|calculateLocally|computeLocally)\b/g,
  },
];

function optionValue(argv, index, name) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) throw new Error(`${name} requires a value`);
  return value;
}

function parseArgs(argv) {
  const args = { root: path.join(appRoot, 'src'), selfTest: false };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--root') {
      args.root = path.resolve(optionValue(argv, index, arg));
      index += 1;
    } else if (arg.startsWith('--root=')) {
      args.root = path.resolve(arg.slice('--root='.length));
    } else if (arg === '--self-test') {
      args.selfTest = true;
    } else if (arg === '--help' || arg === '-h') {
      console.log(`Usage: node scripts/mcp-only-guard.mjs [--root <src>] [--self-test]

Scans JavaScript/TypeScript sources for direct manseryeok-engine imports,
relative engine/src imports, and explicit local-engine fallback symbols.
README and other documentation files are not scanned.`);
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function sourceFiles(root) {
  const files = [];
  const visit = (directory) => {
    for (const entry of readdirSync(directory, { withFileTypes: true })) {
      const entryPath = path.join(directory, entry.name);
      if (entry.isDirectory()) visit(entryPath);
      else if (entry.isFile() && sourceExtensions.has(path.extname(entry.name))) files.push(entryPath);
    }
  };
  visit(root);
  return files.sort();
}

function lineAndColumn(content, offset) {
  const before = content.slice(0, offset);
  const lines = before.split('\n');
  return { line: lines.length, column: lines.at(-1).length + 1 };
}

function scanRoot(root) {
  const violations = [];
  for (const file of sourceFiles(root)) {
    const content = readFileSync(file, 'utf8');
    for (const rule of rules) {
      rule.pattern.lastIndex = 0;
      for (const match of content.matchAll(rule.pattern)) {
        const location = lineAndColumn(content, match.index ?? 0);
        violations.push({ file, ...location, rule: rule.id, message: rule.message, match: match[0] });
      }
    }
  }
  return violations;
}

function printViolations(root, violations) {
  for (const violation of violations) {
    console.error(
      `[mcp-only-guard] FAIL ${path.relative(root, violation.file)}:${violation.line}:${violation.column} ${violation.rule}: ${violation.message}`,
    );
  }
}

function runSelfTest() {
  const scratch = mkdtempSync(path.join(tmpdir(), 'web-mcp-only-guard-'));
  const cleanRoot = path.join(scratch, 'clean');
  const blockedRoot = path.join(scratch, 'blocked');
  mkdirSync(cleanRoot, { recursive: true });
  mkdirSync(blockedRoot, { recursive: true });

  try {
    writeFileSync(
      path.join(cleanRoot, 'client.ts'),
      `import { McpClient } from './mcp/client';\nexport const read = (fallback = '-') => new McpClient(fallback);\n`,
    );
    writeFileSync(path.join(cleanRoot, 'README.md'), `import { Calendar } from 'manseryeok-engine';\n`);
    writeFileSync(path.join(blockedRoot, 'package.ts'), `import { Calendar } from 'manseryeok-engine';\n`);
    writeFileSync(path.join(blockedRoot, 'relative.ts'), `const engine = await import('../../engine/src/index.js');\n`);
    writeFileSync(path.join(blockedRoot, 'fallback.ts'), `const localFallback = () => ({ source: 'local' });\n`);

    const cleanViolations = scanRoot(cleanRoot);
    const blockedViolations = scanRoot(blockedRoot);
    const blockedRules = new Set(blockedViolations.map((violation) => violation.rule));
    const expectedRules = ['engine-package-import', 'engine-relative-import', 'engine-source-import', 'local-engine-fallback'];
    if (cleanViolations.length > 0 || expectedRules.some((rule) => !blockedRules.has(rule))) {
      printViolations(scratch, [...cleanViolations, ...blockedViolations]);
      throw new Error(
        `self-test mismatch clean=${cleanViolations.length} blockedRules=${[...blockedRules].sort().join(',')}`,
      );
    }
    console.log(`[mcp-only-guard] self-test PASS clean=0 blocked=${blockedViolations.length}`);
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
}

try {
  const cli = parseArgs(process.argv.slice(2));
  if (cli.selfTest) {
    runSelfTest();
  } else {
    const violations = scanRoot(cli.root);
    if (violations.length > 0) {
      printViolations(cli.root, violations);
      console.error(`[mcp-only-guard] ${violations.length} violation(s) found`);
      process.exit(1);
    }
    console.log(`[mcp-only-guard] PASS files=${sourceFiles(cli.root).length} violations=0`);
  }
} catch (error) {
  console.error('[mcp-only-guard] fatal:', error instanceof Error ? error.message : String(error));
  process.exit(1);
}
