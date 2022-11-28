import 'package:activity/core/src/exceptions.dart';
import 'package:activity/core/src/controller.dart';

abstract class ActiveModelValue<T> {
  T? get value;
}


/// An [ActiveModel] can take the nature of any any object type. When an update is
/// done an [ActiveStateChanged] event is triggered which in-turn makes a UI rebuild of that widget.
/// [UseCases]
///
///*Using [set]*:
///```dart
/////initialize the property value to zero.
///final age = createProperty<int>(0);
///
/////update the property value to five.
///age.set(5);
///```
///
///-----------------------------------------
///
///*Calling the property*:
///```dart
/////initialize the property value to zero.
///final age = createProperty<int>(0);
///
/////update the property value to five.
///age(5);
///```
class ActiveModel<T> implements ActiveModelValue<T> {
  String? typeName;

  late T _originalValue;
  T get originalValue => _originalValue;

  T _value;

  @override
  T get value => _value;

  /// Returns true if the value of [this] is null.
  ///
  bool get isNull => _value == null;

  /// Returns true if the value of [this] is not null.
  bool get isNotNull => !isNull;

  ActiveController? _activeController;

  /// Returns the instance of the [ActiveController] this
  /// property is associated with.
  ///
  ActiveController get activeController {
    if (_activeController == null) {
      throw ActiveTypeNotAssignedException(
          StackTrace.current, typeName, runtimeType);
    } else {
      return _activeController!;
    }
  }

  ActiveModel(this._value, {this.typeName}) {
    _originalValue = _value;
  }

  ///Links this ActiveModel instance with an [ActiveController].
  ///
  void setActiveController(ActiveController activeController) {
    _activeController = activeController;
  }

  /// Updates the underlying [value] for this ActiveModel.
  ///
  /// If [notifyChange] is true, a UI update will be triggered after the change occurs. Otherwise,
  /// only the value will be set.
  ///
  /// If [setAsOriginal] is true, updating the value will also set the [originalValue] to the
  /// current value. See also [setOriginalValueToCurrent] and [reset]
  ///
  void call(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    set(value, notifyChange: notifyChange, setAsOriginal: setAsOriginal);
  }

  ///Updates the original value to what the current value of this property is.
  ///
  ///If this function is called, the [reset] function will then use the updated
  ///original value to set the current value
  ///
  ///## Example
  ///```dart
  ///final user = createNullProperty<User>();
  ///
  ///user(await userService.loadUser());
  ///
  ///user.reset(); //user value would be reset to null
  ///
  ///user(await userService.loadUser());
  ///
  ///user.setOriginalValueToCurrent();
  ///
  ///user(null);
  ///
  ///user.reset(); //user value would be reset to the user returned from the userService
  ///
  ///```
  void setOriginalValueToCurrent() {
    _originalValue = _value;
  }

  ///Updates the property value. Notifies any listeners to the change
  ///
  ///Returns the updated value
  T set(T value, {bool notifyChange = true, bool setAsOriginal = false}) {
    final oldValue = _value;
    _value = value;
    if (notifyChange && oldValue != value) {
      activeController.notifyActivities([
        ActiveStateChanged(value, oldValue, typeName: typeName)
      ]);
    }

    if (setAsOriginal) {
      _originalValue = _value;
    }

    return _value;
  }

  ///Resets the [value] to the [originalValue].
  ///
  ///If [T] is a  class with properties, changing the properties directly on the object
  ///instead of updating this ActiveModel with a new instance of [T] with the updated values will
  ///prevent [reset] from performing as expected. Tracking the original value is done by reference
  ///internally.
  ///
  ///## Usage
  ///
  ///```dart
  ///final age = ActiveModel<int>(10); //age.value is 10
  ///
  ///age(20); //age.value is 20
  ///age(25); //age.value is 25
  ///
  ///age.reset(); //age.value is back to 10. Triggers UI rebuild or...
  ///
  ///age.reset(notifyChange: false); //age.value is back to 10 but UI does not rebuild
  ///```
  void reset({bool notifyChange = true}) {
    final currentValue = _value;
    _value = _originalValue;

    if (notifyChange) {
      activeController.notifyActivities([
        ActiveStateChanged(
          _originalValue,
          currentValue,
          typeName: typeName,
        )
      ]);
    }
  }

  @override
  String toString() => _value?.toString() ?? '';

  ///Checks if [other] is equal to the [value] of this ActiveModel
  ///
  ///### Usage
  ///
  ///```dart
  ///final age = ActiveModel<int>(10);
  ///
  ///age.equals(10); //returns true
  ///
  ///
  ///final ageTwo = ActiveModel<int>(10);
  ///
  ///age.equals(ageTwo); //returns true
  ///```
  bool equals(dynamic other) {
    if (other is ActiveModel) {
      return other.value == value;
    } else {
      return other == value;
    }
  }

  @override
  bool operator ==(dynamic other) => equals(other);

  @override
  int get hashCode => _value.hashCode;
}

/// [createActiveModel]
/// Short hand helper function to Create a non nullable value
/// An [ActiveModel] can take the nature of any any object type. When an update is
/// done an [ActiveStateChanged] event is triggered which in-turn makes a UI rebuild of that widget.
///
///## Example
///
///```dart
///late final ActiveModel<String> name;
///
///name = createProperty('Bob');
///```
ActiveModel<T> createActiveModel<T>(T value, {String? typeName}) {
  return ActiveModel<T>(value, typeName: typeName);
}


/// [createActiveNullableModel]
/// Create a nullable value
/// An [ActiveModel] can take the nature of any any object type. When an update is
/// done an [ActiveStateChanged] event is triggered which in-turn makes a UI rebuild of that widget.
///
///## Example
///
///```dart
///late final ActiveModel<String?> name;
///
///name = createNullProperty();
///
///```
ActiveModel<T?> createActiveNullableModel<T>({String? typeName}) {
  return createActiveModel(null, typeName: typeName);
}
