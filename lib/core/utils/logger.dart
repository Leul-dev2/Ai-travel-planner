// ─── Structured Logger ──────────────────────────────────────────────
// Centralized logging with levels and production filtering.

import 'package:logger/logger.dart' as pkg;

class AppLogger {
  static final pkg.Logger _logger = pkg.Logger(
    printer: pkg.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: pkg.DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: pkg.Level.debug,
  );

  static void debug(String message, [dynamic data]) {
    _logger.d('$message${data != null ? '\n$data' : ''}');
  }

  static void info(String message, [dynamic data]) {
    _logger.i('$message${data != null ? '\n$data' : ''}');
  }

  static void warning(String message, [dynamic data]) {
    _logger.w('$message${data != null ? '\n$data' : ''}');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Set log level for production
  static void setProductionMode() {
    pkg.Logger.level = pkg.Level.warning;
  }
}
