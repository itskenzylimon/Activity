import 'dart:math';

/// this is a helper class that can be used to generate a unique id.
class UniqueID {
  /// _random is a private static variable of type Random.secure() that is used
  /// to generate a cryptographically secure random number generator.
  static final Random _random = Random.secure();
  static int _timestamp = DateTime.now().millisecondsSinceEpoch;
  static final String _uniqueKey = _random.nextInt(1000000).toString();

  /// generateUuid is a static method that is used to generate a unique id. based
  /// on the current timestamp and a random cryptographically number.
  static String generateUuid() {
    String uuid = (_timestamp++).toString() + _uniqueKey;
    return uuid;
  }
}