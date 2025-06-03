import 'package:flutter/material.dart';
import 'package:dish_dash/components/toast_notification.dart';

class ToastManager {
  static OverlayEntry? _currentOverlayEntry;

  /// Shows a custom toast notification.
  /// [context] The BuildContext from which to show the toast.
  /// [message] The message to display in the toast.
  /// [icon] Optional icon to display.
  /// [backgroundColor] Optional background color for the toast.
  /// [textColor] Optional text color for the toast.
  /// [duration] How long the toast should be visible. Defaults to 3 seconds.
  static void showToast(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any existing toast before showing a new one
    dismissToast();

    _currentOverlayEntry = OverlayEntry(
      builder: (context) => ToastNotification(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        textColor: textColor ?? Colors.white,
      ),
    );

    Overlay.of(context).insert(_currentOverlayEntry!);

    // Automatically dismiss the toast after the specified duration
    Future.delayed(duration, () {
      dismissToast();
    });
  }

  /// Shows a success toast.
  static void showSuccessToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    showToast(
      context,
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: ToastNotification.success('').backgroundColor, // Use factory color
      textColor: ToastNotification.success('').textColor,
      duration: duration,
    );
  }

  /// Shows an error toast.
  static void showErrorToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    showToast(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: ToastNotification.error('').backgroundColor, // Use factory color
      textColor: ToastNotification.error('').textColor,
      duration: duration,
    );
  }

  /// Shows an info toast.
  static void showInfoToast(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    showToast(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: ToastNotification.info('').backgroundColor, // Use factory color
      textColor: ToastNotification.info('').textColor,
      duration: duration,
    );
  }

  /// Dismisses the currently visible toast, if any.
  static void dismissToast() {
    if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
      _currentOverlayEntry?.remove();
      _currentOverlayEntry = null;
    }
  }
}