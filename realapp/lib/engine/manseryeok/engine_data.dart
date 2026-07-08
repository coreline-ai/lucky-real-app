/// Parsed engine reference data (lunar-solar table + solar terms).
///
/// Data files ship as app assets (assets/engine/*.json, copied verbatim from
/// the TS engine). The loader is injected so `dart test` can read from the
/// filesystem while the app uses rootBundle — this layer stays Flutter-free.
library;

import 'dart:convert';

import 'solar_terms.dart';

typedef EngineAssetLoader = Future<String> Function(String assetPath);

const String lunarSolarAssetPath = 'assets/engine/lunar-solar.generated.json';
const String solarTermsAssetPath = 'assets/engine/solar-terms.generated.json';

class EngineData {
  EngineData._(this.solarToLunar, this.lunarToSolar, this._termsByYear);

  /// "yyyy-MM-dd" -> [lunarYear, lunarMonth, lunarDay, isLeap(0|1)]
  final Map<String, List<int>> solarToLunar;

  /// "yyyy-MM-dd-leap" -> [solarYear, solarMonth, solarDay]
  final Map<String, List<int>> lunarToSolar;

  /// Terms normalized to KST (source data is KST-1h; +60min applied at load,
  /// mirroring solar-terms.ts normalizeToKst).
  final Map<int, List<SolarTermInfo>> _termsByYear;

  List<SolarTermInfo> termsForYear(int year) =>
      _termsByYear[year] ?? const <SolarTermInfo>[];

  static Future<EngineData> load(EngineAssetLoader loader) async {
    final lunarJson =
        jsonDecode(await loader(lunarSolarAssetPath)) as Map<String, dynamic>;
    final termsJson =
        jsonDecode(await loader(solarTermsAssetPath)) as Map<String, dynamic>;

    Map<String, List<int>> castTable(dynamic raw) {
      return (raw as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as List).cast<int>()),
      );
    }

    final termsByYear = <int, List<SolarTermInfo>>{};
    termsJson.forEach((yearKey, rawTerms) {
      termsByYear[int.parse(yearKey)] = (rawTerms as List)
          .map(
            (raw) => SolarTermInfo.fromSourceJson(
              raw as Map<String, dynamic>,
            ).normalizedToKst(),
          )
          .toList(growable: false);
    });

    return EngineData._(
      castTable(lunarJson['solarToLunar']),
      castTable(lunarJson['lunarToSolar']),
      termsByYear,
    );
  }
}
