import 'dart:async';
import 'package:activity/activity.dart';
import 'package:activity/core/src/state.dart';
import 'package:activity/core/types/active_type.dart';
import 'errors.dart';

/// [ActiveController] is the base class to manage state and events of
/// [ActiveType]s within an [ActiveView].
///
/// It provides lifecycle handling, update notification, error propagation,
/// and activity tracking.
abstract class ActiveController {
  final StreamController<List<ActiveStateChanged>> _stateController =
  StreamController.broadcast();
  final StreamController<ErrorEvent> _errorController =
  StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = [];
  final List<String> _isRunningKeys = [];

  bool _actively = false;
  bool _disposed = false;

  bool get actively => _actively;
  List<String> get activeTasks => _isRunningKeys;

  ActiveController() {
    for (var element in activities) {
      element.setActiveController(this);
    }
  }

  /// List of all [ActiveType] instances managed by this controller.
  Iterable<ActiveType> get activities;

  /// Adds a listener to state changes.
  StreamSubscription addOnStateChangedListener(
      Function(List<ActiveStateChanged> events) onStateChanged,
      ) {
    _checkDisposed();
    final sub = _stateController.stream.listen(onStateChanged);
    _subscriptions.add(sub);
    return sub;
  }

  /// Cancels a specific subscription.
  Future<void> cancelSubscription(StreamSubscription? subscription) async {
    await subscription?.cancel();
    _subscriptions.remove(subscription);
  }

  /// Adds a listener to error events.
  StreamSubscription onActiveErrorListener(
      Function(ErrorEvent event) onError,
      ) {
    _checkDisposed();
    final sub = _errorController.stream.listen(onError);
    _subscriptions.add(sub);
    return sub;
  }

  /// Notifies listeners of state changes.
  void notifyActivities(List<ActiveStateChanged> events) {
    _checkDisposed();
    if (!_stateController.isClosed) {
      _stateController.add(events);
    }
  }

  /// Updates multiple [ActiveType]s with a single notification.
  void activateTypes(List<Map<ActiveType, dynamic>> activeTypeList) {
    _checkDisposed();
    final changes = <ActiveStateChanged>[];

    for (final activeTypeMap in activeTypeList) {
      if (activeTypeMap.length != 1) {
        throw ArgumentError(
            'Each map in activeTypeList must contain exactly one key-value pair.');
      }

      final activeType = activeTypeMap.keys.first;
      final newValue = activeTypeMap.values.first;
      final oldValue = activeType.value;

      changes.add(ActiveStateChanged(
        newValue,
        oldValue,
        typeName: activeType.typeName,
      ));

      activeType(newValue, notifyChange: false);
    }

    notifyActivities(changes);
  }

  /// Emits an error event to listeners.
  void onActiveError(ErrorEvent event) {
    _checkDisposed();
    if (!_errorController.isClosed) {
      _errorController.add(event);
    }
  }

  /// Updates the running state and notifies listeners.
  void setRunningStatus({
    required bool isRunning,
    required String isRunningKey,
  }) {
    _checkDisposed();

    if (isRunning) {
      _addIsRunningKey(isRunningKey);
    } else {
      _removeIsRunningKey(isRunningKey);
    }

    _actively = _isRunningKeys.isNotEmpty;
    notifyActivities([
      ActiveStateChanged(
        isRunning,
        !isRunning,
        typeName: 'State Updated',
      )
    ]);
  }

  /// Marks the controller as currently running a task.
  void setRunning({required String isRunningKey}) {
    setRunningStatus(isRunning: true, isRunningKey: isRunningKey);
  }

  /// Marks the controller as idle (not running the task).
  void setIdle({required String isRunningKey}) {
    setRunningStatus(isRunning: false, isRunningKey: isRunningKey);
  }

  /// Runs an async task and updates running status before and after.
  Future<T> activeAsync<T>(
      Future<T> Function() task, {
        required String isRunningKey,
      }) async {
    _checkDisposed();

    setRunningStatus(isRunning: true, isRunningKey: isRunningKey);
    try {
      return await task();
    } finally {
      setRunningStatus(isRunning: false, isRunningKey: isRunningKey);
    }
  }

  /// Checks if a task is currently running.
  bool isTaskRunning({String? isRunningKey}) {
    _checkDisposed();
    return isRunningKey == null
        ? _isRunningKeys.isNotEmpty
        : _isRunningKeys.contains(isRunningKey);
  }

  void _addIsRunningKey(String isRunningKey) {
    if (!_isRunningKeys.contains(isRunningKey)) {
      _isRunningKeys.add(isRunningKey);
    }
  }

  void _removeIsRunningKey(String isRunningKey) {
    _isRunningKeys.remove(isRunningKey);
  }

  /// Resets all [ActiveType] values to their original state.
  void resetAllActiveTypes() {
    _checkDisposed();
    final resetTypes = <Map<ActiveType, dynamic>>[];

    for (final activity in activities) {
      resetTypes.add({activity: activity.originalValue});
    }

    activateTypes(resetTypes);
  }

  /// Cleans up all resources and closes streams.
  Future<void> resetActivities() async {
    if (_disposed) return;

    for (final sub in _subscriptions) {
      await sub.cancel();
    }

    _subscriptions.clear();

    if (!_stateController.isClosed) {
      await _stateController.close();
    }

    if (!_errorController.isClosed) {
      await _errorController.close();
    }

    _disposed = true;
  }

  /// Throws if the controller has been disposed.
  void _checkDisposed() {
    if (_disposed) {
      throw StateError('This ActiveController has been disposed.');
    }
  }
}
