import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiHelper {
  /// Call this for pages without an AppBar to set the status bar style
  static void setSystemUIOverlayFromContext(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // We use transparent status bar to let the AppBar color (White/Dark) show through.
    final Color statusBarColor = Colors.transparent;

    // In Light Mode (White BG), we need Dark Icons.
    // In Dark Mode (Dark BG), we need Light Icons.
    final Brightness iconBrightness = isDark
        ? Brightness.light
        : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: iconBrightness, // Android
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
    );
  }

  /// Returns a SystemUiOverlayStyle based on the current theme
  static SystemUiOverlayStyle getOverlayStyle(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // We use transparent status bar to let the AppBar color (White/Dark) show through.
    final Color statusBarColor = Colors.transparent;
    
    // In Light Mode (White BG), we need Dark Icons.
    // In Dark Mode (Dark BG), we need Light Icons.
    final Brightness iconBrightness = isDark
        ? Brightness.light
        : Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarIconBrightness: iconBrightness, // Android
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS: Light means dark content (confusingly)
    );
  }
}
