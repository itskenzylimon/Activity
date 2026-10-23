import 'package:intl/intl.dart';

/// ICU MessageFormat 1 interpolation, cardinal plural and select messages.
///
/// Pass numbers as numbers and include other branches. Selectordinal, date/number skeletons, MessageFormat 2 and rich-text rendering are not implemented.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#localization) · browser route `/#/localization`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Interpolate named parameters
///
/// <!-- activity-snippet: class-icumessage-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final message = IcuMessage('Hello {name}');
///   assert(
///     message.format(locale: 'en', parameters: {'name': 'Ada'}) == 'Hello Ada',
///   );
/// }
/// ```
///
/// ### Format a cardinal plural
///
/// <!-- activity-snippet: class-icumessage-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final message = IcuMessage(
///     '{count, plural, =0{No tasks} one{# task} other{# tasks}}',
///   );
///   assert(message.format(locale: 'en', parameters: {'count': 2}) == '2 tasks');
/// }
/// ```
///
/// ### Select a message branch
///
/// <!-- activity-snippet: class-icumessage-3 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final message = IcuMessage(
///     '{role, select, editor{Can edit} other{Read only}}',
///   );
///   assert(
///     message.format(locale: 'en', parameters: {'role': 'guest'}) == 'Read only',
///   );
/// }
/// ```
class IcuMessage {
  final List<_Node> _nodes;
  IcuMessage(String pattern) : _nodes = _Parser(pattern).parse();
  String format({
    required String locale,
    Map<String, Object?> parameters = const {},
  }) => _render(_nodes, locale, parameters, null);
}

String _render(
  List<_Node> nodes,
  String locale,
  Map<String, Object?> args,
  num? pound,
) => nodes.map((node) => node.render(locale, args, pound)).join();

sealed class _Node {
  String render(String locale, Map<String, Object?> args, num? pound);
}

class _Text extends _Node {
  final String text;
  _Text(this.text);
  @override
  String render(String locale, Map<String, Object?> args, num? pound) => text;
}

class _Argument extends _Node {
  final String name;
  _Argument(this.name);
  @override
  String render(String locale, Map<String, Object?> args, num? pound) =>
      args.containsKey(name) ? '${args[name]}' : '{$name}';
}

class _Pound extends _Node {
  @override
  String render(String locale, Map<String, Object?> args, num? pound) =>
      pound == null ? '#' : NumberFormat.decimalPattern(locale).format(pound);
}

class _Choice extends _Node {
  final String name;
  final bool plural;
  final num offset;
  final Map<String, List<_Node>> options;
  final Map<num, List<_Node>> exact;
  _Choice(this.name, this.plural, this.offset, this.options, this.exact);
  @override
  String render(String locale, Map<String, Object?> args, num? pound) {
    final value = args[name];
    if (!plural) {
      if (!args.containsKey(name)) {
        throw ArgumentError('Missing ICU select parameter "$name"');
      }
      return _render(
        options['$value'] ?? options['other']!,
        locale,
        args,
        pound,
      );
    }
    if (value is! num || !value.isFinite) {
      throw ArgumentError(
        'ICU plural parameter "$name" must be a finite number',
      );
    }
    final adjusted = value - offset;
    final category = Intl.pluralLogic<String>(
      adjusted.abs(),
      locale: locale,
      zero: 'zero',
      one: 'one',
      two: 'two',
      few: 'few',
      many: 'many',
      other: 'other',
      useExplicitNumberCases: false,
    );
    return _render(
      exact[value] ?? options[category] ?? options['other']!,
      locale,
      args,
      adjusted,
    );
  }
}

class _Parser {
  final String source;
  int index = 0;
  _Parser(this.source);
  Never fail(String message) => throw FormatException(message, source, index);
  List<_Node> parse() {
    final nodes = message(false, false, 0);
    if (index != source.length) fail('Unexpected closing brace');
    return List.unmodifiable(nodes);
  }

  void whitespace() {
    while (index < source.length && source[index].trim().isEmpty) {
      index++;
    }
  }

  List<_Node> message(bool nested, bool plural, int depth) {
    if (depth > 64) fail('ICU message nesting limit exceeded');
    final nodes = <_Node>[];
    final text = StringBuffer();
    void flush() {
      if (text.isNotEmpty) {
        nodes.add(_Text(text.toString()));
        text.clear();
      }
    }

    while (index < source.length) {
      final char = source[index];
      if (char == '}') {
        if (!nested) fail('Unexpected closing brace');
        flush();
        index++;
        return nodes;
      }
      if (char == "'") {
        index++;
        if (index < source.length && source[index] == "'") {
          text.write("'");
          index++;
          continue;
        }
        // ICU DOUBLE_OPTIONAL quoting: ordinary apostrophes stay literal.
        if (index == source.length ||
            !['{', '}', if (plural) '#'].contains(source[index])) {
          text.write("'");
          continue;
        }
        while (index < source.length) {
          final quoted = source[index++];
          if (quoted == "'") {
            if (index < source.length && source[index] == "'") {
              text.write("'");
              index++;
            } else {
              break;
            }
          } else {
            text.write(quoted);
          }
        }
        continue;
      }
      if (char == '{') {
        flush();
        index++;
        nodes.add(argument(plural, depth + 1));
        continue;
      }
      if (char == '#' && plural) {
        flush();
        nodes.add(_Pound());
        index++;
        continue;
      }
      text.write(char);
      index++;
    }
    if (nested) fail('Unclosed ICU branch');
    flush();
    return nodes;
  }

  String token(Set<String> stops) {
    final start = index;
    while (index < source.length && !stops.contains(source[index])) {
      index++;
    }
    return source.substring(start, index).trim();
  }

  _Node argument(bool pluralContext, int depth) {
    final name = token({',', '{', '}'});
    if (name.isEmpty || index >= source.length || source[index] == '{') {
      fail('Invalid ICU argument');
    }
    if (source[index] == '}') {
      index++;
      return _Argument(name);
    }
    index++; // comma
    final kind = token({',', '{', '}'});
    if (kind != 'plural' && kind != 'select') {
      fail('Unsupported ICU argument type "$kind"');
    }
    if (index >= source.length || source[index] != ',') {
      fail('Expected comma after ICU argument type');
    }
    index++;
    whitespace();
    num offset = 0;
    if (kind == 'plural' && source.startsWith('offset:', index)) {
      index += 7;
      whitespace();
      final start = index;
      while (index < source.length &&
          RegExp(r'[0-9.]').hasMatch(source[index])) {
        index++;
      }
      final parsed = num.tryParse(source.substring(start, index));
      if (parsed == null || !parsed.isFinite || parsed < 0) {
        fail('Invalid plural offset');
      }
      offset = parsed;
    }
    final options = <String, List<_Node>>{};
    final exact = <num, List<_Node>>{};
    while (true) {
      whitespace();
      if (index >= source.length) fail('Unclosed ICU argument');
      if (source[index] == '}') {
        index++;
        break;
      }
      final selector = token({'{', '}'});
      if (selector.isEmpty || index >= source.length || source[index] != '{') {
        fail('Expected ICU selector and branch');
      }
      num? number;
      if (kind == 'plural') {
        if (selector.startsWith('=')) {
          number = num.tryParse(selector.substring(1));
          if (number == null || !number.isFinite) {
            fail('Invalid exact plural selector');
          }
          if (exact.containsKey(number)) {
            fail('Duplicate exact plural selector');
          }
        } else if (!const [
          'zero',
          'one',
          'two',
          'few',
          'many',
          'other',
        ].contains(selector)) {
          fail('Invalid plural category "$selector"');
        }
      }
      if (options.containsKey(selector)) {
        fail('Duplicate ICU selector "$selector"');
      }
      index++;
      final branch = message(true, kind == 'plural' || pluralContext, depth);
      if (number != null) {
        exact[number] = branch;
      } else {
        options[selector] = branch;
      }
    }
    if (!options.containsKey('other')) {
      fail('ICU $kind requires an other branch');
    }
    return _Choice(name, kind == 'plural', offset, options, exact);
  }
}
