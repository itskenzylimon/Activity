import 'dart:async';

/// A lightweight, type-safe event bus.
///
/// Supports:
/// - Broadcast streams
/// - Type-filtered listeners
/// - Sticky events (last emitted value replayed to new listeners)
/// - Clean lifecycle management
class Deamon {
  Deamon({bool sync = false})
      : _controller = StreamController<Object?>.broadcast(sync: sync);

  Deamon.withController(StreamController<Object?> controller)
      : _controller = controller;

  final StreamController<Object?> _controller;

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
    final baseStream = on<T>();

    if (_lastByType.containsKey(T)) {
      final T cached = _lastByType[T] as T;

      final merged = (() async* {
        yield cached;
        yield* baseStream;
      })();

      return merged.asBroadcastStream();
    }

    return baseStream;
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
  Future<void> close() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
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
