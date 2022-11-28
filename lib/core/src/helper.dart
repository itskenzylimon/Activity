import 'controller.dart';


/// [ActiveStateHelper]
extension ActiveStateHelper<T> on List<ActiveStateChanged<T>> {

  /// [hasTypeName]
  /// Checks if a [typeName] is found.
  bool hasTypeName(String typeName) {
    return map((x) => x.typeName).contains(typeName);
  }

  /// [firstActiveType]
  /// First event in [ActiveStateChanged.typeName], will return null if no
  /// event is found

  ActiveStateChanged<T>? firstActiveType(String typeName) {
    final events = where((e) => e.typeName == typeName);

    return events.isNotEmpty ? events.first : null;
  }

  /// [newActiveTypeValue]
  /// New value for [ActiveStateChanged.newValue] for First event in
  /// [ActiveStateChanged.typeName] that matches typeName

  T? newActiveTypeValue(String typeName) {
    return firstActiveType(typeName)?.newValue;
  }

  /// [oldActiveTypeValue]
  /// Old value for [ActiveStateChanged.newValue] for First event in
  /// [ActiveStateChanged.typeName] that matches typeName

  T? oldActiveTypeValue(String typeName) {
    return firstActiveType(typeName)?.newValue;
  }
}