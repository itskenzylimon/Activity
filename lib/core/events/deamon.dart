import 'dart:async';

/// A typed, isolate-local broadcast event bus with per-subscriber sticky replay.
///
/// Keep each StreamSubscription and cancel it when its owner leaves. Buses do not bridge isolates, browser tabs or platform processes; sticky cache keys use the emission generic type.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#events) · browser route `/#/events`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Await one event
///
/// <!-- activity-snippet: class-deamon-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// Future<void> main() async {
///   final bus = Deamon();
///   try {
///     final next = bus.next<String>(); // Subscribe before emitting.
///     bus.emit('ready');
///     assert(await next == 'ready');
///   } finally {
///     await bus.close();
///   }
/// }
/// ```
///
/// ### Replay the latest typed value
///
/// <!-- activity-snippet: class-deamon-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// Future<void> main() async {
///   final bus = Deamon();
///   try {
///     bus.emitSticky<int>(3);
///     assert(await bus.onSticky<int>().first == 3);
///     bus.clearSticky<int>();
///   } finally {
///     await bus.close();
///   }
/// }
/// ```
class Deamon {
  Deamon({bool sync = false})
    : _controller = StreamController<Object?>.broadcast(sync: sync);

  Deamon.withController(StreamController<Object?> controller)
    : _controller = controller {
    if (!controller.stream.isBroadcast) {
      throw ArgumentError('A broadcast controller is required');
    }
  }

  final StreamController<Object?> _controller;

  Future<void>? _closeFuture;

  final Map<Type, Object?> _lastByType = <Type, Object?>{};

  /// The stream of all events (raw).
  Stream<Object?> get stream => _controller.stream;

  /// Whether the stream is closed.
  bool get isClosed => _controller.isClosed;

  /// Whether any listeners are attached.
  bool get hasListener => _controller.hasListener;

  /// Emits a new event.
  void emit(Object? event) {
    _ensureOpen();
    _controller.add(event);
  }

  /// Emits an error event.
  void emitError(Object error, [StackTrace? stackTrace]) {
    _ensureOpen();
    _controller.addError(error, stackTrace);
  }

  /// Emits a sticky event (cached by type).
  void emitSticky<T extends Object?>(T event) {
    _ensureOpen();
    _lastByType[T] = event;
    emit(event);
  }

  /// Clears sticky events of type [T], or all if [T] is Object/dynamic.
  void clearSticky<T extends Object?>() {
    if (identical(T, Object) || identical(T, dynamic)) {
      _lastByType.clear();
    } else {
      _lastByType.remove(T);
    }
  }

  /// Subscribes to events of type [T].
  Stream<T> on<T extends Object?>() {
    if (identical(T, Object) || identical(T, dynamic)) {
      return stream as Stream<T>;
    }
    return stream.where((e) => e is T).cast<T>();
  }

  /// Subscribes to sticky + future events of type [T].
  Stream<T> onSticky<T extends Object?>() {
    return Stream<T>.multi((sink) {
      final subscription = on<T>().listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );
      // Capture the cache at listen time and buffer before invoking user callbacks.
      if (_lastByType.containsKey(T)) sink.add(_lastByType[T] as T);
      sink.onCancel = subscription.cancel;
      sink.onPause = subscription.pause;
      sink.onResume = subscription.resume;
    }, isBroadcast: true);
  }

  /// Returns the next event of type [T].
  Future<T> next<T extends Object?>() => on<T>().first;

  /// Subscribes to events immediately.
  StreamSubscription<T> listen<T extends Object?>(
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return on<T>().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Closes the event bus.
  Future<void> close() {
    _lastByType.clear();
    return _closeFuture ??= _controller.close();
  }

  /// Internal safety check.
  void _ensureOpen() {
    if (_controller.isClosed) {
      throw StateError('Deamon is closed');
    }
  }

  // ----------- Deprecated Backward-Compatible Aliases -----------

  @Deprecated('Use emit instead.')
  void spawn(Object? event) => emit(event);

  @Deprecated('Use close() instead.')
  void destroy() {
    unawaited(close());
  }

  @Deprecated('Use stream instead.')
  StreamController<Object?> get streamController => _controller;
}
