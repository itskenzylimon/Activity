// env_setup.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform, FileSystemException; // Safe on non-web targets only.
import 'package:flutter/foundation.dart' show kIsWeb, FlutterError;
import 'package:flutter/services.dart' show rootBundle;

/// Lightweight logger interface (to replace printError from your project).
abstract class EnvLogger {
  void info(String message);
  void warn(String message);
  void error(String message, [Object? err, StackTrace? st]);
}

/// Default logger that prints to console. Swap with your own.
class ConsoleEnvLogger implements EnvLogger {
  const ConsoleEnvLogger();
  @override
  void info(String message) => print('[ENV] $message');
  @override
  void warn(String message) => print('[ENV][WARN] $message');
  @override
  void error(String message, [Object? err, StackTrace? st]) {
    print('[ENV][ERROR] $message');
    if (err != null) print('  └─ $err');
    if (st != null) print(st);
  }
}

/// A flexible, cross-platform .env loader & accessor.
///
/// Features:
/// - Load from file (mobile/desktop/CLI) or from Flutter asset (web/mobile).
/// - Strict parser: supports quotes, escapes, and inline comments.
/// - Variable expansion: FOO="${BAR}_x", with cycle protection.
/// - Typed getters with defaults and clear errors.
/// - Merge/override maps and reload at runtime.
///
/// ⚠️ SECURITY NOTE:
/// Do not put production secrets in assets or the client app. Use server-side
/// config or remote config for sensitive values.
class ENVSetup {
  ENVSetup({EnvLogger? logger}) : _logger = logger ?? const ConsoleEnvLogger();

  final EnvLogger _logger;

  /// The in-memory environment map.
  final Map<String, String> _env = <String, String>{};

  /// Returns an unmodifiable snapshot of the current environment.
  Map<String, String> get values => Map.unmodifiable(_env);

  /// Clears all loaded values.
  void clear() => _env.clear();

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  /// Load from a .env **file path** (mobile/desktop/CLI only).
  ///
  /// Example: `await env.loadFile('.env');`
  ///
  /// If [overrideExisting] is false, existing keys are preserved.
  Future<void> loadFile(
      String filePath, {
        bool overrideExisting = true,
        bool expand = true,
      }) async {
    if (kIsWeb) {
      _logger.warn('loadFile("$filePath") ignored on Web. Use loadAsset() instead.');
      return;
    }
    final file = File(filePath);
    if (!await file.exists()) {
      _logger.error('ENV file not found at "$filePath"');
      throw FileSystemException('ENV file not found', filePath);
    }
    final contents = await file.readAsString();
    final parsed = _parse(contents);
    _merge(parsed, overrideExisting: overrideExisting);
    if (expand) _expandAll();
    _logger.info('Loaded ${parsed.length} keys from "$filePath".');
  }

  /// Load from a bundled Flutter **asset** (works on all platforms, incl. Web).
  ///
  /// Example:
  ///   1) Add to pubspec.yaml:
  ///        assets:
  ///          - assets/.env
  ///   2) `await env.loadAsset('assets/.env');`
  Future<void> loadAsset(
      String assetPath, {
        bool overrideExisting = true,
        bool expand = true,
      }) async {
    String contents;
    try {
      contents = await rootBundle.loadString(assetPath);
    } on FlutterError catch (e, st) {
      _logger.error('ENV asset not found: "$assetPath"', e, st);
      rethrow;
    }
    final parsed = _parse(contents);
    _merge(parsed, overrideExisting: overrideExisting);
    if (expand) _expandAll();
    _logger.info('Loaded ${parsed.length} keys from asset "$assetPath".');
  }

  /// Merge a map of env values (e.g., from CI secrets or overrides).
  void merge(Map<String, String> entries, {bool overrideExisting = true, bool expand = true}) {
    _merge(entries, overrideExisting: overrideExisting);
    if (expand) _expandAll();
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  /// Parse .env contents into a map.
  ///
  /// Supported formats:
  /// - KEY=VALUE
  /// - KEY="quoted value with spaces and \"escapes\""
  /// - KEY='single quoted'
  /// - KEY=bare_value # with inline comment
  /// - Empty lines and lines starting with `#` are ignored.
  Map<String, String> _parse(String contents) {
    final env = <String, String>{};
    final lines = const LineSplitter().convert(contents);

    final keyValueRegex = RegExp(r'^\s*([A-Za-z_][A-Za-z0-9_\.]*)\s*=\s*(.*)\s*$');

    for (var rawLine in lines) {
      var line = rawLine.trimRight();
      if (line.isEmpty || line.startsWith('#')) continue;

      final match = keyValueRegex.firstMatch(line);
      if (match == null) {
        _logger.warn('Skipping invalid line: $line');
        continue;
      }

      final key = match.group(1)!;
      var value = match.group(2) ?? '';

      // Handle quoted values
      if (value.startsWith('"')) {
        // Double-quoted: supports escapes and can contain '#'
        value = _unescapeDoubleQuoted(_stripMatchingQuotes(value, '"'));
      } else if (value.startsWith("'")) {
        // Single-quoted: literal, no escapes
        value = _stripMatchingQuotes(value, "'");
      } else {
        // Bare value: stop at unescaped '#'
        final hash = _indexOfUnescapedHash(value);
        if (hash != -1) value = value.substring(0, hash);
        value = value.trim();
      }

      env[key] = value;
    }

    return env;
  }

  String _stripMatchingQuotes(String input, String quote) {
    if (input.length >= 2 && input.startsWith(quote) && input.endsWith(quote)) {
      return input.substring(1, input.length - 1);
    }
    // Support multi-line or dangling quotes by trimming first/last if present.
    if (input.startsWith(quote)) input = input.substring(1);
    if (input.endsWith(quote)) input = input.substring(0, input.length - 1);
    return input;
  }

  String _unescapeDoubleQuoted(String input) {
    final sb = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (c != r'\') {
        sb.write(c);
        continue;
      }
      // Escape sequence
      i++;
      if (i >= input.length) {
        sb.write(r'\');
        break;
      }
      final e = input[i];
      switch (e) {
        case 'n':
          sb.write('\n');
          break;
        case 'r':
          sb.write('\r');
          break;
        case 't':
          sb.write('\t');
          break;
        case '"':
          sb.write('"');
          break;
        case r'\':
          sb.write(r'\');
          break;
        default:
        // Unknown escape: keep literally
          sb.write(r'\');
          sb.write(e);
      }
    }
    return sb.toString();
  }

  int _indexOfUnescapedHash(String s) {
    for (var i = 0; i < s.length; i++) {
      if (s[i] == '#') {
        if (i == 0 || s[i - 1] != r'\') return i;
      }
    }
    return -1;
  }

  // ---------------------------------------------------------------------------
  // Expansion
  // ---------------------------------------------------------------------------

  /// Expand ${VAR} and ${VAR:-default} references.
  void _expandAll() {
    final resolving = <String>{};
    for (final k in _env.keys.toList()) {
      _env[k] = _expandValue(_env[k]!, resolving);
    }
  }

  String _expandValue(String value, Set<String> resolving) {
    final rx = RegExp(r'\$\{([A-Za-z_][A-Za-z0-9_\.]*)(:-([^}]*))?\}');
    return value.replaceAllMapped(rx, (m) {
      final key = m.group(1)!;
      final hasDefault = m.group(2) != null;
      final def = m.group(3) ?? '';

      // Prefer in-memory, then platform environment (non-web).
      String? replacement = _env[key];
      if (replacement == null && !kIsWeb) {
        replacement = Platform.environment[key];
      }

      if (replacement == null) {
        replacement = hasDefault ? def : '';
      } else {
        // Protect against cycles: if we see same key in the chain, stop expanding.
        if (!resolving.add(key)) return replacement;
        replacement = _expandValue(replacement, resolving);
        resolving.remove(key);
      }
      return replacement;
    });
  }

  void _merge(Map<String, String> src, {required bool overrideExisting}) {
    if (overrideExisting) {
      _env.addAll(src);
    } else {
      for (final e in src.entries) {
        _env.putIfAbsent(e.key, () => e.value);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Typed getters
  // ---------------------------------------------------------------------------

  String getString(String key, {String? defaultValue, bool trim = true}) {
    final v = _env[key];
    if (v == null) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env "$key"');
    }
    return trim ? v.trim() : v;
  }

  int getInt(String key, {int? defaultValue}) {
    final s = _env[key];
    if (s == null) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env "$key"');
    }
    final v = int.tryParse(s.trim());
    if (v == null) throw FormatException('Env "$key" is not an int: "$s"');
    return v;
  }

  double getDouble(String key, {double? defaultValue}) {
    final s = _env[key];
    if (s == null) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env "$key"');
    }
    final v = double.tryParse(s.trim());
    if (v == null) throw FormatException('Env "$key" is not a double: "$s"');
    return v;
  }

  bool getBool(String key, {bool? defaultValue}) {
    final s = _env[key];
    if (s == null) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env "$key"');
    }
    final t = s.trim().toLowerCase();
    if (t == 'true' || t == '1' || t == 'yes' || t == 'y' || t == 'on') return true;
    if (t == 'false' || t == '0' || t == 'no' || t == 'n' || t == 'off') return false;
    throw FormatException('Env "$key" is not a bool: "$s"');
  }

  Duration getDuration(String key, {Duration? defaultValue}) {
    final s = _env[key];
    if (s == null) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env "$key"');
    }
    // Supports ISO8601 (e.g. PT15M) or simple "<number><unit>" like "30s", "5m", "2h".
    final v = s.trim();
    if (v.startsWith('P')) {
      // ISO8601
      return _parseIso8601Duration(v);
    }
    final simple = RegExp(r'^(\d+)\s*([smhd])$');
    final m = simple.firstMatch(v);
    if (m != null) {
      final n = int.parse(m.group(1)!);
      switch (m.group(2)!) {
        case 's':
          return Duration(seconds: n);
        case 'm':
          return Duration(minutes: n);
        case 'h':
          return Duration(hours: n);
        case 'd':
          return Duration(days: n);
      }
    }
    throw FormatException('Env "$key" is not a duration: "$s"');
  }

  Uri getUri(String key, {Uri? defaultValue}) {
    final s = _env[key];
    if (s == null) {
      if (defaultValue != null) return defaultValue;
      throw StateError('Missing env "$key"');
    }
    final u = Uri.tryParse(s.trim());
    if (u == null) throw FormatException('Env "$key" is not a valid URI: "$s"');
    return u;
  }

  // Minimal ISO8601 duration parser for PT#H#M#S (hours/minutes/seconds)
  Duration _parseIso8601Duration(String input) {
    final rx = RegExp(r'^P(T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)$');
    final m = rx.firstMatch(input);
    if (m == null) throw FormatException('Unsupported ISO8601 duration: "$input"');
    final h = int.tryParse(m.group(2) ?? '0') ?? 0;
    final mm = int.tryParse(m.group(3) ?? '0') ?? 0;
    final s = int.tryParse(m.group(4) ?? '0') ?? 0;
    return Duration(hours: h, minutes: mm, seconds: s);
  }
}