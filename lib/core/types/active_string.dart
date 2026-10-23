part of 'package:activity/core/types/active_type.dart';

/// Observable text; update through helpers to notify consumers.
///
/// Register fields in the owning controller before notifying updates. Mutating collection `.value` directly bypasses notifications; snapshots are shallow.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) · browser route `/#/values`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Normalize a draft
///
/// <!-- activity-snippet: class-activestring-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveString(' hello ');
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.trimValue();
///     controller.value.append(' world');
///     assert(controller.value.value == 'hello world');
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Parse optional numeric input
///
/// <!-- activity-snippet: class-activestring-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveString(' hello ');
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value(' 42 ');
///     assert(controller.value.tryInt == 42);
///     controller.value('invalid');
///     assert(controller.value.tryInt == null);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
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

/// Optional reactive values; constructors use named `value:` arguments.
///
/// Check for null before calling operations requiring a value. The owner disposes the controller, not each wrapper.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) · browser route `/#/values`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Initialize absent data
///
/// <!-- activity-snippet: class-activenullablestring-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveNullableString();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     assert(controller.value.isNull);
///     controller.value.setIfNull(() => 'Ada');
///     assert(controller.value.value == 'Ada');
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Clear and restore absence
///
/// <!-- activity-snippet: class-activenullablestring-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveNullableString();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value('Ada');
///     controller.value.reset();
///     assert(controller.value.value == null);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveNullableString extends ActiveType<String?> {
  ActiveNullableString({String? value, super.typeName}) : super(value);

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
