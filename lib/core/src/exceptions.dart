import 'package:activity/activity.dart';

/// Base class for any exception thrown within the Activity system.
///
/// All exceptions here include:
/// - [stackTrace]: where the exception was thrown
/// - [typeName]: optional identifier of the property involved
/// - [type]: the runtime type of the property or value
abstract class ActiveException implements Exception {
  final StackTrace? stackTrace;
  final String? typeName;
  final Type type;

  ActiveException(this.stackTrace, this.typeName, this.type);
}

/// [ActiveTypeNullException]
///
/// Thrown when accessing or operating on a nullable [ActiveType] that has not
/// been assigned a value (i.e. is `null`).
///
/// ### Common Scenarios:
/// - Using arithmetic operations on `ActiveIntNull`
/// - Evaluating a condition on `ActiveBoolNull`
/// - Accessing `.value` on a null-initialized ActiveType
class ActiveTypeNullException extends ActiveException {
  ActiveTypeNullException(
      super.stackTrace,
      super.typeName,
      super.type,
      );

  @override
  String toString() =>
      '[ActiveTypeNullException] : '
          'Value for ${typeName ?? type} is null.\n'
          'Stack Trace: $stackTrace';
}

/// [ActiveTypeNotAssignedException]
///
/// Thrown when an [ActiveType] is used before being registered with an
/// [ActiveController], i.e. it's missing from the `activities` list.
///
/// ### Common Scenarios:
/// - Attempting to notify changes on an unassigned property
/// - Updating a value that hasn't been linked to a controller
/// - Forgetting to include a property in `List<ActiveType> get activities`
class ActiveTypeNotAssignedException extends ActiveException {
  ActiveTypeNotAssignedException(
      super.stackTrace,
      super.typeName,
      super.type,
      );

  @override
  String toString() =>
      '[ActiveTypeNotAssignedException] : '
          'Value for ${typeName ?? type} was changed but not linked to a controller.\n'
          'This likely means ${typeName ?? type} is missing from your activities list.\n'
          'Stack Trace: $stackTrace';
}