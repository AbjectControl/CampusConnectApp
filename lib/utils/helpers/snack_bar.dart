import 'package:flutter/material.dart';

class SnackbarService {
  // Use this key in MaterialApp
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    Color? backgroundColor,
    Duration? duration,
  }) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? Colors.black87,
      duration: duration ?? const Duration(seconds: 3),
    );
    messengerKey.currentState?.showSnackBar(snackbar);
  }

  static void success(String message) =>
      show(message, backgroundColor: Colors.green);

  static void error(String message) =>
      show(message, backgroundColor: Colors.redAccent);

  static void info(String message) =>
      show(message, backgroundColor: Colors.blueAccent);
}
