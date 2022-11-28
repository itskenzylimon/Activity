///[ErrorEvent]
/// Event handler registered to [ActiveController.addOnStateChangedListener]
///
/// [error] the error received from the system
/// [stackTrace]
/// [errorData] any additional data passed to the [ErrorEvent]

class ErrorEvent<T> {
  final T error;
  final StackTrace? stackTrace;
  final Map<dynamic, dynamic> errorData;

  /// If no values are passed to the [errorData] the data will be made to null
  /// we do this by checking if a key is available in the map

  E? getErrorData<E>(dynamic key) {
    if (errorData.containsKey(key)) {
      return errorData[key] as E;
    }
    return null;
  }

  ErrorEvent(this.error, {this.stackTrace, this.errorData = const {}});

  @override
  String toString() =>
      'Exception : ${error.toString()}\nStack Trace : $stackTrace\nError Data :'
          '${errorData.toString()}';
}