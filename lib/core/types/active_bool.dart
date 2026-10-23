part of 'package:activity/core/types/active_type.dart';

/// A non-nullable observable boolean.
///
/// Register fields in the owning controller before notifying updates. Mutating collection `.value` directly bypasses notifications; snapshots are shallow.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) · browser route `/#/values`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Toggle a flag
///
/// <!-- activity-snippet: class-activebool-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveBool(false);
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.toggle();
///     assert(controller.value.value);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Explicit state changes
///
/// <!-- activity-snippet: class-activebool-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveBool(false);
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.setTrue();
///     controller.value.setFalse();
///     assert(controller.value.isFalse);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveBool extends ActiveType<bool> {
  ActiveBool(super.value, {super.typeName});

  void toggle({bool notifyChange = true}) =>
      set(!value, notifyChange: notifyChange);

  /// Returns true if the current value is true.
  bool get isTrue => value;

  /// Returns true if the current value is false.
  bool get isFalse => !value;

  /// Updates the value to true.
  void setTrue({bool notifyChange = true}) =>
      set(true, notifyChange: notifyChange);

  /// Updates the value to false.
  void setFalse({bool notifyChange = true}) =>
      set(false, notifyChange: notifyChange);
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
/// <!-- activity-snippet: class-activenullablebool-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveNullableBool();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     assert(controller.value.isNull);
///     controller.value.setIfNull(() => true);
///     assert(controller.value.value == true);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Clear and restore absence
///
/// <!-- activity-snippet: class-activenullablebool-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveNullableBool();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value(true);
///     controller.value.reset();
///     assert(controller.value.value == null);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveNullableBool extends ActiveType<bool?> {
  ActiveNullableBool({bool? value, super.typeName}) : super(value);

  /// Returns true if the current value is not null and equals true.
  bool get isTrue => value == true;

  /// Returns true if the current value is not null and equals false.
  bool get isFalse => value == false;

  /// Returns true if the current value is null.
  @override
  bool get isNull => value == null;

  /// Updates the value to true.
  void setTrue({bool notifyChange = true}) =>
      set(true, notifyChange: notifyChange);

  /// Updates the value to false.
  void setFalse({bool notifyChange = true}) =>
      set(false, notifyChange: notifyChange);

  /// Updates the value to null.
  void setNull({bool notifyChange = true}) =>
      set(null, notifyChange: notifyChange);
}
