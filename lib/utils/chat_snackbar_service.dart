import 'package:flutter/material.dart';

class ChatSnackbarService {
  static void show({
    required BuildContext context,
    required String message,
    required TextStyle textStyle,
    Color? backgroundColor,
    SnackBarBehavior? behavior,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: textStyle),
        backgroundColor: backgroundColor,
        behavior: behavior,
        duration: duration,
      ),
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    required TextStyle textStyle,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context: context,
      message: message,
      textStyle: textStyle,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }
}
