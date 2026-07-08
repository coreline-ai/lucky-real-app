import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/core/constants/asset_paths.dart';
import 'package:ohaeng_guardians/core/domain/five_element.dart';

/// pubspec에 등록한 1차 에셋이 실제로 번들에 포함되는지 전건 확인한다
/// (에셋 연결 워크스트림 Phase 1 자체 테스트).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> expectLoadable(String path) async {
    final data = await rootBundle.load(path);
    expect(data.lengthInBytes, greaterThan(0), reason: path);
  }

  test(
    'pubspec runtime image assets stay WebP-only and exclude source trees',
    () {
      final assetLines = File('pubspec.yaml')
          .readAsLinesSync()
          .map((line) => line.trim())
          .where((line) => line.startsWith('- assets/'))
          .toList();

      expect(assetLines.where((line) => line.endsWith('.png')), isEmpty);
      expect(
        assetLines.where((line) => line.contains('imagegen_sources')),
        isEmpty,
      );
      expect(
        assetLines.where(
          (line) =>
              line.startsWith('- assets/market/') && !line.endsWith('.json'),
        ),
        isEmpty,
      );
      expect(assetLines, contains('- assets/market/kr_instruments.json'));
    },
  );

  test('static asset paths are bundled and loadable', () async {
    const paths = [
      AssetPaths.appIcon,
      AssetPaths.brandSplashSymbol,
      AssetPaths.splashBackground,
      AssetPaths.homeBackground,
      AssetPaths.onboardingGuardianIntro,
      AssetPaths.onboardingRoutineIntro,
      AssetPaths.onboardingCollectionRecord,
      AssetPaths.onboardingFirstReveal,
      AssetPaths.cardFrame,
      AssetPaths.cardBack,
      AssetPaths.homeGuardianCardFrame,
      AssetPaths.fortuneBanner,
      AssetPaths.marketTabBackground,
      AssetPaths.homeBalancePanel,
      AssetPaths.homeRoutineCta,
      AssetPaths.fortuneTabBackground,
      AssetPaths.routineTabBackground,
      AssetPaths.routineCompleteBadge,
      AssetPaths.collectionTabBackground,
      AssetPaths.collectionEmpty,
      AssetPaths.historyEmpty,
      AssetPaths.errorEngine,
      AssetPaths.settingsDataDelete,
      AssetPaths.settingsNotice,
      AssetPaths.chemistryResultBackground,
      AssetPaths.shareTodayGuardianTemplate,
      AssetPaths.shareChemistryTemplate,
      // 배경 B안: 운세 스트립 3종 + 기록/설정 배경
      AssetPaths.fortuneRelationshipStrip,
      AssetPaths.fortuneWorkStudyStrip,
      AssetPaths.fortuneConditionStrip,
      AssetPaths.historyBackground,
      AssetPaths.settingsBackground,
    ];
    for (final path in paths) {
      await expectLoadable(path);
    }
  });

  test(
    'market instrument master is bundled and has searchable symbols',
    () async {
      final text = await rootBundle.loadString(
        'assets/market/kr_instruments.json',
      );
      final payload = jsonDecode(text) as Map<String, dynamic>;
      final instruments = (payload['instruments'] as List)
          .cast<Map<String, dynamic>>();
      expect(instruments.length, greaterThan(1000));
      expect(
        instruments,
        contains(
          predicate<Map<String, dynamic>>(
            (row) => row['symbol'] == '005930' && row['name'] == '삼성전자',
          ),
        ),
      );
    },
  );

  test('per-element asset paths are bundled and loadable', () async {
    for (final element in FiveElement.values) {
      await expectLoadable(AssetPaths.guardianIdle(element));
      await expectLoadable(AssetPaths.elementBackground(element));
      await expectLoadable(AssetPaths.elementCardBackground(element));
      await expectLoadable(AssetPaths.elementWideBackground(element));
      await expectLoadable(AssetPaths.elementCardArt(element));
      await expectLoadable(AssetPaths.guardianCardArt(element));
      await expectLoadable(AssetPaths.guardianCardArtYin(element));
      await expectLoadable(AssetPaths.routineBanner(element));
    }
  });
}
