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

/// Typed reactive state, snapshots and explicit value comparisons.
///
/// Register fields in the owning controller before notifying updates. Mutating collection `.value` directly bypasses notifications; snapshots are shallow.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) · browser route `/#/values`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Set and reset
///
/// <!-- activity-snippet: class-activetype-t-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveType<String>('draft');
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value('saved');
///     assert(controller.value.value == 'saved');
///     controller.value.reset();
///     assert(controller.value.value == 'draft');
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Transform and compare
///
/// <!-- activity-snippet: class-activetype-t-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveType<String>('draft');
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.updateValue((text) => text.toUpperCase());
///     assert(controller.value.equals('DRAFT'));
///     assert(!controller.value.setIfChanged('DRAFT'));
///     // Wrapper == is identity equality; equals compares the stored value.
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveType<T> implements ActiveTypeValue<T> {
  /// Optional name identifier for this type.
  String? typeName;

  /// Stores the original value before any changes.
  late T _originalValue;
  T get originalValue => snapshot(_originalValue);

  /// Stores a mock or temporary value (optional, for testing or preview purposes).
  T? _mockValue;
  bool _hasMockValue = false;
  T get mockValue => _hasMockValue ? _mockValue as T : _value;
  set mockValue(T value) {
    _mockValue = value;
    _hasMockValue = true;
  }

  /// Override for shallow collection copies or custom model snapshots.
  T snapshot(T value) => value;

  /// Read-only shallow payload for events.
  T eventSnapshot(T value) => snapshot(value);
  bool accepts(Object? value) => value is T;

  T updateValue(T Function(T value) transform, {bool notifyChange = true}) {
    ensureCanMutate();
    return set(transform(snapshot(value)), notifyChange: notifyChange);
  }

  R select<R>(R Function(T value) selector) => selector(value);

  bool setIfChanged(T next, {bool notifyChange = true}) {
    if (value == next) return false;
    set(next, notifyChange: notifyChange);
    return true;
  }

  ActiveUpdate<T> changeTo(T next) => ActiveUpdate(this, next);

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
        StackTrace.current,
        typeName,
        runtimeType,
      );
    }
    return _activeController!;
  }

  /// Creates a new instance of [ActiveType] with the given [value].
  ActiveType(this._value, {this.typeName}) {
    _originalValue = snapshot(_value);
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
  void setOriginalValueToCurrent([String? typeName]) {
    _originalValue = snapshot(_value);
  }

  /// Forces the original value to a specific one.
  ///
  /// Useful for programmatically overriding what is considered the “original state”.
  void setToOriginal(T value) {
    _originalValue = snapshot(value);
  }

  /// Updates the internal [value].
  ///
  /// If [notifyChange] is true, it will trigger UI rebuilds
  /// through the controller's [ActiveController.notifyActivities].
  ///
  /// Optionally mark this new value as the new [originalValue].
  void ensureCanMutate() {
    if (_activeController?.isDisposed ?? false) {
      throw StateError('The owning ActiveController has been disposed.');
    }
  }

  T set(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    ensureCanMutate();
    if (notifyChange && _value != value) activeController;
    final changed = _value != value;
    final oldValue = eventSnapshot(_value);
    _value = value;

    if (notifyChange && changed) {
      activeController.notifyActivities([
        ActiveStateChanged(eventSnapshot(value), oldValue, typeName: typeName),
      ]);
    }

    if (setAsOriginal) {
      _originalValue = snapshot(value);
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
  /// age(30, notifyChange: false);
  /// age.reset(notifyChange: false); // Back to 20, without an owner.
  /// // For UI updates, register age in a controller and leave notifications on.
  /// ```
  void reset({bool notifyChange = true}) {
    ensureCanMutate();
    if (notifyChange) activeController;
    final currentValue = eventSnapshot(_value);
    _value = snapshot(_originalValue);

    if (notifyChange) {
      activeController.notifyActivities([
        ActiveStateChanged(
          eventSnapshot(_value),
          currentValue,
          typeName: typeName,
        ),
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
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
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

/// A typed assignment for a controller batch.
///
/// Use controller.activate for preflight checks and one event list. Batches do not roll back arbitrary user-defined setter side effects.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#models) · browser route `/#/models`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Commit related values together
///
/// <!-- activity-snippet: class-activeupdate-t-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class DraftController extends ActiveController {
///   final count = ActiveInt(0);
///   final title = ActiveString('draft');
///   @override
///   Iterable<ActiveType> get activities => [count, title];
/// }
///
/// Future<void> main() async {
///   final controller = DraftController();
///   try {
///     controller.activate([
///       controller.count.changeTo(2),
///       controller.title.changeTo('saved'),
///     ]);
///     assert(controller.count.value == 2 && controller.title.value == 'saved');
///   } finally {
///     await controller.dispose();
///   }
/// }
/// ```
///
/// ### Restore a coherent draft
///
/// <!-- activity-snippet: class-activeupdate-t-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class DraftController extends ActiveController {
///   final count = ActiveInt(0);
///   final title = ActiveString('draft');
///   @override
///   Iterable<ActiveType> get activities => [count, title];
/// }
///
/// Future<void> main() async {
///   final controller = DraftController();
///   try {
///     controller.activate([
///       controller.count.changeTo(5),
///       controller.title.changeTo('edited'),
///     ]);
///     controller.resetAllActiveTypes();
///     assert(controller.count.value == 0 && controller.title.value == 'draft');
///   } finally {
///     await controller.dispose();
///   }
/// }
/// ```
class ActiveUpdate<T> {
  final ActiveType<T> target;
  final T next;
  const ActiveUpdate(this.target, this.next);
  ActiveStateChanged commit() {
    final old = target.eventSnapshot(target.value);
    target.set(next, notifyChange: false);
    return ActiveStateChanged(
      target.eventSnapshot(next),
      old,
      typeName: target.typeName,
    );
  }
}
