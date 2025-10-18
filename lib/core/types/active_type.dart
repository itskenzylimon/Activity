import 'package:activity/core/src/exceptions.dart';
import 'package:activity/core/src/controller.dart';
import '../src/state.dart';

part 'active_bool.dart';
part 'active_int.dart';
part 'active_double.dart';
part 'active_string.dart';
part 'active_map.dart';
part 'active_list.dart';
part 'active_datetime.dart';

/// Base interface defining readable value access for Active types.
abstract class ActiveTypeValue<T> {
  T? get value;
}

/// [ActiveType] is a reactive container class designed to hold a mutable value
/// that can automatically notify an [ActiveController] when changed.
///
/// It enables reactive UI updates and state tracking via the `activity` package.
///
/// Example usage:
/// ```dart
/// final name = ActiveType<String>('Bob');
/// name('Alice'); // Updates and notifies the controller
/// name.reset();  // Reverts to the original value
/// ```
class ActiveType<T> implements ActiveTypeValue<T> {
  /// Optional name identifier for this type.
  String? typeName;

  /// Stores the original value before any changes.
  late T _originalValue;
  T get originalValue => _originalValue;

  /// Stores a mock or temporary value (optional, for testing or preview purposes).
  late T _mockValue;
  T get mockValue => _mockValue;

  /// The current value.
  T _value;

  @override
  T get value => _value;

  /// Returns `true` if the value is `null`.
  bool get isNull => _value == null;

  /// Returns `true` if the value is **not** `null`.
  bool get isNotNull => !isNull;

  /// The controller managing this active type.
  ActiveController? _activeController;

  /// Returns the assigned [ActiveController] or throws an exception
  /// if this ActiveType is not linked to any controller.
  ActiveController get activeController {
    if (_activeController == null) {
      throw ActiveTypeNotAssignedException(
          StackTrace.current, typeName, runtimeType);
    }
    return _activeController!;
  }

  /// Creates a new instance of [ActiveType] with the given [value].
  ActiveType(this._value, {this.typeName}) {
    _originalValue = _value;
  }

  /// Links this ActiveType instance to an [ActiveController].
  void setActiveController(ActiveController activeController) {
    _activeController = activeController;
  }

  /// Function-call syntax for setting a new value.
  ///
  /// Example:
  /// ```dart
  /// final age = ActiveType<int>(10);
  /// age(25); // same as age.set(25)
  /// ```
  void call(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    set(value, notifyChange: notifyChange, setAsOriginal: setAsOriginal);
  }

  /// Updates the original value to the current value.
  ///
  /// Example:
  /// ```dart
  /// user.setOriginalValueToCurrent();
  /// ```
  void setOriginalValueToCurrent(String? typeName) {
    _originalValue = _value;
  }

  /// Forces the original value to a specific one.
  ///
  /// Useful for programmatically overriding what is considered the “original state”.
  void setToOriginal(T value) {
    _originalValue = value;
  }

  /// Updates the internal [value].
  ///
  /// If [notifyChange] is true, it will trigger UI rebuilds
  /// through the controller's [notifyActivities].
  ///
  /// Optionally mark this new value as the new [originalValue].
  T set(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    final oldValue = _value;
    _value = value;

    if (notifyChange && oldValue != value) {
      activeController.notifyActivities([
        ActiveStateChanged(value, oldValue, typeName: typeName),
      ]);
    }

    if (setAsOriginal) {
      _originalValue = value;
    }

    return _value;
  }

  /// Resets the value back to the original state.
  ///
  /// If [notifyChange] is true, triggers state rebuilds.
  ///
  /// Example:
  /// ```dart
  /// final age = ActiveType<int>(20);
  /// age(30);
  /// age.reset(); // back to 20
  /// ```
  void reset({bool notifyChange = true}) {
    final currentValue = _value;
    _value = _originalValue;

    if (notifyChange) {
      activeController.notifyActivities([
        ActiveStateChanged(_originalValue, currentValue, typeName: typeName),
      ]);
    }
  }

  /// Compares the current value to another [ActiveType] or raw object.
  ///
  /// Example:
  /// ```dart
  /// age.equals(10);
  /// otherAge.equals(age);
  /// ```
  bool equals(dynamic other) {
    return other is ActiveType ? other.value == value : other == value;
  }

  @override
  String toString() => _value?.toString() ?? '';

  @override
  bool operator ==(dynamic other) => equals(other);

  @override
  int get hashCode => _value.hashCode;
}

/// Creates a non-nullable [ActiveType] with an initial value.
///
/// Example:
/// ```dart
/// final name = createActiveType('Alice');
/// ```
ActiveType<T> createActiveType<T>(T value, {String? typeName}) {
  return ActiveType<T>(value, typeName: typeName);
}

/// Creates a nullable [ActiveType] with no initial value.
///
/// Example:
/// ```dart
/// final name = createActiveNullableType<String>();
/// ```
ActiveType<T?> createActiveNullableType<T>({String? typeName}) {
  return createActiveType(null, typeName: typeName);
}