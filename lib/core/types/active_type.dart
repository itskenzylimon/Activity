import 'dart:io';

import 'package:activity/core/helpers/logger.dart';
import 'package:activity/core/memory/memory.dart';
import 'package:activity/core/src/exceptions.dart';
import 'package:activity/core/src/controller.dart';

part 'active_bool.dart';
part 'active_int.dart';
part 'active_double.dart';
part 'active_string.dart';
part 'active_map.dart';
part 'active_list.dart';
part 'active_datetime.dart';

abstract class ActiveTypeValue<T> {
  T? get value;
}


/// An [ActiveType] can take the nature of any any object type. When an update is
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
class ActiveType<T> implements ActiveTypeValue<T> {
  String? typeName;

  Memory memory = Memory(filename: '${Directory.current.path}/activity-data.act');

  late T _originalValue;
  T get originalValue => _originalValue;

  late T _mockValue;
  T get mockValue => _mockValue;

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

  ActiveType(this._value, {this.typeName}) {
    _originalValue = _value;
  }

  ///Links this ActiveType instance with an [ActiveController].
  ///
  void setActiveController(ActiveController activeController) {
    _activeController = activeController;
  }

  /// Updates the underlying [value] for this ActiveType.
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
  void setOriginalValueToCurrent(String typeName) async {
    var data = await memory.readMemory(typeName);
    printError(data);
    if (data != null) {
       _originalValue = data;
      set(data, setAsOriginal: true);
    } else {
      _originalValue = _value;
    }
  }
  
  void setToOriginal(dynamic value, String typeName) async {
    memory.insertMemory(typeName, value);

    var data = await memory.readMemory(typeName);
    if (data != null) {
      _originalValue = data;
    } else {
      _originalValue = _value;
    }
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
  ///instead of updating this ActiveType with a new instance of [T] with the updated values will
  ///prevent [reset] from performing as expected. Tracking the original value is done by reference
  ///internally.
  ///
  ///## Usage
  ///
  ///```dart
  ///final age = ActiveType<int>(10); //age.value is 10
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

  ///Checks if [other] is equal to the [value] of this ActiveType
  ///
  ///### Usage
  ///
  ///```dart
  ///final age = ActiveType<int>(10);
  ///
  ///age.equals(10); //returns true
  ///
  ///
  ///final ageTwo = ActiveType<int>(10);
  ///
  ///age.equals(ageTwo); //returns true
  ///```
  bool equals(dynamic other) {
    if (other is ActiveType) {
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

/// ## createActiveType
/// Short hand helper function to Create a non nullable value
/// An [ActiveType] can take the nature of any any object type. When an update is
/// done an [ActiveStateChanged] event is triggered which in-turn makes a UI rebuild of that widget.
///
///## Example
///
///```dart
///late final ActiveType<String> name;
///
///name = createProperty('Bob');
///```
ActiveType<T> createActiveType<T>(T value, {String? typeName}) {
  return ActiveType<T>(value, typeName: typeName);
}


/// [createActiveNullableType]
/// Create a nullable value
/// An [ActiveType] can take the nature of any any object type. When an update is
/// done an [ActiveStateChanged] event is triggered which in-turn makes a UI rebuild of that widget.
///
///## Example
///
///```dart
///late final ActiveType<String?> name;
///
///name = createNullProperty();
///
///```
ActiveType<T?> createActiveNullableType<T>({String? typeName}) {
  return createActiveType(null, typeName: typeName);
}
