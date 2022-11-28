part of 'package:activity/core/types/active_type.dart';

/// An [ActiveString] with similar characteristics as a an
/// ordinary dart List object. When an update is done an [ActiveStateChanged]
/// event is triggered which in-turn makes a UI rebuild of that widget.
///
/// Has similar characteristics as int and The value cannot be null

class ActiveString extends ActiveType<String> {
  ActiveString(super.value, {super.typeName});

  ///Factory constructor for initializing an [ActiveString] to an empty [String].
  ///
  ///See [ActiveType] for [typeName] usages.
  ///
  ///## Example
  ///
  ///```dart
  ///final title = ActiveString.empty();
  ///```
  factory ActiveString.empty({String? typeName}) {
    return ActiveString('', typeName: typeName);
  }

  ///Whether the string value is empty
  bool get isEmpty => _value.isEmpty;

  ///Whether the string value is empty or not
  bool get isNotEmpty => _value.isNotEmpty;

  /// The length of the string value.
  int get length => _value.length;

  /// Whether the string value contains a match of [other].
  ///
  /// Example:
  /// ```dart
  /// const string = ActiveString('Doug');
  /// final containsD = string.contains('D'); // true
  /// final containsUpperCase = string.contains(RegExp(r'[A-Z]')); // true
  /// ```
  /// If [startIndex] is provided, this method matches only at or after that
  /// index:
  /// ```dart
  /// const string = ActiveString('Doug smith');
  /// final containsD = string.contains(RegExp('D'), 0); // true
  /// final caseSensitive = string.contains(RegExp(r'[A-Z]'), 1); // false
  /// ```
  /// The [startIndex] must not be negative or greater than [length].
  bool contains(String other, [int startIndex = 0]) =>
      _value.contains(other, startIndex);

  /// The substring of the string value from [start], inclusive, to [end], exclusive.
  ///
  /// Example:
  /// ```dart
  /// const string = ActiveString('dougsmith');
  /// var result = string.substring(1); // 'ougsmith'
  /// result = string.substring(1, 3); // 'oug'
  /// ```
  ///
  /// Both [start] and [end] must be non-negative and no greater than [length];
  /// [end], if provided, must be greater than or equal to [start].
  String substring(int start, [int? end]) => _value.substring(start, end);
}

/// An [ActiveNullableString] with similar characteristics as a an
/// ordinary dart List object. When an update is done an [ActiveStateChanged]
/// event is triggered which in-turn makes a UI rebuild of that widget.
///
/// Has similar characteristics as int and The value can be null
///
/// Use [isNull] or [isNotNull] to check null state.

class ActiveNullableString extends ActiveType<String?> {
  ActiveNullableString({String? value, super.typeName})
      : super(value);

  ///Whether the string value is empty
  ///
  ///Returns true if the string value is null
  bool get isEmpty => _value?.isEmpty ?? true;

  ///Whether the string value is empty or not.
  ///
  ///Returns false if the string value is null
  bool get isNotEmpty => _value?.isNotEmpty ?? false;

  /// The length of the string value.
  ///
  /// Returns 0 if the string value is null
  int get length => _value?.length ?? 0;

  /// Whether the string value contains a match of [other].
  ///
  /// Returns false if the String value is null
  ///
  /// Example:
  /// ```dart
  /// const string = ActiveString('Doug');
  /// final containsD = string.contains('D'); // true
  /// final containsUpperCase = string.contains(RegExp(r'[A-Z]')); // true
  /// ```
  /// If [startIndex] is provided, this method matches only at or after that
  /// index:
  /// ```dart
  /// const string = ActiveString('Doug smith');
  /// final containsD = string.contains(RegExp('D'), 0); // true
  /// final caseSensitive = string.contains(RegExp(r'[A-Z]'), 1); // false
  /// ```
  /// The [startIndex] must not be negative or greater than [length].
  bool contains(String other, [int startIndex = 0]) =>
      _value?.contains(other, startIndex) ?? false;

  /// The substring of the string value from [start], inclusive, to [end], exclusive.
  ///
  /// Returns null if the string value is null
  ///
  /// Example:
  /// ```dart
  /// const string = ActiveString('dougsmith');
  /// var result = string.substring(1); // 'ougsmith'
  /// result = string.substring(1, 3); // 'oug'
  /// ```
  ///
  /// Both [start] and [end] must be non-negative and no greater than [length];
  /// [end], if provided, must be greater than or equal to [start].
  String? substring(int start, [int? end]) => _value?.substring(start, end);
}
