import 'dart:async';

/// Using Dart [Stream]s, this thingy lets you send events to whoever cares.
/// The [Deamon] is awesome for making apps that don't depend on each other.
/// It means you don't have to bother with defining and tracking listeners.
///
/// But don't go crazy and use the [Deamon] for everything.
/// Only use it for events that matter to a lot of folks.
///
/// Events are just plain old Dart objects. You can pick the ones you like by their class.

class Deamon {
  final StreamController _streamController;

  /// Controller for the Deamon stream.
  StreamController get streamController => _streamController;

  /// Creates an [Deamon].
  ///
  /// If [sync] is true, events are passed directly to the stream's listeners
  /// during a [fire] call. If false (the default), the event will be passed to
  /// the listeners at a later time, after the code creating the event has
  /// completed.
  Deamon({bool sync = false})
      : _streamController = StreamController.broadcast(sync: sync);

  /// Instead of using the default [StreamController] you can use this constructor
  /// to pass your own controller.
  ///
  Deamon.dynamicController(StreamController controller)
      : _streamController = controller;

  /// Listens for events of Type [T] and its subtypes.
  ///
  /// The method is called like this: myDeamon.on<MyType>();
  ///
  /// If the method is called without a type parameter, the [Stream] contains every
  /// event of this [Deamon].
  ///
  /// The returned [Stream] is a broadcast stream so multiple subscriptions are
  /// allowed.
  ///
  /// Each listener is handled independently, and if they pause, only the pausing
  /// listener is affected.
  ///
  /// A paused listener will buffer events internally until
  /// its tired or canceled. So it's usually better to just cancel and later
  /// subscribe again (avoids memory leak).
  ///
  Stream<T> on<T>() {
    if (T == dynamic) {
      return streamController.stream as Stream<T>;
    } else {
      return streamController.stream.where((event) => event is T).cast<T>();
    }
  }

  /// Spawns a new event on the [Deamon] with the specified [event].
  ///
  void spawn(event) {
    streamController.add(event);
  }

  /// Destroy this [Deamon]. This is generally only in a testing context.
  ///
  void destroy() {
    _streamController.close();
  }
}