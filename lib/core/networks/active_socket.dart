import 'dart:typed_data';

export 'package:activity/core/networks/sockets/web.dart'
if (dart.library.io) 'package:activity/core/networks/sockets/io.dart';

/// [OnSuccess] callback when a connection is established
typedef OnSuccess = void Function();

/// [OnFailure] callback when a connection has failed to established
typedef OnFailure = void Function();

/// [OnClose] callback when a connection is closed
typedef OnClose = void Function();

/// [OnMessage] callback when a connection has received data, [data] is the data
/// received from the websocket of type [dynamic]
typedef OnMessage = void Function(dynamic data);


/// [WebSocketState] enum to represent the state of the websocket
/// [isConnecting] when the websocket is connecting
/// [isOpen] when the websocket is open
/// [isClosing] when the websocket is closing
/// [isClosed] when the websocket is closed
enum WebSocketState {
  isConnecting,
  isOpen,
  isClosing,
  isClosed,
}

/// [WebOpenStatus] enum to represent the state of the websocket
/// [pending] when the websocket is connecting
/// [success] when the websocket is open
/// [failed] when the websocket is closing
enum WebOpenStatus {
  pending,
  success,
  failed,
}

/// [ActiveSocket] abstract class to represent the websocket
abstract class ActiveSocket {
  /// Called when a connection is established
  onSuccess(OnSuccess callback);

  /// Called when a connection has failed
  onFailure(OnFailure callback);

  /// Called when a connection is closed
  onClose(OnClose callback);

  /// Called when websocket sends data
  onMessage(OnMessage callback);

  /// Call this when you want to established a connection
  open(String url);

  /// Called when you want to close a connection
  close();

  /// Called when you want to send data to [websocket]
  /// A [string] data in expected
  send(String data);

  /// Called when you want to send Uint8List to websocket
  /// A Uint8List data in expect
  sendUint8List(Uint8List data);

  /// Get the current state of the websocket
  WebSocketState state();
}
