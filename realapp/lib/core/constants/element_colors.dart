import 'package:flutter/material.dart';

import '../domain/five_element.dart';

/// Design tokens for element colors (02 접근성 규칙: 색상 단독 구분 금지 —
/// 라벨/아이콘과 함께 사용한다).
class ElementColors {
  const ElementColors._();

  static const Color wood = Color(0xFF3E8E5A);
  static const Color fire = Color(0xFFD9553F);
  static const Color earth = Color(0xFFB98A3C);
  static const Color metal = Color(0xFF8C93A0);
  static const Color water = Color(0xFF3B6EA5);

  static Color of(FiveElement element) => switch (element) {
    FiveElement.wood => wood,
    FiveElement.fire => fire,
    FiveElement.earth => earth,
    FiveElement.metal => metal,
    FiveElement.water => water,
  };
}
