#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

let sharp;
try {
  sharp = require('sharp');
} catch (error) {
  console.error(
    'Missing dependency: sharp. Install it in a temp tool dir and run with NODE_PATH, e.g.\n' +
      '  mkdir -p /tmp/lucky_asset_tools && cd /tmp/lucky_asset_tools && npm init -y && npm install sharp\n' +
      '  NODE_PATH=/tmp/lucky_asset_tools/node_modules node realapp/assets/imagegen_sources/tools/optimize_apk_assets_webp.cjs --convert --verify --report',
  );
  process.exit(1);
}

const repoRoot = path.resolve(__dirname, '../../../..');
const appRoot = path.join(repoRoot, 'realapp');
const imageRoot = path.join(appRoot, 'assets/images');
const reportPath = path.join(
  appRoot,
  'assets/imagegen_sources/APK_ASSET_OPTIMIZATION_REPORT.md',
);

const elements = ['wood', 'fire', 'earth', 'metal', 'water'];
const registeredRoots = [
  'app_icon',
  'backgrounds',
  'cards',
  'collection',
  'effects',
  'errors',
  'guardians',
  'history',
  'onboarding',
  'settings',
];

const staticPngAssets = [
  'assets/images/app_icon/brand_app_icon_symbol_2048_v1.png',
  'assets/images/app_icon/brand_splash_symbol_2048_v1.png',
  'assets/images/backgrounds/splash_start_bg_1080x1920_v1.png',
  'assets/images/backgrounds/home_bg_default_1080x1920_v1.png',
  'assets/images/onboarding/onboarding_guardian_intro_1080x1920_v1.png',
  'assets/images/onboarding/onboarding_routine_intro_1080x1920_v1.png',
  'assets/images/onboarding/onboarding_collection_record_1080x1920_v1.png',
  'assets/images/onboarding/onboarding_first_guardian_reveal_1080x1920_v1.png',
  'assets/images/cards/card_frame_common_1080x1620_v2.png',
  'assets/images/cards/card_back_1080x1620_v2.png',
  'assets/images/cards/home_guardian_card_frame_1080x1620_v1.png',
  'assets/images/backgrounds/fortune_total_bg_1920x1080_v1.png',
  'assets/images/backgrounds/home_balance_panel_bg_1920x1080_v1.png',
  'assets/images/backgrounds/home_routine_cta_bg_1920x1080_v1.png',
  'assets/images/effects/routine_complete_badge_1024_v1.png',
  'assets/images/collection/collection_empty_1920x1080_v1.png',
  'assets/images/history/history_empty_illustration_1920x1080_v1.png',
  'assets/images/errors/error_engine_illustration_1920x1080_v1.png',
  'assets/images/settings/settings_data_delete_illustration_1920x1080_v1.png',
  'assets/images/settings/settings_entertainment_notice_1920x1080_v1.png',
];

function activePngAssets() {
  const dynamicAssets = elements.flatMap((element) => [
    `assets/images/cards/card_element_${element}_1080x1620_v1.png`,
    `assets/images/cards/card_guardian_${element}_yang_1080x1620_v1.png`,
    `assets/images/guardians/guardian_${element}_yang_idle_2048_v2.png`,
    `assets/images/backgrounds/element_bg_${element}_1080x1920_v1.png`,
    `assets/images/backgrounds/element_bg_${element}_card_1080x1620_v1.png`,
    `assets/images/backgrounds/element_bg_${element}_wide_1920x1080_v1.png`,
    `assets/images/backgrounds/routine_${element}_bg_1920x1080_v1.png`,
  ]);
  return [...staticPngAssets, ...dynamicAssets].sort();
}

function toWebpAsset(assetPath) {
  return assetPath.replace(/\.png$/, '.webp');
}

function abs(assetPath) {
  return path.join(appRoot, assetPath);
}

function mib(bytes) {
  return bytes / 1024 / 1024;
}

function formatMib(bytes) {
  return `${mib(bytes).toFixed(1)} MiB`;
}

function fileSize(assetPath) {
  return fs.statSync(abs(assetPath)).size;
}

function listFiles(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return listFiles(full);
    return full;
  });
}

function allRegisteredPngAssets() {
  return registeredRoots
    .flatMap((root) => listFiles(path.join(imageRoot, root)))
    .filter((file) => file.endsWith('.png'))
    .map((file) => path.relative(appRoot, file))
    .sort();
}

function webpOptions(assetPath) {
  if (assetPath.includes('/app_icon/')) {
    return { quality: 92, alphaQuality: 100, effort: 6, smartSubsample: true };
  }
  if (
    assetPath.includes('/guardians/') ||
    assetPath.includes('/effects/') ||
    assetPath.includes('card_frame') ||
    assetPath.includes('home_guardian_card_frame')
  ) {
    return { quality: 90, alphaQuality: 100, effort: 6, smartSubsample: true };
  }
  if (assetPath.includes('/cards/')) {
    return { quality: 84, alphaQuality: 100, effort: 6, smartSubsample: true };
  }
  return { quality: 82, alphaQuality: 100, effort: 6, smartSubsample: true };
}

async function convertAssets() {
  for (const sourceAsset of activePngAssets()) {
    const source = abs(sourceAsset);
    const target = abs(toWebpAsset(sourceAsset));
    fs.mkdirSync(path.dirname(target), { recursive: true });
    await sharp(source).webp(webpOptions(sourceAsset)).toFile(target);
  }
}

async function verifyAssets() {
  const failures = [];
  const rows = [];

  for (const sourceAsset of activePngAssets()) {
    const targetAsset = toWebpAsset(sourceAsset);
    const source = abs(sourceAsset);
    const target = abs(targetAsset);

    if (!fs.existsSync(source)) {
      failures.push(`${sourceAsset}: missing source PNG`);
      continue;
    }
    if (!fs.existsSync(target)) {
      failures.push(`${targetAsset}: missing WebP derivative`);
      continue;
    }

    const sourceMeta = await sharp(source).metadata();
    const targetMeta = await sharp(target).metadata();

    if (targetMeta.format !== 'webp') {
      failures.push(`${targetAsset}: expected WebP, got ${targetMeta.format}`);
    }
    if (sourceMeta.width !== targetMeta.width || sourceMeta.height !== targetMeta.height) {
      failures.push(
        `${targetAsset}: dimension mismatch ${sourceMeta.width}x${sourceMeta.height} -> ` +
          `${targetMeta.width}x${targetMeta.height}`,
      );
    }
    if (sourceMeta.hasAlpha && !targetMeta.hasAlpha) {
      failures.push(`${targetAsset}: source has alpha but WebP does not`);
    }

    const pngBytes = fs.statSync(source).size;
    const webpBytes = fs.statSync(target).size;
    rows.push({
      sourceAsset,
      targetAsset,
      width: sourceMeta.width,
      height: sourceMeta.height,
      sourceHasAlpha: Boolean(sourceMeta.hasAlpha),
      targetHasAlpha: Boolean(targetMeta.hasAlpha),
      pngBytes,
      webpBytes,
    });
  }

  return { failures, rows };
}

function writeReport(verification) {
  const usedPng = activePngAssets();
  const usedWebp = usedPng.map(toWebpAsset);
  const allPng = allRegisteredPngAssets();
  const usedSet = new Set(usedPng);
  const unusedBundledCandidates = allPng.filter((assetPath) => !usedSet.has(assetPath));
  const usedPngBytes = usedPng.reduce((sum, assetPath) => sum + fileSize(assetPath), 0);
  const usedWebpBytes = usedWebp.reduce((sum, assetPath) => sum + fileSize(assetPath), 0);
  const allRegisteredPngBytes = allPng.reduce((sum, assetPath) => sum + fileSize(assetPath), 0);
  const unusedBytes = unusedBundledCandidates.reduce(
    (sum, assetPath) => sum + fileSize(assetPath),
    0,
  );
  const convertedSavings = usedPngBytes - usedWebpBytes;
  const estimatedBundleSavings = unusedBytes + convertedSavings;

  const largestUnused = unusedBundledCandidates
    .map((assetPath) => ({ assetPath, bytes: fileSize(assetPath) }))
    .sort((a, b) => b.bytes - a.bytes)
    .slice(0, 12);

  const lines = [
    '# APK Asset Optimization Report',
    '',
    `Updated: ${new Date().toISOString()}`,
    '',
    '## Summary',
    '',
    `- Active runtime assets: ${usedPng.length}`,
    `- Folder-registered PNG candidates before optimization: ${allPng.length}`,
    `- Unused PNG candidates excluded from APK bundle: ${unusedBundledCandidates.length} (${formatMib(unusedBytes)})`,
    `- Active PNG source size: ${formatMib(usedPngBytes)}`,
    `- Active WebP bundle size: ${formatMib(usedWebpBytes)}`,
    `- WebP conversion savings on active assets: ${formatMib(convertedSavings)}`,
    `- Estimated image bundle savings: ${formatMib(estimatedBundleSavings)}`,
    `- Dimension verification: ${verification.failures.length === 0 ? 'PASS' : 'FAIL'}`,
    '',
    '## Runtime Policy',
    '',
    '- Flutter runtime paths use `.webp` derivatives listed individually in `realapp/pubspec.yaml`.',
    '- PNG files remain as source/reference assets and are not registered for the APK bundle.',
    '- Every WebP derivative must keep the same width and height as its PNG source.',
    '',
    '## Largest Excluded PNG Candidates',
    '',
    '| Size | Asset |',
    '|---:|---|',
    ...largestUnused.map(
      ({ assetPath, bytes }) => `| ${formatMib(bytes)} | \`${assetPath}\` |`,
    ),
    '',
    '## Verification Failures',
    '',
    ...(verification.failures.length === 0
      ? ['None.']
      : verification.failures.map((failure) => `- ${failure}`)),
    '',
  ];

  fs.writeFileSync(reportPath, `${lines.join('\n')}\n`);
}

async function main() {
  const args = new Set(process.argv.slice(2));
  if (args.has('--convert')) {
    await convertAssets();
  }

  const verification = await verifyAssets();

  if (args.has('--report')) {
    writeReport(verification);
  }

  const usedPng = activePngAssets();
  const usedWebp = usedPng.map(toWebpAsset);
  const activePngBytes = usedPng.reduce((sum, assetPath) => sum + fileSize(assetPath), 0);
  const activeWebpBytes = usedWebp
    .filter((assetPath) => fs.existsSync(abs(assetPath)))
    .reduce((sum, assetPath) => sum + fileSize(assetPath), 0);

  console.log(`active_assets=${usedPng.length}`);
  console.log(`active_png_size=${formatMib(activePngBytes)}`);
  console.log(`active_webp_size=${formatMib(activeWebpBytes)}`);
  console.log(`dimension_failures=${verification.failures.length}`);

  if (args.has('--print-pubspec-assets')) {
    for (const assetPath of usedWebp) {
      console.log(`    - ${assetPath}`);
    }
  }

  if (verification.failures.length > 0) {
    for (const failure of verification.failures) {
      console.error(failure);
    }
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
