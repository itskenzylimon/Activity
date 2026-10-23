part of 'package:activity/core/types/active_type.dart';

/// Observable integers with numeric helpers.
///
/// Register fields in the owning controller before notifying updates. Mutating collection `.value` directly bypasses notifications; snapshots are shallow.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) · browser route `/#/values`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Increment a counter
///
/// <!-- activity-snippet: class-activeint-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveInt(2);
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.increment();
///     assert(controller.value.value == 3);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Clamp and derive
///
/// <!-- activity-snippet: class-activeint-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveInt(2);
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.updateValue((n) => n * 10);
///     controller.value.clampTo(0, 10);
///     assert(controller.value.select((n) => n.isEven));
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveInt extends ActiveType<int> {
  ActiveInt(super.value, {super.typeName});

  /// Factory constructor for initializing an [ActiveInt] to zero.
  ///
  /// See [ActiveType] for [typeName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final numberOfFriends = ActiveInt.zero();
  /// ```
  factory ActiveInt.zero({String? typeName}) {
    return ActiveInt(0, typeName: typeName);
  }

  /// Returns true if the int value is odd
  bool get isOdd => _value.isOdd;

  /// Returns true if the int value is even.
  bool get isEven => _value.isEven;

  /// Whether this number is negative.
  bool get isNegative => _value.isNegative;

  /// The int value as a double
  double toDouble() => _value.toDouble();

  /// Increment the int value by 1
  int increment({bool notifyChange = true}) =>
      set(_value + 1, notifyChange: notifyChange);

  /// Decrement the int value by 1
  int decrement({bool notifyChange = true}) =>
      set(_value - 1, notifyChange: notifyChange);

  /// Returns the absolute value of this integer.
  int abs() => _value.abs();

  /// Adds [other] to this number.
  ///
  /// This does not set the value for this [ActiveInt].
  ///
  /// The result is an [int], as described by [int.+],
  /// if both this number and [other] is an integer,
  /// otherwise the result is a [double].
  E add<E extends num>(E other) {
    return (_value + other) as E;
  }

  /// Subtracts [other] from this number.
  ///
  /// This does not set the value for this [ActiveInt].
  ///
  /// The result is an [int], as described by [int.-],
  /// if both this number and [other] is an integer,
  /// otherwise the result is a [double].
  E subtract<E extends num>(E other) {
    return (_value - other) as E;
  }

  /// Divides this number by [other].
  ///
  /// This does not set the value for this [ActiveInt].
  double divide<E extends num>(E other) {
    return _value / other;
  }

  /// Euclidean modulo of this number by [other].
  ///
  /// This does not set the value for this [ActiveInt].
  ///
  /// Returns the remainder of the Euclidean division.
  /// The Euclidean division of two integers `a` and `b`
  /// yields two integers `q` and `r` such that
  /// `a == b * q + r` and `0 <= r < b.abs()`.
  ///
  /// The Euclidean division is only defined for integers, but can be easily
  /// extended to work with doubles. In that case, `q` is still an integer,
  /// but `r` may have a non-integer value that still satisfies `0 <= r < |b|`.
  ///
  /// The sign of the returned value `r` is always positive.
  ///
  ///
  /// The result is an [int], as described by [int.%],
  /// if both this number and [other] are integers,
  /// otherwise the result is a [double].
  ///
  /// Example:
  /// ```dart
  /// final number = ActiveInt(5);
  /// print(number % 3); // 2
  /// ```
  E mod<E extends num>(E other) {
    return (_value % other) as E;
  }

  /// Multiplies this number by [other].
  ///
  /// This does not set the value for this [ActiveInt].
  ///
  /// The result is an [int], as described by [int.*],
  /// if both this number and [other] are integers,
  /// otherwise the result is a [double].
  E multiply<E extends num>(E other) {
    return (_value * other) as E;
  }
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
/// <!-- activity-snippet: class-activenullableint-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveNullableInt();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     assert(controller.value.isNull);
///     controller.value.setIfNull(() => 18);
///     assert(controller.value.value == 18);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Clear and restore absence
///
/// <!-- activity-snippet: class-activenullableint-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveNullableInt();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value(18);
///     controller.value.reset();
///     assert(controller.value.value == null);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveNullableInt extends ActiveType<int?> {
  ActiveNullableInt({int? value, super.typeName}) : super(value);

  /// Factory constructor for initializing an [ActiveNullableInt] to zero.
  ///
  /// See [ActiveType] for [typeName] usages.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final numberOfFriends = ActiveIntNull.zero();
  /// ```
  factory ActiveNullableInt.setToZero({String? typeName}) {
    return ActiveNullableInt(value: 0, typeName: typeName);
  }

  /// Returns true if the int value is odd
  ///
  /// Returns false if the int value is null
  bool get isOdd => _value?.isOdd ?? false;

  /// Returns true if the int value is even.
  ///
  /// Returns false if the int value is null
  bool get isEven => _value?.isEven ?? false;

  /// Whether this number is negative.
  ///
  /// Returns false if the int value is null
  bool get isNegative => _value?.isNegative ?? false;

  /// The int value as a double
  ///
  /// Returns null if the int value is null
  double? toDouble() => _value?.toDouble();

  /// Returns the absolute value of this integer.
  ///
  /// Returns null if the int value is null
  int? abs() => _value?.abs();

  /// Adds [other] to this number.
  ///
  /// This does not set the value for this [ActiveNullableInt].
  ///
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  ///
  /// The result is an [int], as described by [int.+],
  /// if both this number and [other] is an integer,
  /// otherwise the result is a [double].
  E add<E extends num>(E other) {
    return isNotNull
        ? (_value! + other) as E
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Subtracts [other] from this number.
  ///
  /// This does not set the value for this [ActiveNullableInt].
  ///
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  ///
  /// The result is an [int], as described by [int.-],
  /// if both this number and [other] is an integer,
  /// otherwise the result is a [double].
  E subtract<E extends num>(E other) {
    return isNotNull
        ? (_value! - other) as E
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Divides this number by [other].
  ///
  /// This does not set the value for this [ActiveNullableInt].
  ///
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  double divide<E extends num>(E other) {
    return isNotNull
        ? _value! / other
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Euclidean modulo of this number by [other].
  ///
  /// This does not set the value for this [ActiveNullableInt].
  ///
  /// Returns the remainder of the Euclidean division.
  /// The Euclidean division of two integers `a` and `b`
  /// yields two integers `q` and `r` such that
  /// `a == b * q + r` and `0 <= r < b.abs()`.
  ///
  /// The Euclidean division is only defined for integers, but can be easily
  /// extended to work with doubles. In that case, `q` is still an integer,
  /// but `r` may have a non-integer value that still satisfies `0 <= r < |b|`.
  ///
  /// The sign of the returned value `r` is always positive.
  ///
  ///
  /// The result is an [int], as described by [int.%],
  /// if both this number and [other] are integers,
  /// otherwise the result is a [double].
  ///
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  ///
  /// Example:
  /// ```dart
  /// final number = ActiveIntNull(5);
  /// print(number % 3); // 2
  /// ```
  E mod<E extends num>(E other) {
    return isNotNull
        ? (_value! % other) as E
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Multiplies this number by [other].
  ///
  /// This does not set the value for this [ActiveNullableInt].
  ///
  /// The result is an [int], as described by [int.*],
  /// if both this number and [other] are integers,
  /// otherwise the result is a [double].
  ///
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  E multiply<E extends num>(E other) {
    return isNotNull
        ? (_value! * other) as E
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }
}
