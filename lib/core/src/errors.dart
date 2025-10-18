/// [ErrorEvent]
/// A data structure used to represent an error emitted by the [ActiveController].
///
/// This is dispatched through [ActiveController.onActiveErrorListener] and contains:
/// - The original [error] thrown or caught
/// - An optional [stackTrace]
/// - Optional [errorData] for debugging or recovery context
class ErrorEvent<T> {
  /// The actual error or exception object.
  final T error;

  /// Stack trace captured at the point of the error (optional).
  final StackTrace? stackTrace;

  /// A map of additional context or metadata related to the error.
  ///
  /// This is useful for passing extra diagnostics, such as operation name,
  /// user ID, request payload, etc.
  final Map<dynamic, dynamic> errorData;

  /// Creates a new instance of [ErrorEvent].
  ///
  /// If [errorData] is not supplied, an empty map is used.
  ErrorEvent(
      this.error, {
        this.stackTrace,
        this.errorData = const {},
      });

  /// Retrieves a strongly-typed value from the [errorData] map using [key].
  ///
  /// Returns null if the key does not exist or cannot be cast to type [E].
  ///
  /// Example:
  /// ```dart
  /// final errorEvent = ErrorEvent('Something went wrong', errorData: {'userId': 42});
  /// final userId = errorEvent.getErrorData<int>('userId'); // returns 42
  /// ```
  E? getErrorData<E>(dynamic key) {
    if (errorData.containsKey(key)) {
      return errorData[key] as E;
    }
    return null;
  }

  @override
  String toString() {
    return 'Exception: ${error.toString()}\n'
        'Stack Trace: $stackTrace\n'
        'Error Data: ${errorData.toString()}';
  }
}