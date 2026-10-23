import 'dart:async';
import 'package:activity/activity.dart';
import 'errors.dart';

/// An application or feature owner for state, subscriptions and asynchronous work.
///
/// Disposal is terminal and idempotent. activeAsync tracks work; it does not cancel I/O. Check isDisposed after awaits before applying results; use generation tokens for stale responses (see the recipes gallery).
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#async) · browser route `/#/async`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Track an asynchronous operation
///
/// <!-- activity-snippet: abstract-class-activecontroller-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveString('idle');
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     await controller.activeAsync(() async {
///       assert(controller.isTaskRunning(isRunningKey: 'load'));
///       controller.value('ready');
///     }, isRunningKey: 'load');
///     assert(!controller.actively);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Recover without discarding state
///
/// <!-- activity-snippet: abstract-class-activecontroller-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveString('draft');
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     try {
///       await controller.activeAsync<void>(
///         () async => throw StateError('offline'),
///         isRunningKey: 'save',
///       );
///     } on StateError {
///       assert(controller.value.value == 'draft'); // Retain the draft for retry.
///     }
///     assert(!controller.actively);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
abstract class ActiveController {
  final StreamController<List<ActiveStateChanged>> _stateController =
      StreamController.broadcast();
  final StreamController<ErrorEvent> _errorController =
      StreamController.broadcast();

  final List<StreamSubscription> _subscriptions = [];
  final Map<String, int> _runningCounts = {};
  Future<void>? _disposeFuture;
  bool get isDisposed => _disposed;

  bool _actively = false;
  bool _disposed = false;

  bool get actively => _actively;
  List<String> get activeTasks => List.unmodifiable(_runningCounts.keys);

  ActiveController() {
    for (var element in activities) {
      element.setActiveController(this);
    }
  }

  /// List of all [ActiveType] instances managed by this controller.
  Iterable<ActiveType> get activities;

  /// Adds a listener to state changes.
  StreamSubscription<List<ActiveStateChanged>> addOnStateChangedListener(
    void Function(List<ActiveStateChanged> events) onStateChanged,
  ) {
    _checkDisposed();
    final sub = _stateController.stream.listen(onStateChanged);
    _subscriptions.add(sub);
    return sub;
  }

  /// Cancels a specific subscription.
  Future<void> cancelSubscription(StreamSubscription? subscription) async {
    _subscriptions.remove(subscription);
    await subscription?.cancel();
  }

  /// Adds a listener to error events.
  StreamSubscription<ErrorEvent> onActiveErrorListener(
    void Function(ErrorEvent event) onError,
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
      _stateController.add(List.unmodifiable(events));
    }
  }

  /// Updates multiple [ActiveType]s with a single notification.
  void activateTypes(List<Map<ActiveType, dynamic>> activeTypeList) {
    _checkDisposed();
    final changes = <ActiveStateChanged>[];

    for (final entry in activeTypeList) {
      if (entry.length != 1 || !entry.keys.first.accepts(entry.values.first)) {
        throw ArgumentError(
          "Each update must contain one correctly typed value.",
        );
      }
      entry.keys.first.ensureCanMutate();
    }
    for (final activeTypeMap in activeTypeList) {
      if (activeTypeMap.length != 1) {
        throw ArgumentError(
          'Each map in activeTypeList must contain exactly one key-value pair.',
        );
      }

      final activeType = activeTypeMap.keys.first;
      final newValue = activeTypeMap.values.first;
      final oldValue = activeType.eventSnapshot(activeType.value);

      changes.add(
        ActiveStateChanged(
          activeType.eventSnapshot(newValue),
          oldValue,
          typeName: activeType.typeName,
        ),
      );

      activeType(newValue, notifyChange: false);
    }

    if (changes.isNotEmpty) notifyActivities(changes);
  }

  /// Commits typed assignments with one notification.
  void activate(Iterable<ActiveUpdate> updates) {
    _checkDisposed();
    final pending = updates.toList();
    for (final update in pending) {
      update.target.ensureCanMutate();
      if (!update.target.accepts(update.next)) {
        throw ArgumentError('Update value does not match its target type');
      }
    }
    final events = [for (final update in pending) update.commit()];
    if (events.isNotEmpty) notifyActivities(events);
  }

  /// Register a value created after controller construction.
  void register(ActiveType value) {
    _checkDisposed();
    value.setActiveController(this);
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

    if (!isRunning && !_runningCounts.containsKey(isRunningKey)) return;
    final wasRunning = _actively;
    if (isRunning) {
      _addIsRunningKey(isRunningKey);
    } else {
      _removeIsRunningKey(isRunningKey);
    }

    _actively = _runningCounts.isNotEmpty;
    notifyActivities([
      ActiveStateChanged(_actively, wasRunning, typeName: 'State Updated'),
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
      if (!_disposed) {
        setRunningStatus(isRunning: false, isRunningKey: isRunningKey);
      }
    }
  }

  /// Checks if a task is currently running.
  bool isTaskRunning({String? isRunningKey}) {
    _checkDisposed();
    return isRunningKey == null
        ? _runningCounts.isNotEmpty
        : _runningCounts.containsKey(isRunningKey);
  }

  void _addIsRunningKey(String isRunningKey) {
    _runningCounts.update(
      isRunningKey,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  void _removeIsRunningKey(String isRunningKey) {
    final count = _runningCounts[isRunningKey] ?? 0;
    if (count <= 1) {
      _runningCounts.remove(isRunningKey);
    } else {
      _runningCounts[isRunningKey] = count - 1;
    }
  }

  /// Resets all [ActiveType] values to their original state.
  void resetAllActiveTypes() {
    _checkDisposed();
    final resetTypes = <Map<ActiveType, dynamic>>[];

    for (final activity in activities) {
      resetTypes.add({activity: activity.snapshot(activity.originalValue)});
    }

    activateTypes(resetTypes);
  }

  /// Cleans up all resources and closes streams.
  Future<void> resetActivities() => dispose();

  /// Terminal, idempotent cleanup. Pending tasks retain their result/error.
  Future<void> dispose() {
    if (_disposeFuture != null) return _disposeFuture!;
    _disposed = true;
    _runningCounts.clear();
    _actively = false;
    return _disposeFuture = _disposeResources();
  }

  Future<void> _disposeResources() async {
    _disposed = true;

    for (final sub in List.of(_subscriptions)) {
      await sub.cancel();
    }

    _subscriptions.clear();
    _runningCounts.clear();
    _actively = false;

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
