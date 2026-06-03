// ─── Context Extensions ─────────────────────────────────────────────
// Convenience extensions on BuildContext.

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // ── Theme ──
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ── Media Query ──
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  double get statusBarHeight => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;

  // ── Responsive ──
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // ── Snackbar ──
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? colorScheme.error
            : colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Loading Dialog ──
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }
}
