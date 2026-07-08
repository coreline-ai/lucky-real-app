/// 오행 분포 계산 (03 ElementBalance).
/// 가중치는 앱 설정이다: 천간 1.0, 지지 본기 1.0, 나머지 지장간 0.3.
/// Pure Dart — Flutter import 금지 레이어.
library;

import '../../core/domain/five_element.dart';
import '../gateway/models.dart';

const Map<String, FiveElement> ganElement = {
  '甲': FiveElement.wood,
  '乙': FiveElement.wood,
  '丙': FiveElement.fire,
  '丁': FiveElement.fire,
  '戊': FiveElement.earth,
  '己': FiveElement.earth,
  '庚': FiveElement.metal,
  '辛': FiveElement.metal,
  '壬': FiveElement.water,
  '癸': FiveElement.water,
};

/// 상생: 내가 생하는 오행.
const Map<FiveElement, FiveElement> saeng = {
  FiveElement.wood: FiveElement.fire,
  FiveElement.fire: FiveElement.earth,
  FiveElement.earth: FiveElement.metal,
  FiveElement.metal: FiveElement.water,
  FiveElement.water: FiveElement.wood,
};

/// 상극: 내가 극하는 오행.
const Map<FiveElement, FiveElement> geuk = {
  FiveElement.wood: FiveElement.earth,
  FiveElement.earth: FiveElement.water,
  FiveElement.water: FiveElement.fire,
  FiveElement.fire: FiveElement.metal,
  FiveElement.metal: FiveElement.wood,
};

const double _stemWeight = 1.0;
const double _mainHiddenStemWeight = 1.0;
const double _minorHiddenStemWeight = 0.3;

class ElementBalance {
  const ElementBalance(this.scores);

  final Map<FiveElement, double> scores;

  double get _total => scores.values
      .fold(0.0, (sum, v) => sum + v)
      .clamp(0.0001, double.infinity)
      .toDouble();

  /// 표시용 백분율 (합 100 근사).
  int percentOf(FiveElement element) =>
      ((scores[element] ?? 0) / _total * 100).round();

  /// 동률이면 목화토금수 고정 순서로 앞선 것을 택해 결정성을 보장한다.
  FiveElement get dominant => _pick((a, b) => a > b);

  FiveElement get weakest => _pick((a, b) => a < b);

  FiveElement _pick(bool Function(double, double) better) {
    var result = FiveElement.wood;
    var best = scores[result] ?? 0;
    for (final element in FiveElement.values) {
      final score = scores[element] ?? 0;
      if (better(score, best)) {
        result = element;
        best = score;
      }
    }
    return result;
  }

  /// [exclude]를 제외한 최약 오행 (다양성 보정용).
  FiveElement weakestExcluding(FiveElement exclude) {
    FiveElement? result;
    var best = double.infinity;
    for (final element in FiveElement.values) {
      if (element == exclude) continue;
      final score = scores[element] ?? 0;
      if (score < best) {
        result = element;
        best = score;
      }
    }
    return result ?? weakest;
  }
}

/// 원국의 오행 분포. 시주 미상이면 시주 항목은 자연히 빠진다.
ElementBalance calculateElementBalance(FourPillarsResult natal) {
  final scores = {for (final e in FiveElement.values) e: 0.0};

  void addGan(String gan, double weight) {
    final element = ganElement[gan];
    if (element != null) {
      scores[element] = scores[element]! + weight;
    }
  }

  for (final pillar in [natal.year, natal.month, natal.day, natal.hour]) {
    if (pillar == null) continue;
    addGan(pillar.gan, _stemWeight);
  }

  natal.jijanggan.forEach((position, hiddenStems) {
    for (var i = 0; i < hiddenStems.length; i++) {
      addGan(
        hiddenStems[i],
        i == 0 ? _mainHiddenStemWeight : _minorHiddenStemWeight,
      );
    }
  });

  return ElementBalance(scores);
}
