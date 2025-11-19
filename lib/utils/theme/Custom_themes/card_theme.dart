import 'package:cconnect/utils/theme/Custom_themes/color_scheme.dart';
import 'package:flutter/material.dart';

class CCardTheme {
  CCardTheme._();

  static final lightCardTheme = CardThemeData(
    color: CColorScheme.lightColorScheme.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black12,
  );

  static final darkCardTheme = CardThemeData(
    color: CColorScheme.darkColorScheme.surface,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black45,
  );
}
