part of 'package:activity/core/types/active_type.dart';

/// [ActiveBool]
/// A strongly-typed reactive boolean property that is **non-nullable**.
///
/// It notifies its [ActiveController] when updated,
/// causing reactive widgets to rebuild.
///
/// ### Example:
/// ```dart
/// final isVisible = ActiveBool(false);
/// isVisible.setTrue();  // Sets to true and notifies listeners
/// if (isVisible.isFalse) { ... }
/// ```
class ActiveBool extends ActiveType<bool> {
  ActiveBool(super.value, {super.typeName}) {
    assert(value != null, '[ActiveBool] must be initialized with non-null value');
  }

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

/// [ActiveNullableBool]
/// A reactive boolean property that **can be null**.
///
/// Behaves similarly to Dart's `bool?` and supports null safety,
/// while maintaining the reactivity of [ActiveType].
///
/// ### Example:
/// ```dart
/// final isLoading = ActiveNullableBool();
/// isLoading.setTrue();
/// if (isLoading.isFalse) { ... }
/// isLoading.setNull();
/// ```
class ActiveNullableBool extends ActiveType<bool?> {
  ActiveNullableBool({bool? value, super.typeName}) : super(value);

  /// Returns true if the current value is not null and equals true.
  bool get isTrue => value == true;

  /// Returns true if the current value is not null and equals false.
  bool get isFalse => value == false;

  /// Returns true if the current value is null.
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
