// lib/utils/logger.dart
import 'package:flutter/foundation.dart' show kReleaseMode, debugPrint, kIsWeb;

/// Simple log levels.
enum LogLevel { error, warn, info, success, normal }

/// Central logger with color + formatting controls.
class Logger {
  Logger({
    this.enabled = true,
    this.includeTimestamp = true,
    this.enableColors = true,
    this.printInRelease = true,
    this.nameWidth = 14,
  });

  /// Globally accessible instance (customize at app start if you like).
  static Logger instance = Logger();

  /// Master switch.
  bool enabled;

  /// Include ISO-ish timestamp prefix.
  bool includeTimestamp;

  /// Use ANSI colors when supported. (On web, we just keep plain text.)
  bool enableColors;

  /// If false, suppress logs in release mode.
  bool printInRelease;

  /// Pads the `name` field to align messages.
  final int nameWidth;

  // ANSI color codes (foreground).
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _white = '\x1B[37m';

  String _colorFor(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return _red;
      case LogLevel.success:
        return _green;
      case LogLevel.warn:
        return _yellow;
      case LogLevel.info:
        return _blue;
      case LogLevel.normal:
        return _white;
    }
  }

  void log(
      LogLevel level,
      String message, {
        String name = '',
        Object? error,
        StackTrace? stackTrace,
      }) {
    if (!enabled) return;
    if (kReleaseMode && !printInRelease) return;

    final ts = includeTimestamp ? _timestamp() : '';
    final tag = name.isEmpty ? '' : name.padRight(nameWidth);
    final prefix = [if (ts.isNotEmpty) ts, if (tag.isNotEmpty) tag].join('  ');
    final body = prefix.isEmpty ? message : '$prefix  $message';

    final colored = _maybeColor(level, body);

    // debugPrint throttles long lines for us.
    debugPrint(colored);

    if (error != null) {
      debugPrint(_maybeColor(level, '  └─ $error'));
    }
    if (stackTrace != null) {
      debugPrint(_maybeColor(level, stackTrace.toString()));
    }
  }

  // Convenience wrappers
  void error(String text, {String name = '📕 error', Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, text, name: name, error: error, stackTrace: stackTrace);

  void success(String text, {String name = '📗 success'}) =>
      log(LogLevel.success, text, name: name);

  void warn(String text, {String name = '📙 warning'}) =>
      log(LogLevel.warn, text, name: name);

  void info(String text, {String name = '📘 info'}) =>
      log(LogLevel.info, text, name: name);

  void normal(String text, {String name = '📓 normal'}) =>
      log(LogLevel.normal, text, name: name);

  // ------- helpers -------

  String _timestamp() {
    final now = DateTime.now();
    // 2025-10-18 14:03:07.123
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  String _maybeColor(LogLevel level, String text) {
    // Many IDE consoles support ANSI; browsers generally don't.
    if (!enableColors || kIsWeb) return text;
    final color = _colorFor(level);
    return '$color$text$_reset';
  }
}

/// ---------------------------
/// Drop-in top-level helpers.
/// Keep your existing API.
/// ---------------------------

void printError(dynamic text, {String name = '📕: error', Object? error, StackTrace? stackTrace}) =>
    Logger.instance.error(text.toString(), name: name, error: error, stackTrace: stackTrace);

void printSuccess(dynamic text, {String name = '📙: success'}) =>
    Logger.instance.success(text.toString(), name: name);

void printWarning(dynamic text, {String name = '📗: warning'}) =>
    Logger.instance.warn(text.toString(), name: name);

void printInfo(dynamic text, {String name = '📘: info'}) =>
    Logger.instance.info(text.toString(), name: name);

void printNormal(dynamic text, {String name = '📓: normal'}) =>
    Logger.instance.normal(text.toString(), name: name);
