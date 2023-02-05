import 'dart:math';

class UniqueID {
  static final Random _random = Random.secure();
  static int _timestamp = DateTime.now().millisecondsSinceEpoch;
  static final String _uniqueKey = _random.nextInt(1000000).toString();

  static String generateUuid() {
    String uuid = (_timestamp++).toString() + _uniqueKey;
    return uuid;
  }
}