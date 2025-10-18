/// Stream Events connected to the State
/// Use [ActiveController.addOnStateChangedListener] to get notified of these events.
class ActiveStateChanged<T> {
  final T? oldValue;
  final T? newValue;
  final String? typeName;
  final String? info;

  ActiveStateChanged(this.newValue, this.oldValue, {this.typeName, this.info});

  // ======= FACTORY HELPERS FOR LISTS =======

  static ActiveStateChanged<T> addActiveList<T>(T newValue, {String? typeName}) =>
      ActiveStateChanged(newValue, null,
          typeName: typeName, info: 'A new value added: $newValue');

  static ActiveStateChanged<Iterable<T>> addAllActiveList<T>(
      Iterable<T> newValues, {String? typeName}) =>
      ActiveStateChanged(newValues, null,
          typeName: typeName, info: 'List values added: $newValues');

  static ActiveStateChanged<T> removeActiveList<T>(T removedValue,
      {String? typeName}) =>
      ActiveStateChanged(null, removedValue,
          typeName: typeName, info: 'Value removed: $removedValue');

  static ActiveStateChanged<Iterable<T>> clearActiveList<T>(
      Iterable<T> oldValues, {String? typeName}) =>
      ActiveStateChanged(<T>[], oldValues,
          typeName: typeName, info: 'List cleared');

  static ActiveStateChanged<T> insertIntoList<T>(int index, T value,
      {String? typeName}) =>
      ActiveStateChanged(value, null,
          typeName: typeName, info: 'Inserted $value at index $index');

  static ActiveStateChanged<Iterable<T>> insertAllIntoList<T>(
      int index, Iterable<T> values, {String? typeName}) =>
      ActiveStateChanged(values, null,
          typeName: typeName,
          info: 'Inserted all $values at index $index');

  static ActiveStateChanged<T> removedFromList<T>(T removedValue,
      {String? typeName}) =>
      ActiveStateChanged(null, removedValue,
          typeName: typeName, info: 'Removed from list: $removedValue');

  // ======= FACTORY HELPERS FOR MAPS =======

  static ActiveStateChanged<Map<K, V>> addActiveMap<K, V>(Map<K, V> addedMap,
      {String? typeName}) =>
      ActiveStateChanged(addedMap, null,
          typeName: typeName, info: 'Added map: $addedMap');

  static ActiveStateChanged<MapEntry<K, V>> entryActiveMap<K, V>(
      K key, V newValue,
      {String? typeName}) {
    final entry = MapEntry(key, newValue);
    return ActiveStateChanged(entry, null,
        typeName: typeName, info: 'Added entry to map: $entry');
  }

  static ActiveStateChanged<Iterable<MapEntry<K, V>>> entriesActiveMap<K, V>(
      Iterable<MapEntry<K, V>> entries,
      {String? typeName}) =>
      ActiveStateChanged(entries, null,
          typeName: typeName, info: 'Added entries to map: $entries');

  static ActiveStateChanged<V> updateActiveMap<K, V>(
      K key, V? oldValue, V? newValue,
      {String? typeName}) =>
      ActiveStateChanged(newValue, oldValue,
          typeName: typeName, info: 'Map key $key updated to: $newValue');

  static ActiveStateChanged<V> removedActiveMap<K, V>(K key, V removedValue,
      {String? typeName}) {
    final entry = MapEntry(key, removedValue);
    return ActiveStateChanged(null, removedValue,
        typeName: typeName, info: 'Removed from map: $entry');
  }

  @override
  String toString() {
    return 'Old value : $oldValue, New value : $newValue, Type name : $typeName, Type info : $info';
  }
}

/// Extension methods on a list of ActiveStateChanged<T>
extension ActiveStateChangedExtensions<T> on List<ActiveStateChanged<T>> {
  /// Returns `true` if the list contains a change event with the specified [typeName].
  bool containsPropertyName(String typeName) {
    return any((e) => e.typeName == typeName);
  }

  /// Returns the first change event with the specified [typeName], or `null` if not found.
  ActiveStateChanged<T>? firstForPropertyName(String typeName) {
    for (final e in this) {
      if (e.typeName == typeName) return e;
    }
    return null;
  }

  /// Returns the `newValue` from the first change event with the specified [typeName].
  /// Returns `null` if not found.
  T? newValueFor(String typeName) {
    final event = firstForPropertyName(typeName);
    return event?.newValue;
  }

  /// Returns the `oldValue` from the first change event with the specified [typeName].
  /// Returns `null` if not found.
  T? oldValueFor(String typeName) {
    final event = firstForPropertyName(typeName);
    return event?.oldValue;
  }
}