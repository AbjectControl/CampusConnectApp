import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class SnackbarService {
  // Use this key in MaterialApp
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    String? title,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title ?? _getTitle(contentType),
        message: message,
        contentType: contentType,
      ),
    );

    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(snackBar);
  }

  static String _getTitle(ContentType type) {
    if (type == ContentType.failure) return 'Oh Snap!';
    if (type == ContentType.success) return 'Success!';
    if (type == ContentType.warning) return 'Warning!';
    if (type == ContentType.help) return 'Info';
    return 'Notification';
  }

  static void success(String message, {String? title}) =>
      show(message, title: title, contentType: ContentType.success);

  static void error(String message, {String? title}) =>
      show(message, title: title, contentType: ContentType.failure);

  static void info(String message, {String? title}) =>
      show(message, title: title, contentType: ContentType.help);

  static void warning(String message, {String? title}) =>
      show(message, title: title, contentType: ContentType.warning);
}
