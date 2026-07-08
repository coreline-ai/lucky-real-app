/// Five-element identity. Values follow 03-domain-data-spec.
///
/// Pure Dart: this file must stay importable from the engine layer
/// (no Flutter imports).
enum FiveElement { wood, fire, earth, metal, water }

extension FiveElementLabel on FiveElement {
  String get korean => switch (this) {
    FiveElement.wood => '목',
    FiveElement.fire => '화',
    FiveElement.earth => '토',
    FiveElement.metal => '금',
    FiveElement.water => '수',
  };
}
