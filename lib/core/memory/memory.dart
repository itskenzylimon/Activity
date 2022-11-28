import '../types/active_memory.dart';

class Memory {
  Memory._();
  static final Memory memory = Memory._();

  final Map<String, ActiveMemory> _data = {};

  bool get isDataEmpty {
    _data.removeWhere((key, value) => _isMemoryActive(value));
    return _data.isEmpty;
  }

  bool get isMemoryEmpty => !isDataEmpty;

  /// Get all data from [ActiveMemory].
  ///
  /// Will return empty list if entries are not found
  List readMemories() {
    return _data.entries.toList();
  }


  /// Get data from [ActiveMemory].
  ///
  /// Will return null if entry is not found
  ActiveMemory? readMemory<ActiveMemory>(String key) {
    if (_validateMemory(key)) {
      final item = _data[key]!;
      return item.activeType;
    }
    return null;
  }

  /// It creates an entry in [ActiveMemory] if the value does not exist.
  ///
  /// If the [key] is not found it returns [true].
  ///
  /// If the [key] is found it returns [false].
  ///
  /// Use this in situations where you are uncertain if a [key] exists and
  /// your not planning to update the current value.
  bool createMemory<T>(String key,
      T activeType, {Duration? duration}) {
    if (!_validateMemory(key)) {
      createMemory(key, activeType, duration: duration);
      return true;
    }
    return false;
  }

  /// Creates new entry in [ActiveMemory].
  ///
  /// If a value exist it does an update in initialize.
  void upsertMemory<T>(String key,
      T activeType, {Duration? duration}) {
    _data[key] = ActiveMemory<T>.create(activeType,
        dateTime: _setMemoryExpiry(duration));
  }

  /// Updates a [key] value in [ActiveMemory] with the new value.
  ///
  /// If the [key] is not found it returns [false].
  ///
  /// If the [key] is found it returns [true].
  bool updateMemory<T>(String key,
      T activeType, {Duration? duration}) {
    if (_validateMemory(key)) {
      _data[key] = _data[key]!.copyWith(
        activeType: activeType,
        expiresAt: _setMemoryExpiry(duration),
      );
      return true;
    }
    return false;
  }

  /// Removes entry from [ActiveMemory].
  ///
  /// Checks if a key exists in [ActiveMemory] before removing entry
  void deleteMemory(String key) {
    if(_validateMemory(key) == true){
      _data.remove(key);
    }
  }

  /// Removes all values stored on [ActiveMemory]
  ///
  /// Clears every entry
  void resetMemory() {
    _data.clear();
  }

  /// Checks if a key exists in Active Memory
  ///
  /// returns [true] if key is found.
  ///
  /// returns [false] if value does not exist.
  bool hasMemory(String key) {
    return _validateMemory(key);
  }

  /// Sets Active Memory entry expiry date
  DateTime? _setMemoryExpiry(Duration? expiry) =>
      expiry != null ? DateTime.now().add(expiry) : null;

  /// Checks Active Memory entry expiry date
  /// returns [false] if entry has not expired and [true] if its before expiry
  bool _isMemoryActive(ActiveMemory activeMemory) {
    if (activeMemory.expiresAt != null && activeMemory.expiresAt!.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  /// This func validates if activeMemory key is expired, if so it removes the
  /// data and returns [false], if not it returns true
  bool _validateMemory(String key) {
    final entry = _data[key];
    if (entry == null) {
      return false;
    } else if (_isMemoryActive(entry)) {
      deleteMemory(key);
      return false;
    }
    return true;
  }
}