// schema_validator.dart
import 'dart:core';

/// Result of validating a payload against a schema.
class SchemaResponse {
  /// True if no validation errors occurred.
  final bool valid;

  /// The original (unmodified) data that was validated.
  final Map<String, dynamic> data;

  /// A sanitized view of data that passed validation (keys with errors removed).
  final Map<String, dynamic> schema;

  /// Validation errors by field key -> message (or nested map).
  final Map<String, String> errors;

  const SchemaResponse({
    required this.valid,
    required this.data,
    required this.schema,
    required this.errors,
  });

  @override
  String toString() {
    final ok = valid ? 'Success' : 'Failed';
    return '( $ok )\n${valid ? schema : errors}';
  }
}

/// Common rule names used for customizing error messages.
/// You can use these with `customErrors` (e.g., 'email', 'username.minLength').
class Rules {
  static const required = 'required';
  static const requiredIf = 'requiredIf';
  static const requiredWhen = 'requiredWhen';
  static const notEmpty = 'notEmpty';
  static const type = 'type';
  static const min = 'min';
  static const max = 'max';
  static const minLength = 'minLength';
  static const maxLength = 'maxLength';
  static const email = 'email';
  static const phone = 'phone';
  static const url = 'url';
  static const uuid = 'uuid';
  static const ipv4 = 'ipv4';
  static const ipv6 = 'ipv6';
  static const pattern = 'pattern';
  static const includes = 'in';
  static const equalsTo = 'equalsTo';
  static const date = 'date';
  static const before = 'before';
  static const after = 'after';
  static const minItems = 'minItems';
  static const maxItems = 'maxItems';
  static const custom = 'custom';
}

/// Validate form payloads with explicit unknown-field and custom-rule policies.
///
/// Validation is not authorization or network verification. A custom rule returns null on success; sanitized maps and snapshots remain shallow.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#validation) · browser route `/#/validation`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Validate and sanitize
///
/// <!-- activity-snippet: class-schemavalidator-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final validator = SchemaValidator({
///     'age': {'type': int, 'min': 18},
///   }, allowUnknownKeys: false);
///   final result = validator.validate({'age': 21, 'extra': 'omitted'});
///   assert(result.valid && !result.schema.containsKey('extra'));
/// }
/// ```
///
/// ### Explain a recoverable field error
///
/// <!-- activity-snippet: class-schemavalidator-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final validator = SchemaValidator({
///     'name': {
///       'type': String,
///       'custom':
///           (dynamic value, Map<String, dynamic> data) =>
///               value == 'admin' ? 'Reserved name' : null,
///     },
///   });
///   final result = validator.validate({'name': 'admin'});
///   assert(result.errors['name'] == 'Reserved name');
///   // Keep the form draft and display result.errors beside its fields.
/// }
/// ```
class SchemaValidator {
  /// Validation schema describing constraints per key.
  final Map<String, Map<String, dynamic>> _schema;

  /// Optional custom error messages.
  ///
  /// Precedence when resolving messages:
  /// - 'field.rule' (e.g. 'email.required')
  /// - 'field'
  /// - 'rule'      (e.g. 'required')
  /// - Default message (built-in)
  ///
  /// Values are plain strings.
  final Map<String, String>? customErrors;
  final bool allowUnknownKeys;

  SchemaValidator(
    Map<String, dynamic> schema, {
    this.customErrors,
    this.allowUnknownKeys = true,
  }) : _schema = schema.map(
         (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
       );

  /// Validate [data] against this schema.
  SchemaResponse validate(Map<String, dynamic> data) {
    // Work on a defensive copy; never mutate caller input.
    final input = Map<String, dynamic>.from(data);
    final sanitized = <String, dynamic>{
      for (final entry in data.entries)
        if (allowUnknownKeys || _schema.containsKey(entry.key))
          entry.key: entry.value,
    };
    final errors = <String, String>{};

    for (final key in _schema.keys) {
      final rules = _schema[key]!;
      final hasKey = input.containsKey(key);
      final value = input[key];

      // ---------- required / conditional required ----------
      final isRequired = _asBool(rules[Rules.required]) ?? false;

      final requiredIf = rules[Rules.requiredIf];
      final requiredWhen = rules[Rules.requiredWhen];
      final requiredBecauseIf = _requiredIf(requiredIf, input);
      final requiredBecauseWhen = _requiredWhen(requiredWhen, input);

      final mustExist = isRequired || requiredBecauseIf || requiredBecauseWhen;

      if (!hasKey || value == null) {
        if (mustExist) {
          _putError(
            errors,
            key,
            _msg(key, Rules.required, defaultMsg: '$key is required'),
          );
          sanitized.remove(key);
          continue;
        } else {
          // no value, not required => skip further checks
          sanitized.remove(key);
          continue;
        }
      }

      // ---------- notEmpty ----------
      if (_asBool(rules[Rules.notEmpty]) == true) {
        if ((value is String && value.trim().isEmpty) ||
            (value is Iterable && value.isEmpty) ||
            (value is Map && value.isEmpty)) {
          _putError(
            errors,
            key,
            _msg(key, Rules.notEmpty, defaultMsg: '$key must not be empty'),
          );
          sanitized.remove(key);
          continue;
        }
      }

      // ---------- type check ----------
      final expectedType = rules[Rules.type];
      if (expectedType != null) {
        final ok = _isOfType(value, expectedType);
        if (!ok) {
          _putError(
            errors,
            key,
            _msg(key, Rules.type, defaultMsg: '$key has invalid type'),
          );
          sanitized.remove(key);
          continue;
        }
      }

      // ---------- numeric bounds ----------
      if (value is num) {
        final min = rules[Rules.min];
        if (min is num && value < min) {
          _putError(
            errors,
            key,
            _msg(key, Rules.min, defaultMsg: '$key is below minimum ($min)'),
          );
        }
        final max = rules[Rules.max];
        if (max is num && value > max) {
          _putError(
            errors,
            key,
            _msg(key, Rules.max, defaultMsg: '$key exceeds maximum ($max)'),
          );
        }
      }

      // ---------- string length bounds ----------
      if (value is String) {
        final minLen = rules[Rules.minLength];
        if (minLen is int && value.length < minLen) {
          _putError(
            errors,
            key,
            _msg(
              key,
              Rules.minLength,
              defaultMsg: '$key is too short (min $minLen)',
            ),
          );
        }
        final maxLen = rules[Rules.maxLength];
        if (maxLen is int && value.length > maxLen) {
          _putError(
            errors,
            key,
            _msg(
              key,
              Rules.maxLength,
              defaultMsg: '$key is too long (max $maxLen)',
            ),
          );
        }
      }

      // ---------- list size bounds ----------
      if (value is List) {
        final minItems = rules[Rules.minItems];
        if (minItems is int && value.length < minItems) {
          _putError(
            errors,
            key,
            _msg(
              key,
              Rules.minItems,
              defaultMsg: '$key needs at least $minItems item(s)',
            ),
          );
        }
        final maxItems = rules[Rules.maxItems];
        if (maxItems is int && value.length > maxItems) {
          _putError(
            errors,
            key,
            _msg(
              key,
              Rules.maxItems,
              defaultMsg: '$key allows at most $maxItems item(s)',
            ),
          );
        }
      }

      // ---------- format checks ----------
      if (_asBool(rules[Rules.email]) == true) {
        if (!(value is String && _emailRegex.hasMatch(value))) {
          _putError(
            errors,
            key,
            _msg(key, Rules.email, defaultMsg: '$key is not a valid email'),
          );
        }
      }

      if (_asBool(rules[Rules.phone]) == true) {
        // E.164: +<country><number>, up to 15 digits (relaxed to allow local too)
        if (!(value is String && _phoneE164Regex.hasMatch(value))) {
          _putError(
            errors,
            key,
            _msg(key, Rules.phone, defaultMsg: '$key is not a valid phone'),
          );
        }
      }

      if (_asBool(rules[Rules.url]) == true) {
        final uri = value is String ? Uri.tryParse(value) : null;
        final ok =
            uri != null &&
            ['http', 'https'].contains(uri.scheme) &&
            uri.host.isNotEmpty;
        if (!ok) {
          _putError(
            errors,
            key,
            _msg(key, Rules.url, defaultMsg: '$key is not a valid URL'),
          );
        }
      }

      if (_asBool(rules[Rules.uuid]) == true) {
        if (!(value is String && _uuidRegex.hasMatch(value))) {
          _putError(
            errors,
            key,
            _msg(key, Rules.uuid, defaultMsg: '$key is not a valid UUID'),
          );
        }
      }

      if (_asBool(rules[Rules.ipv4]) == true) {
        if (!(value is String && _ipv4Regex.hasMatch(value))) {
          _putError(
            errors,
            key,
            _msg(key, Rules.ipv4, defaultMsg: '$key is not a valid IPv4'),
          );
        }
      }

      if (_asBool(rules[Rules.ipv6]) == true) {
        if (!(value is String && _isIpv6(value))) {
          _putError(
            errors,
            key,
            _msg(key, Rules.ipv6, defaultMsg: '$key is not a valid IPv6'),
          );
        }
      }

      final pattern = rules[Rules.pattern];
      if (pattern is String || pattern is RegExp) {
        final rx = pattern is RegExp ? pattern : RegExp(pattern as String);
        if (!(value is String && rx.hasMatch(value))) {
          _putError(
            errors,
            key,
            _msg(
              key,
              Rules.pattern,
              defaultMsg: '$key does not match required pattern',
            ),
          );
        }
      }

      // ---------- enums / allowed set ----------
      final allowed = rules[Rules.includes] ?? rules['enum'];
      if (allowed is Iterable) {
        final set = allowed.toSet();
        if (!set.contains(value)) {
          _putError(
            errors,
            key,
            _msg(key, Rules.includes, defaultMsg: '$key must be one of $set'),
          );
        }
      }

      // ---------- equalsTo (confirm) ----------
      final equalsTo = rules[Rules.equalsTo];
      if (equalsTo is String) {
        if (input[equalsTo] != value) {
          _putError(
            errors,
            key,
            _msg(key, Rules.equalsTo, defaultMsg: '$key must equal $equalsTo'),
          );
        }
      }

      // ---------- date & boundaries ----------
      if (_asBool(rules[Rules.date]) == true) {
        if (!(value is String && _isParsableDate(value))) {
          _putError(
            errors,
            key,
            _msg(key, Rules.date, defaultMsg: '$key is not a valid date'),
          );
        } else {
          final dt = DateTime.parse(value);
          final before = rules[Rules.before];
          final after = rules[Rules.after];
          if (before is String &&
              _isParsableDate(before) &&
              !(dt.isBefore(DateTime.parse(before)))) {
            _putError(
              errors,
              key,
              _msg(
                key,
                Rules.before,
                defaultMsg: '$key must be before $before',
              ),
            );
          }
          if (after is String &&
              _isParsableDate(after) &&
              !(dt.isAfter(DateTime.parse(after)))) {
            _putError(
              errors,
              key,
              _msg(key, Rules.after, defaultMsg: '$key must be after $after'),
            );
          }
        }
      }

      // ---------- custom function ----------
      final custom = rules[Rules.custom];
      if (custom
          is String? Function(dynamic value, Map<String, dynamic> data)) {
        final msg = custom(value, input);
        if (msg != null && msg.isNotEmpty) {
          _putError(errors, key, _msg(key, Rules.custom, defaultMsg: msg));
        }
      }

      // If any error exists for this key, remove from sanitized.
      if (errors.containsKey(key)) {
        sanitized.remove(key);
      }
    }

    return SchemaResponse(
      valid: errors.isEmpty,
      data: Map.unmodifiable(input),
      schema: Map.unmodifiable(sanitized),
      errors: Map.unmodifiable(errors),
    );
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  bool _requiredIf(dynamic rule, Map<String, dynamic> data) {
    // Example: {'requiredIf': {'country': 'US'}}
    if (rule is Map) {
      for (final e in rule.entries) {
        if (data[e.key] == e.value) return true;
      }
    }
    return false;
  }

  bool _requiredWhen(dynamic rule, Map<String, dynamic> data) {
    // Example: {'requiredWhen': (data) => data['subscribe'] == true}
    if (rule is bool) return rule;
    if (rule is bool Function(Map<String, dynamic>)) return rule(data);
    return false;
  }

  bool _isOfType(dynamic value, dynamic expected) {
    if (expected is bool Function(dynamic)) return expected(value);
    if (expected is Type) {
      if (expected == num) return value is num;
      if (expected == int) return value is int;
      if (expected == double) return value is double;
      if (expected == String) return value is String;
      if (expected == bool) return value is bool;
      if (expected == List) return value is List;
      if (expected == Map) return value is Map;
      // For subtype checks, supply a typed predicate instead.
      return value.runtimeType == expected;
    } else if (expected is Iterable<Type>) {
      // Accept any of the listed types.
      for (final t in expected) {
        if (_isOfType(value, t)) return true;
      }
      return false;
    }
    throw ArgumentError.value(
      expected,
      'type',
      'Use a Type, Iterable<Type>, or bool predicate',
    );
  }

  bool _isParsableDate(String s) {
    try {
      DateTime.parse(s);
      final date = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})(?:[Tt ](\d{2})(?::?(\d{2}))?(?::?(\d{2}))?)?',
      ).firstMatch(s);
      if (date == null) return false;
      for (final bound in const [(4, 23), (5, 59), (6, 59)]) {
        final component = date[bound.$1];
        if (component != null && int.parse(component) > bound.$2) {
          return false;
        }
      }
      final calendar = DateTime(
        int.parse(date[1]!),
        int.parse(date[2]!),
        int.parse(date[3]!),
      );
      return calendar.year == int.parse(date[1]!) &&
          calendar.month == int.parse(date[2]!) &&
          calendar.day == int.parse(date[3]!);
    } catch (_) {
      return false;
    }
  }

  void _putError(Map<String, String> dst, String key, String message) {
    // Only keep first error per key to avoid noise; remove to collect all.
    dst.putIfAbsent(key, () => message);
  }

  String _msg(String key, String rule, {required String defaultMsg}) {
    if (customErrors == null) return defaultMsg;
    return customErrors!['$key.$rule'] ??
        customErrors![key] ??
        customErrors![rule] ??
        defaultMsg;
  }

  bool? _asBool(dynamic v) {
    if (v is bool) return v;
    return null;
  }

  // Regexes (compiled once)
  static final RegExp _emailRegex = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  // E.164 (e.g. +254712345678) — allow optional leading + and 7–15 digits
  static final RegExp _phoneE164Regex = RegExp(r'^\+?[1-9]\d{6,14}$');

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  static final RegExp _ipv4Regex = RegExp(
    r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
  );

  // IPv6 syntax, including compressed addresses and final embedded IPv4.
  // Zone IDs are deliberately outside this schema rule.
  bool _isIpv6(String value) {
    if (value.isEmpty || value.contains('%')) return false;
    final compressed = value.contains('::');
    if (compressed && value.indexOf('::') != value.lastIndexOf('::')) {
      return false;
    }
    var source = value;
    var ipv4Groups = 0;
    if (source.contains('.')) {
      final separator = source.lastIndexOf(':');
      if (separator < 0 ||
          !_ipv4Regex.hasMatch(source.substring(separator + 1))) {
        return false;
      }
      source = '${source.substring(0, separator + 1)}ffff';
      ipv4Groups = 1;
    }
    final halves = source.split('::');
    final groups = <String>[];
    for (final half in halves) {
      if (half.isEmpty && compressed) continue;
      groups.addAll(half.split(':'));
    }
    if (groups.any((group) => !RegExp(r'^[a-fA-F0-9]{1,4}$').hasMatch(group))) {
      return false;
    }
    final count = groups.length + ipv4Groups;
    return compressed ? count < 8 : count == 8;
  }
}
