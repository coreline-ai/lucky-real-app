import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSystemUiStyles {
  const AppSystemUiStyles._();

  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );
}
