import 'package:activity/activity.dart';

///Base class for any Activity specific exception
abstract class ActiveException implements Exception {
  final StackTrace? stackTrace;
  final String? typeName;
  final Type type;

  ActiveException(this.stackTrace, this.typeName, this.type);
}

/// [ActiveTypeNullException]
/// This is thrown when an exception happens on Nullable Activity Property that
/// has not been assigned a value
///
/// [CaseStudy]
/// 1. Performing an arithmetic operation on an [ActiveIntNull] when its null
/// 2. Checking an [ActiveBool] value when the value is null
/// 3...


class ActiveTypeNullException extends ActiveException {
  ActiveTypeNullException(super.stack, super.typeName, super.type);

  @override
  String toString() =>
      '[ActiveTypeNullException] : Value for ${typeName ?? type} is null.'
          '\nStack trace : $stackTrace';
}

/// [ActiveTypeNotAssignedException]
/// This is thrown when an exception happens on a value not assigned any type
/// value and there is an update on the value and UI
///
/// [CaseStudy]
/// 1. Trying to get any type value that has not been assigned
/// 2. Using a value that has not been assigned on the UI
/// 3...

class ActiveTypeNotAssignedException extends ActiveException {
  ActiveTypeNotAssignedException(
      super.stack, super.typeName, super.type);

  @override
  String toString() =>
      '[ActiveTypeNotAssignedException] : Value for ${typeName ?? type} changed '
          'and failed to update the UI. \nStack Trace: $stackTrace, '
          'add ${typeName ?? type} to list List<ActiveType> get activities';
}
