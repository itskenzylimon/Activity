part of 'package:activity/core/types/active_type.dart';

/// Observable decimal values and transformations.
///
/// Register fields in the owning controller before notifying updates. Mutating collection `.value` directly bypasses notifications; snapshots are shallow.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) · browser route `/#/values`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Update progress
///
/// <!-- activity-snippet: class-activedouble-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveDouble(0.25);
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.increment(0.5);
///     assert(controller.value.value == 0.75);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Bound progress
///
/// <!-- activity-snippet: class-activedouble-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveDouble(0.25);
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value(1.5);
///     controller.value.clampTo(0, 1);
///     assert(controller.value.value == 1);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveDouble extends ActiveType<double> {
  ActiveDouble(super.value, {super.typeName});

  /// [setToZero]
  /// Sets [ActiveDouble] value to zero
  ///
  /// ## Example
  ///
  /// ```dart
  /// final bankAccountBalance = ActiveDouble.zero();
  /// ```
  factory ActiveDouble.setToZero({String? typeName}) {
    return ActiveDouble(0, typeName: typeName);
  }

  /// A number is negative if it's smaller than zero, or if it is the double
  /// -0.0. This precludes a NaN value like double.nan from being negative.

  bool get isNegative => _value.isNegative;

  /// Truncates this num to an integer and returns the result as an int.
  /// Equivalent to truncate.Truncates the double value and returns the int

  int toInt() => _value.toInt();

  /// Returns the integer closest to the double value.
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  `(3.5).round() == 4` and `(-3.5).round() == -4`.
  ///
  /// Throws an [UnsupportedError] if this number is not finite
  /// (NaN or an infinity).
  /// ```dart
  /// final number = ActiveDouble(3.25);
  /// print(number.round()); // 3
  ///
  /// number(3.5);
  /// print(number.round()); // 4
  ///
  /// number(3.75);
  /// print(number.round()); // 4
  /// ```
  int round() => _value.round();

  /// Returns the integer double value closest to the double value.
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  `(3.5).roundToDouble() == 4` and `(-3.5).roundToDouble() == -4`.
  ///
  /// If this is already an integer valued double, including `-0.0`, or it is not
  /// a finite value, the value is returned unmodified.
  ///
  /// For the purpose of rounding, `-0.0` is considered to be below `0.0`,
  /// and `-0.0` is therefore considered closer to negative numbers than `0.0`.
  /// This means that for a value `d` in the range `-0.5 < d < 0.0`,
  /// the result is `-0.0`.
  /// ```dart
  /// final number = ActiveDouble(3.25);
  /// print(number.roundToDouble()); // 3.0
  ///
  /// number(3.5);
  /// print(number.roundToDouble()); // 4.0
  ///
  /// number(3.75);
  /// print(number.roundToDouble()); // 4.0
  /// ```
  double roundToDouble() => _value.roundToDouble();

  /// Adds [other] to this number.
  ///
  /// This does not set the value for this [ActiveDouble].
  ///
  /// The result is an [double], as described by [double.+]
  double add<E extends num>(E other) {
    return _value + other;
  }

  /// Subtracts [other] from this number.
  ///
  /// This does not set the value for this [ActiveDouble].
  ///
  /// The result is an [double], as described by [double.-]
  double subtract<E extends num>(E other) {
    return _value - other;
  }

  /// Divides this number by [other].
  ///
  /// This does not set the value for this [ActiveDouble].
  ///
  /// The result is an [double], as described by [double./]
  double divide<E extends num>(E other) {
    return _value / other;
  }

  /// Euclidean modulo of this number by [other].
  ///
  /// This does not set the value for this [ActiveDouble].
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
  /// The result is an [double], as described by [double.%]
  ///
  /// Example:
  /// ```dart
  /// final number = ActiveDouble(5.0);
  /// print(number % 3); // 2.0
  /// ```
  double mod<E extends num>(E other) {
    return _value % other;
  }

  /// Multiplies this number by [other].
  ///
  /// This does not set the value for this [ActiveDouble].
  ///
  /// The result is an [double], as described by [double.*]
  double multiply<E extends num>(E other) {
    return _value * other;
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
/// <!-- activity-snippet: class-activitynullabledoubleproperty-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActivityNullableDoubleProperty();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     assert(controller.value.isNull);
///     controller.value.setIfNull(() => 4.5);
///     assert(controller.value.value == 4.5);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Clear and restore absence
///
/// <!-- activity-snippet: class-activitynullabledoubleproperty-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActivityNullableDoubleProperty();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value(4.5);
///     controller.value.reset();
///     assert(controller.value.value == null);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActivityNullableDoubleProperty extends ActiveType<double?> {
  ActivityNullableDoubleProperty({double? value, super.typeName})
    : super(value);

  factory ActivityNullableDoubleProperty.zero({String? typeName}) {
    return ActivityNullableDoubleProperty(value: 0, typeName: typeName);
  }

  /// Whether this number is negative.
  ///
  /// Returns false if the double value is null
  bool get isNegative => _value?.isNegative ?? false;

  /// Truncates the double value and returns the int
  ///
  /// Returns null if the double value is null
  int? toInt() => _value?.toInt();

  /// Returns the integer closest to the double value.
  ///
  /// Returns null if the double value is null
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  `(3.5).round() == 4` and `(-3.5).round() == -4`.
  ///
  /// Throws an [UnsupportedError] if this number is not finite
  /// (NaN or an infinity).
  /// ```dart
  /// final number = ActivityNullableDoubleProperty(value: 3.25);
  /// print(number.round()); // 3
  ///
  /// number(3.5);
  /// print(number.round()); // 4
  ///
  /// number(3.75);
  /// print(number.round()); // 4
  /// ```
  int? round() => _value?.round();

  /// Returns the integer double value closest to the double value.
  ///
  /// Returns null if the double value is null
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  `(3.5).roundToDouble() == 4` and `(-3.5).roundToDouble() == -4`.
  ///
  /// If this is already an integer valued double, including `-0.0`, or it is not
  /// a finite value, the value is returned unmodified.
  ///
  /// For the purpose of rounding, `-0.0` is considered to be below `0.0`,
  /// and `-0.0` is therefore considered closer to negative numbers than `0.0`.
  /// This means that for a value `d` in the range `-0.5 < d < 0.0`,
  /// the result is `-0.0`.
  /// ```dart
  /// final number = ActivityNullableDoubleProperty(value: 3.25);
  /// print(number.roundToDouble()); // 3.0
  ///
  /// number(3.5);
  /// print(number.roundToDouble()); // 4.0
  ///
  /// number(3.75);
  /// print(number.roundToDouble()); // 4.0
  /// ```
  double? roundToDouble() => _value?.roundToDouble();

  /// Adds [other] to this number.
  ///
  /// This does not set the value for this [ActivityNullableDoubleProperty].
  ///
  /// The result is an [double], as described by [double.+].
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  double add<E extends num>(E other) {
    return isNotNull
        ? _value! + other
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Subtracts [other] from this number.
  ///
  /// This does not set the value for this [ActivityNullableDoubleProperty].
  ///
  /// The result is an [double], as described by [double.-],
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  double subtract<E extends num>(E other) {
    return isNotNull
        ? _value! - other
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Divides this number by [other].
  ///
  /// This does not set the value for this [ActivityNullableDoubleProperty].
  ///
  /// The result is an [double], as described by [double./],
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
  /// This does not set the value for this [ActivityNullableDoubleProperty].
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
  /// The result is an [double], as described by [double.%]
  ///
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  ///
  /// Example:
  /// ```dart
  /// final number = ActivityNullableDoubleProperty(value: 5);
  /// print(number % 3); // 2.0
  /// ```
  double mod<E extends num>(E other) {
    return isNotNull
        ? _value! % other
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }

  /// Multiplies this number by [other].
  ///
  /// This does not set the value for this [ActivityNullableDoubleProperty].
  ///
  /// The result is an [double], as described by [double.*],
  /// If the underlying value is `null` throws an [ActiveTypeNullException].
  double multiply<E extends num>(E other) {
    return isNotNull
        ? _value! * other
        : throw ActiveTypeNullException(
          StackTrace.current,
          typeName,
          runtimeType,
        );
  }
}
