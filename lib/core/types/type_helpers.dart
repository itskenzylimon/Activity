import 'active_type.dart';

extension ActiveNumericHelpers<N extends num> on ActiveType<N> {
  bool get isPositive => value > 0;
  bool get isNegative => value < 0;
  bool get isZero => value == 0;
  bool isBetween(num minimum, num maximum, {bool inclusive = true}) =>
      inclusive
          ? value >= minimum && value <= maximum
          : value > minimum && value < maximum;
  double get asDouble => value.toDouble();
  int get asInt => value.toInt();
}

extension ActiveIntegerHelpers on ActiveType<int> {
  int increment([int amount = 1]) => updateValue((value) => value + amount);
  int decrement([int amount = 1]) => updateValue((value) => value - amount);
  int clampTo(int minimum, int maximum) =>
      updateValue((value) => value.clamp(minimum, maximum));
}

extension ActiveDecimalHelpers on ActiveType<double> {
  double increment([double amount = 1]) =>
      updateValue((value) => value + amount);
  double decrement([double amount = 1]) =>
      updateValue((value) => value - amount);
  double clampTo(double minimum, double maximum) =>
      updateValue((value) => value.clamp(minimum, maximum).toDouble());
}

extension ActiveTextHelpers on ActiveType<String> {
  int? get tryInt => int.tryParse(value.trim());
  double? get tryDouble => double.tryParse(value.trim());
  bool get isBlank => value.trim().isEmpty;
  String trimValue() => updateValue((value) => value.trim());
  String append(String text) => updateValue((value) => '$value$text');
  String prepend(String text) => updateValue((value) => '$text$value');
  String replaceText(String from, String to) =>
      updateValue((value) => value.replaceAll(from, to));
}

extension ActiveNullableHelpers<T> on ActiveType<T?> {
  T valueOr(T fallback) => value ?? fallback;
  T setIfNull(T Function() create) {
    final current = value;
    if (current != null) return current;
    final next = create();
    set(next);
    return next;
  }
}

extension ActiveListHelpers<T> on ActiveList<T> {
  List<T> get snapshotValue => List.unmodifiable(value);
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  bool any(bool Function(T) test) => value.any(test);
  bool every(bool Function(T) test) => value.every(test);
  R fold<R>(R initial, R Function(R, T) combine) =>
      value.fold(initial, combine);
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final groups = <K, List<T>>{};
    for (final item in value) {
      (groups[keyOf(item)] ??= []).add(item);
    }
    return groups;
  }

  void replaceAt(int index, T element) => updateValue((list) {
    list[index] = element;
    return list;
  });
  void removeWhere(bool Function(T) test) => updateValue((list) {
    list.removeWhere(test);
    return list;
  });
  void retainWhere(bool Function(T) test) => updateValue((list) {
    list.retainWhere(test);
    return list;
  });
  void sort([int Function(T, T)? compare]) => updateValue((list) {
    list.sort(compare);
    return list;
  });
  void replaceAll(Iterable<T> items) => set(List.of(items));
  bool addIfAbsent(T item) {
    if (contains(item)) return false;
    add(item);
    return true;
  }
}

extension ActiveMapHelpers<K, V> on ActiveMap<K, V> {
  Map<K, V> get snapshotValue => Map.unmodifiable(value);
  V valueOr(K key, V fallback) =>
      value.containsKey(key) ? value[key] as V : fallback;
  V putIfAbsent(K key, V Function() create) {
    if (containsKey(key)) return value[key] as V;
    final next = create();
    addEntry(MapEntry(key, next));
    return next;
  }

  void setEntry(K key, V next) => addEntry(MapEntry(key, next));
  Map<K2, V2> mapEntries<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      value.map(transform);
}

extension ActiveDateHelpers on ActiveType<DateTime> {
  DateTime addDuration(Duration duration) =>
      updateValue((value) => value.add(duration));
  DateTime subtractDuration(Duration duration) =>
      updateValue((value) => value.subtract(duration));
  DateTime get startOfDay =>
      value.isUtc
          ? DateTime.utc(value.year, value.month, value.day)
          : DateTime(value.year, value.month, value.day);
  bool isSameDay(DateTime other) =>
      value.year == other.year &&
      value.month == other.month &&
      value.day == other.day;
}
