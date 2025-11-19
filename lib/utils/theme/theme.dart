import 'package:cconnect/utils/theme/Custom_themes/appbar_theme.dart';
import 'package:cconnect/utils/theme/Custom_themes/card_theme.dart';
import 'package:cconnect/utils/theme/Custom_themes/color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// Light Theme — Academic, clean, professional
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: CColorScheme.lightColorScheme,
    scaffoldBackgroundColor: CColorScheme.lightColorScheme.background,
    appBarTheme: CAppBarTheme.lightAppBarTheme,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF111827)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF334155)),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CColorScheme.lightColorScheme.primary,
        foregroundColor: CColorScheme.lightColorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardTheme: CCardTheme.lightCardTheme,
  );

  /// Dark Theme — Sleek and focused
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: CColorScheme.darkColorScheme,
    scaffoldBackgroundColor: CColorScheme.darkColorScheme.background,
    appBarTheme: CAppBarTheme.darkAppBarTheme,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFF8FAFC)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CColorScheme.darkColorScheme.primary,
        foregroundColor: CColorScheme.darkColorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    cardTheme: CCardTheme.darkCardTheme,
  );
}
