import 'package:flutter/material.dart';
import 'package:cconnect/utils/theme/Custom_themes/color_scheme.dart';

class CAppBarTheme {
  CAppBarTheme._();

  static final lightAppBarTheme = AppBarTheme(
    backgroundColor: CColorScheme.lightColorScheme.primary,
    foregroundColor: CColorScheme.lightColorScheme.onPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );

  static final darkAppBarTheme = AppBarTheme(
    backgroundColor: CColorScheme.darkColorScheme.primary,
    foregroundColor: CColorScheme.darkColorScheme.onPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
  );
}
