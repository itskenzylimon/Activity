import 'dart:async';
import 'package:activity/activity.dart';
import 'package:activity/core/types/active_type.dart';

import 'errors.dart';

/// ActiveController
/// [ActiveController] is an abstraction of the [ActiveView] bounded.
/// ActiveController handles current state of active types in [ActiveView].
///
/// Business Logic should exist here and data is easily accessed from the
/// [ActiveView] through the assigned activeController.
///
/// When an update occurs on an active type, the events are automatically
/// emitted, The [ActiveState] bound to the [ActiveController] will update
/// itself everytime an [ActiveType] value is updated and initiate a build.

abstract class ActiveController {
  final StreamController<List<ActiveStateChanged>> _stateController =
      StreamController.broadcast();
  final StreamController<ErrorEvent> _errorController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = [];

  bool _actively = false;

  bool get actively => _actively;

  final List<dynamic> _isRunningKeys = [];

  List<dynamic> get activeTasks => _isRunningKeys;

  ActiveController() {
    for (var element in activities) {
      element.setActiveController(this);
    }
  }

  ///Contains list of [ActiveType] values in [ActiveController].
  ///
  ///Every [ActiveType] are added here to allow automatic rebuild.

  Iterable<ActiveType> get activities;

  ///Event handler for [ActiveType] when values get updated
  ///
  ///If a listener references a [BuildContext] inside a [Widget], override the
  /// [Widget] dispose method and cancel the subscription.

  StreamSubscription addOnStateChangedListener(
      Function(List<ActiveStateChanged> events) onStateChanged) {
    final newSubscription = _stateController.stream.listen(onStateChanged);
    _subscriptions.add(newSubscription);
    return newSubscription;
  }

  ///Cancels events subscription.
  Future<void> cancelSubscription(StreamSubscription? subscription) async {
    await subscription?.cancel();
    _subscriptions.remove(subscription);
  }

  ///Event handler when there is a [onActiveError].
  StreamSubscription onActiveErrorListener(Function(ErrorEvent event) onError) {
    final newSubscription = _errorController.stream.listen(onError);
    _subscriptions.add(newSubscription);
    return newSubscription;
  }

  ///Initiates [ActiveState] when UI needs updating.
  ///
  /// This process is handled by the package when an [ActiveType] is updated,
  /// and is not really required to be called when updating [ActiveType].

  void notifyActivities(List<ActiveStateChanged> events) {
    if (_stateController.isClosed) {
      return;
    }
    _stateController.add(events);
  }

  /// [activateTypes] allows multiple [ActiveType] to be updated at once and it
  /// will only trigger a single state change.
  ///
  /// [activeTypeList] is a [List<Map<ActiveType, dynamic>>], where keys are the
  /// properties you want to set, and the values are the new changes. Each map
  /// in the list must contain exactly one key/value pair.
  ///
  ///## Example
  ///
  ///```dart
  ///late final ActiveType<String> taskName;
  ///late final ActiveType<int> taskScore;
  ///
  ///activateTypes([
  ///   {taskName: 'Write Test Cases'},
  ///   {taskScore: 5.5},
  ///]);
  ///```

  void activateTypes(List<Map<ActiveType, dynamic>> activeTypeList) {
    final List<ActiveStateChanged> changes = [];
    for (var activeTypeMap in activeTypeList) {
      assert(activeTypeMap.keys.length == 1,
          'activeTypeMap item should contain one key/value pair.');
      final activeType = activeTypeMap.keys.first;

      final oldValue = activeType.value;
      final newValue = activeTypeMap.values.first;

      changes.add(ActiveStateChanged(newValue, oldValue,
          typeName: activeType.typeName));

      activeType(newValue, notifyChange: false);
    }
    notifyActivities(changes);
  }

  ///Alerts [ActiveState] that an error has occurred. all listeners registered
  /// by the[onActiveErrorListener] function will be executed

  void onActiveError(ErrorEvent event) {
    if (_errorController.isClosed) {
      return;
    }
    _errorController.add(event);
  }

  /// Updates the current [ActiveController] status.
  ///
  /// You can use this in [ActiveState] by calling [ActiveState.ifRunning] function
  /// to show maybe a loading indicator.
  ///
  /// You can also access the current state using [actively] value
  /// in [ActiveController].
  ///
  /// [isRunning] is a bool value rep Activity running status
  /// [isRunningKey] is a String value rep Activity running key, this value
  /// could be used to find the active [ActiveController].
  ///
  /// [activeAsync] functions automatically updates [actively] value.

  void setRunningStatus(
      {required bool isRunning, required String isRunningKey}) {
    if (isRunning) {
      _addIsRunningKey(isRunningKey);
      _actively = _isRunningKeys.isNotEmpty || isRunning;
      notifyActivities([ActiveStateChanged(isRunning, !isRunning, typeName: 'State Updated')]);
    } else {
      _removeIsRunningKey(isRunningKey);
    }
  }

  /// Updates the current [ActiveController] status to true.
  /// You can specify the [ActiveController] by passing the [isRunningKey]

  /// Updates the current [ActiveController] status to true.
  ///
  /// You can use this in [ActiveState] by calling [ActiveState.ifRunning] function
  /// to show maybe a loading indicator.
  ///
  /// You can also access the current state using [actively] value
  /// in [ActiveController].
  ///
  /// [isRunningKey] is a String value rep Activity running status, this value
  /// could be used to find the active [ActiveController].
  ///
  /// [activeAsync] functions automatically updates [actively] value.

  void setRunning({required String isRunningKey}) {
    setRunningStatus(isRunning: true, isRunningKey: isRunningKey);
  }

  /// Updates the current [ActiveController] status to false.
  /// You can specify the [ActiveController] by passing the [isRunningKey]

  /// Updates the current [ActiveController] status to true.
  ///
  /// You can use this in [ActiveState] by calling [ActiveState.ifRunning] function
  /// to show maybe a loading indicator.
  ///
  /// You can also access the current state using [actively] value
  /// in [ActiveController].
  ///
  /// [isRunningKey] is a String value rep Activity running status, this value
  /// could be used to find the active [ActiveController].
  ///
  /// [activeAsync] functions automatically updates [actively] value.

  void setIdle({dynamic isRunningKey}) {
    setRunningStatus(isRunning: false, isRunningKey: isRunningKey);
  }

  /// Use this function when you have a long running task asynchronously. it
  /// handles setting [actively] status from true to false once done.
  ///
  /// [isRunningKey] is a String value rep Activity running status, this value
  /// could be used to find the active [ActiveController].
  ///
  ///Example:
  ///```dart
  ///Future<void> loadTasks() async {
  ///    final tasks = await activeAsync<Tasks>(
  ///      () async => await taskService.getAllActiveTasks(),
  ///      isRunningKey: 'loadTasks'
  ///    );
  ///}
  ///```

  Future<T> activeAsync<T>(Future<T> Function() task,
      {dynamic isRunningKey}) async {
    setRunningStatus(isRunning: true, isRunningKey: isRunningKey);
    try {
      final doTask = await task();
      return doTask;
    } finally {
      setRunningStatus(isRunning: false, isRunningKey: isRunningKey);
    }
  }

  /// Use this when you intend to check if [actively] is true
  ///
  /// Pass the [isRunningKey] if you intend to specify the [ActiveController].

  bool isTaskRunning({String? isRunningKey}) {
    if(isRunningKey == null){
      return _isRunningKeys.isNotEmpty;
    }
   return _isRunningKeys.contains(isRunningKey);
  }

  /// Use this when you intend to attach [isRunningKey] to a running [ActiveController].

  void _addIsRunningKey(String isRunningKey) {
    if (!_isRunningKeys.contains(isRunningKey)) {
      _isRunningKeys.add(isRunningKey);
    }
  }

  /// Use this when you intend to detach [isRunningKey] to a running [ActiveController].

  void _removeIsRunningKey(String isRunningKey) {
    if (_isRunningKeys.contains(isRunningKey)) {
      _isRunningKeys.remove(isRunningKey);
    }
  }

  /// Factory reset.
  /// This resets every activeType property defined in [activities] list

  void resetAllActiveTypes() {
    final resetTypes = <Map<ActiveType, dynamic>>[];
    for (final activity in activities) {
      resetTypes.add({activity: activity.originalValue});
    }
    activateTypes(resetTypes);
  }

  /// Use this when you want to clear current state & event listeners
  /// that are connected and are active.

  void resetActivities() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _errorController.close();
    _stateController.close();
  }
}

/// Stream Events connected to the State
/// You can use [ActiveController.addOnStateChangedListener] to get notified of
/// these events

class ActiveStateChanged<T> {
  final T? oldValue;
  final T? newValue;
  final String? typeName;
  final String? info;

  ActiveStateChanged(this.newValue, this.oldValue, {this.typeName, this.info});

  /// [addActiveList]
  /// Method that describes [ActiveStateChanged] of type [ActiveList] when a
  /// new value is added to a list

  static ActiveStateChanged addActiveList<V>(V newValue, {String? typeName}) =>
      ActiveStateChanged(newValue, null,
          typeName: typeName, info: 'A new value added : $newValue');

  /// [addAllActiveList]
  /// Method that describes [ActiveStateChanged] of type [ActiveList] when
  /// new values is added to a list

  static ActiveStateChanged addAllActiveList<V>(Iterable<V> newValues,
          {String? typeName}) =>
      ActiveStateChanged(newValues, null,
          typeName: typeName, info: 'List values added : $newValues');

  /// [removeActiveList]
  /// Method that describes [ActiveStateChanged] of type [ActiveList] when a
  /// values is removed from a list

  static ActiveStateChanged removeActiveList<V>(V removedValue,
          {String? typeName}) =>
      ActiveStateChanged(null, removedValue,
          typeName: typeName, info: 'Value removed : $removedValue');

  /// [clearActiveList]
  /// Method that describes [ActiveStateChanged] of type [ActiveList] when you
  /// want to clear every value in a list
  static ActiveStateChanged<Iterable<V>> clearActiveList<V>(
          Iterable<V> iterable,
          {String? typeName}) =>
      ActiveStateChanged(<V>[], iterable,
          typeName: typeName, info: 'List cleared');

  ///A factory method which creates a single [ActiveStateChanged] object with a description
  ///describing the value inserted into to the list at the specified index
  static ActiveStateChanged insertIntoList<V>(int index, V value,
          {String? typeName}) =>
      ActiveStateChanged(
        value,
        null,
        typeName: typeName,
        info: 'Inserted $value into List as index $index',
      );

  ///A factory method which creates a single [ActiveStateChanged] object with a description
  ///describing all the values that were inserted into the list at the specified index
  static ActiveStateChanged insertAllIntoList<V>(int index, Iterable<V> values,
          {String? typeName}) =>
      ActiveStateChanged(values, null,
          typeName: typeName,
          info: 'Inserted All $values into List as index $index');

  ///A factory method which creates a single [ActiveStateChanged] object with a description
  ///describing what value was removed from the list
  static ActiveStateChanged removedFromList<V>(V removedValue,
          {String? typeName}) =>
      ActiveStateChanged(null, removedValue,
          typeName: typeName, info: 'Removed From List: $removedValue');

  /// [addActiveMap]
  /// Method that describes [ActiveStateChanged] of type [ActiveMap] when you
  ///describing what new map values were added to another map

  static ActiveStateChanged addActiveMap<K, V>(Map<K, V> addedMap,
      {String? typeName}) {
    return ActiveStateChanged(addedMap, null,
        typeName: typeName, info: 'Added Map To Map : $addedMap');
  }

  /// [entryActiveMap]
  /// Method that describes [ActiveStateChanged] of type [ActiveMap] when you
  /// add a new entry key/value is added to the map

  static ActiveStateChanged entryActiveMap<K, V>(K key, V newValue,
      {String? typeName}) {
    final mapEntry = MapEntry(key, newValue);
    return ActiveStateChanged(mapEntry, null,
        typeName: typeName, info: 'Added Entry To Map : $mapEntry');
  }

  /// [entriesActiveMap]
  /// Method that describes [ActiveStateChanged] of type [ActiveMap] when you
  /// add entry objects to the map

  static ActiveStateChanged entriesActiveMap<K, V>(
      Iterable<MapEntry<K, V>> mapEntries,
      {String? typeName}) {
    return ActiveStateChanged(mapEntries, null,
        typeName: typeName, info: 'Added Entries To Map: $mapEntries');
  }

  /// [updateActiveMap]
  /// Method that describes [ActiveStateChanged] of type [ActiveMap] when you
  /// update a key value

  static ActiveStateChanged<V> updateActiveMap<K, V>(
      K key, V? oldValue, V? newValue,
      {String? typeName}) {
    return ActiveStateChanged<V>(newValue, oldValue,
        typeName: typeName, info: 'Map $key key value updated to : $key');
  }

  /// [removedActiveMap]
  /// Method that describes [ActiveStateChanged] of type [ActiveMap] when you
  /// remove an entry from map

  static ActiveStateChanged<V> removedActiveMap<K, V>(K key, V newValue,
      {String? typeName}) {
    final mapEntry = MapEntry(key, newValue);
    return ActiveStateChanged<V>(null, newValue,
        typeName: typeName, info: 'Removed From Map: $mapEntry');
  }

  @override
  String toString() {
    return 'Old value : $oldValue, New value : $newValue, Type name : $typeName, Type info : $info';
  }
}

extension ActiveStateChangedExtensions<T> on List<ActiveStateChanged<T>> {
  ///Whether the typeName on any event matches the [typeName] argument
  bool containsPropertyName(String typeName) {
    return map((x) => x.typeName).contains(typeName);
  }

  ///Gets the first event where the [ActiveStateChanged.typeName] matches the
  ///[typeName] argument
  ///
  ///Returns null if no event is found
  ActiveStateChanged<T>? firstForPropertyName(String typeName) {
    final events = where((e) => e.typeName == typeName);

    return events.isNotEmpty ? events.first : null;
  }

  ///Gets the [ActiveStateChanged.newValue] for the first event where the
  ///[ActiveStateChanged.typeName]
  ///matches the [typeName] argument
  T? newValueFor(String typeName) {
    return firstForPropertyName(typeName)?.newValue;
  }

  ///Gets the [ActiveStateChanged.oldValue] for the first event where the
  ///[ActiveStateChanged.typeName]
  ///matches the [typeName] argument
  T? oldValueFor(String typeName) {
    return firstForPropertyName(typeName)?.oldValue;
  }
}
