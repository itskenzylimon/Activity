part of 'package:activity/core/types/active_type.dart';

/// An [ActiveType] with similar characteristics as a an
/// ordinary dart bool object. When an update is done an [ActiveStateChanged]
/// event is triggered which in-turn makes a UI rebuild of that widget.
///
/// Has similar characteristics as bool and The value cannot be null

class ActiveBool extends ActiveType<bool> {
  ActiveBool(super.value, {super.typeName});

  ///Whether the underlying value is true
  bool get isTrue => _value;

  ///Whether the underlying value is false
  bool get isFalse => !_value;

  ///Sets the value to true
  void setTrue({bool notifyChange = true}) =>
      super.set(true, notifyChange: notifyChange);

  ///Sets the value to false
  void setFalse({bool notifyChange = true}) =>
      super.set(false, notifyChange: notifyChange);
}

/// [ActiveNullableBool]
/// ordinary dart bool object. When an update is done an [ActiveStateChanged]
/// event is triggered which in-turn makes a UI rebuild of that widget.
///
/// Has similar characteristics as bool and The value can exist as null

class ActiveNullableBool extends ActiveType<bool?> {
  ActiveNullableBool({bool? value, super.typeName}) : super(value);

  ///Whether the underlying value is not null and true
  bool get isTrue => isNotNull && _value == true;

  ///Whether the underlying value is not null and false
  bool get isFalse => isNotNull && _value == false;

  ///Sets the value to true
  void setTrue({bool notifyChange = true}) =>
      super.set(true, notifyChange: notifyChange);

  ///Sets the value to false
  void setFalse({bool notifyChange = true}) =>
      super.set(false, notifyChange: notifyChange);

  ///Sets the value to null
  void setNull({bool notifyChange = true}) =>
      super.set(null, notifyChange: notifyChange);
}
