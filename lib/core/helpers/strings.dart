extension SuperString on String {
  // ---------------------------------------------------------------------------
  // Case checks
  // ---------------------------------------------------------------------------

  /// True if every character is already uppercase OR is a non-letter.
  /// (e.g. 'HELLO', '123!?', '' -> true; 'Hello' -> false)
  bool get isUpperCase {
    if (isEmpty) return true;
    final hasLetter = RegExp(r'\p{L}', unicode: true);
    final onlyUpperOrNonLetters =
    RegExp(r'^(?:\p{Lu}|\P{L})+$', unicode: true).hasMatch(this);
    // If there are letters, they must be upper; digits/punct are fine.
    return !hasLetter.hasMatch(this) || onlyUpperOrNonLetters;
  }

  /// True if every character is lowercase OR is a non-letter.
  bool get isLowerCase {
    if (isEmpty) return true;
    final hasLetter = RegExp(r'\p{L}', unicode: true);
    final onlyLowerOrNonLetters =
    RegExp(r'^(?:\p{Ll}|\P{L})+$', unicode: true).hasMatch(this);
    return !hasLetter.hasMatch(this) || onlyLowerOrNonLetters;
  }

  // ---------------------------------------------------------------------------
  // Character classes
  // ---------------------------------------------------------------------------

  /// True if all characters are alphanumeric (letters or digits).
  ///
  /// (Compat: this used to be named isNumber in your code; kept both.)
  bool get isAlNum => RegExp(r'^[\p{L}\p{N}]+$', unicode: true).hasMatch(this);

  /// Alias kept for backward compatibility (actually checks alphanumeric).
  bool get isNumber => isAlNum;

  /// True if all characters are alphabetic letters.
  bool get isAlpha => RegExp(r'^\p{L}+$', unicode: true).hasMatch(this);

  /// True if all characters are digits (Unicode numeric).
  bool get isInteger => RegExp(r'^\p{N}+$', unicode: true).hasMatch(this);

  /// True if the entire string is a valid number (int or double) in Dart sense.
  bool get isNumeric => num.tryParse(trim()) != null;

  /// True if the entire string is a valid int.
  bool get isInt => int.tryParse(trim()) != null;

  /// True if the entire string is a valid double.
  bool get isDouble => double.tryParse(trim()) != null;

  // ---------------------------------------------------------------------------
  // Iteration & indexing
  // ---------------------------------------------------------------------------

  /// Iterable of (code-point) characters. (Grapheme-safe requires package:characters.)
  Iterable<String> get iterable => runes.map(String.fromCharCode);

  /// First character (code point). Throws [StateError] if empty.
  String get first => String.fromCharCode(runes.first);

  /// Last character (code point). Throws [StateError] if empty.
  String get last => String.fromCharCode(runes.last);

  /// Character at [index] (by code point).
  String charAt(int index) => iterable.elementAt(index);

  // ---------------------------------------------------------------------------
  // Case transforms
  // ---------------------------------------------------------------------------

  /// Capitalize first letter and lowercase the rest.
  String capitalize() =>
      isNotEmpty ? first.toUpperCase() + substring(1).toLowerCase() : this;

  /// Title case: capitalizes each word separated by whitespace.
  String title() {
    if (isEmpty) return this;
    final parts = trim().split(RegExp(r'\s+'));
    return parts.map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
  }

  /// Convert into CamelCase (PascalCase by default).
  /// If [isLowerCamelCase] is true, produce lowerCamelCase.
  String toCamelCase({bool isLowerCamelCase = false}) {
    if (isEmpty) return this;
    final parts = _splitWords();
    if (parts.isEmpty) return this;

    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      final p = parts[i];
      if (i == 0 && isLowerCamelCase) {
        buffer.write(p.toLowerCase());
      } else {
        buffer.write(p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1).toLowerCase());
      }
    }
    return buffer.toString();
  }

  /// lowerCamelCase shorthand.
  String get camelCase => toCamelCase(isLowerCamelCase: true);

  /// UpperCamelCase / PascalCase.
  String get pascalCase => toCamelCase(isLowerCamelCase: false);

  /// snake_case.
  String get snakeCase {
    final parts = _splitWords();
    return parts.map((p) => p.toLowerCase()).join('_');
  }

  /// kebab-case / param-case.
  String get kebabCase {
    final parts = _splitWords();
    return parts.map((p) => p.toLowerCase()).join('-');
  }

  /// Make a URL/filename friendly slug (ascii-ish, lowercase, dash-separated).
  String get slugify {
    var s = removeDiacritics().toLowerCase();
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    s = s.replaceAll(RegExp(r'-{2,}'), '-');
    return s.trim().replaceAll(RegExp(r'^-+|-+$'), '');
  }

  // ---------------------------------------------------------------------------
  // Search & counts
  // ---------------------------------------------------------------------------

  /// Count occurrences of [value] between [start] (inclusive) and [end] (exclusive).
  int count(String value, [int start = 0, int? end]) {
    final sub = (end == null) ? substring(start) : substring(start, end);
    return value.allMatches(sub).length;
  }

  /// True if this contains all [values].
  bool containsAll(Iterable<String> values) => values.every(contains);

  /// True if this contains any of [values].
  bool containsAny(Iterable<String> values) => values.any(contains);

  /// Part after the first [pattern]; returns empty string if not found.
  String after(Pattern pattern) {
    if (pattern is String) {
      final i = indexOf(pattern);
      return i == -1 ? '' : substring(i + pattern.length);
    } else {
      final r = (pattern as RegExp).firstMatch(this);
      return r == null ? '' : substring(r.end);
    }
  }

  /// Text between [start] and [end] (first matches). Returns empty if not found.
  String between(Pattern start, Pattern end) {
    final a = (start is String) ? indexOf(start) : (start as RegExp).firstMatch(this)?.start ?? -1;
    if (a == -1) return '';
    final startEnd = (start is String)
        ? a + start.length
        : ((start as RegExp).firstMatch(this)!.end);
    final b = (end is String)
        ? indexOf(end, startEnd)
        : (end as RegExp).firstMatch(substring(startEnd))?.start;
    if (b == null || b == -1) return '';
    final endIdx = (end is String) ? b : startEnd + b;
    return substring(startEnd, endIdx);
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  /// Collapse all consecutive whitespace to a single space and trim ends.
  String get collapseWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Reverse the string (code points).
  String get reverse => iterable.toList().reversed.join();

  /// Repeat the string [times] (>= 0).
  String repeat(int times) {
    if (times <= 0) return '';
    return List.filled(times, this).join();
  }

  /// Truncate to [max] chars; append [ellipsis] if truncated.
  String truncate(int max, {String ellipsis = '…'}) {
    if (length <= max || max <= 0) return this;
    if (max <= ellipsis.length) return ellipsis.substring(0, max);
    return substring(0, max - ellipsis.length) + ellipsis;
  }

  /// Remove leading/trailing quotes (single or double) if present.
  String get unquote {
    if (length >= 2) {
      final a = this[0], b = this[length - 1];
      if ((a == '"' && b == '"') || (a == "'" && b == "'")) {
        return substring(1, length - 1);
      }
    }
    return this;
  }

  /// Strip common diacritics to ASCII equivalents (best effort).
  String removeDiacritics() {
    // Minimal map; extend as you need.
    const from = 'ÀÁÂÃÄÅĀĂĄàáâãäåāăąÇĆĈĊČçćĉċčÐĎĐðďđÈÉÊËĒĔĖĘĚèéêëēĕėęěĞġģĞİıÌÍÎÏĪĬĮİìíîïīĭįĳÑŃŇŅñńňņÒÓÔÕÖØŌŎŐòóôõöøōŏőŔŘŖŕřŗŚŜŞŠśŝşšŤŢŦťţŧÙÚÛÜŪŬŮŰŲùúûüūŭůűųÝŸýÿŹŻŽźżž';
    const to   = 'AAAAAAAAaaaaaaaaCCCCCcccccDDĐdddEEEEEEEEEeeeeeeeeeGggGIIIIIIIIiiiiiiijNNNnnnOOOOOOOoooooooRRRrrrSSSSssssTTTtttUUUUUUUUuuuuuuuuYYyyZZZzzz';
    final map = <int, String>{};
    for (var i = 0; i < from.length && i < to.length; i++) {
      map[from.codeUnitAt(i)] = to[i];
    }
    final sb = StringBuffer();
    for (final r in runes) {
      sb.write(map[r] ?? String.fromCharCode(r));
    }
    return sb.toString();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Split into "word" tokens by non-alphanumeric boundaries.
  List<String> _splitWords() {
    // Replace separators with space, then split.
    final cleaned = trim()
        .replaceAll(RegExp(r'[_\-\s]+'), ' ')
        .replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ')
        .trim();
    if (cleaned.isEmpty) return <String>[];
    return cleaned.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  }
}
