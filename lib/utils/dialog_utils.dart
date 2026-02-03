import 'package:flutter/material.dart';

/// Utility class for common dialog functionality
class DialogUtils {
  /// Dismisses the keyboard and closes the dialog with a small delay
  /// to ensure keyboard dismissal is processed before navigation
  static void dismissKeyboardAndPop(BuildContext context) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  /// Dismisses the keyboard and executes a callback with a small delay
  static void dismissKeyboardAndExecute(BuildContext context, VoidCallback callback) {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), callback);
  }

  /// Dismisses the keyboard immediately (useful for tap handlers)
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Creates a GestureDetector that dismisses keyboard on tap
  /// and optionally closes dialog when tapping outside content
  static Widget buildDialogGestureDetector({
    required Widget child,
    required BuildContext context,
    bool closeOnOutsideTap = false,
    VoidCallback? onOutsideTap,
  }) {
    return GestureDetector(
      onTap: () {
        dismissKeyboard(context);
        if (closeOnOutsideTap) {
          if (onOutsideTap != null) {
            onOutsideTap();
          } else {
            dismissKeyboardAndPop(context);
          }
        }
      },
      child: child,
    );
  }

  /// Wraps content in a GestureDetector that prevents tap propagation
  /// (useful for preventing dialog close when tapping on content)
  static Widget preventTapPropagation({required Widget child}) {
    return GestureDetector(
      onTap: () {
        // Prevent tap from bubbling up to parent GestureDetector
      },
      child: child,
    );
  }
}
