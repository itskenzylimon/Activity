import 'dart:typed_data';

export 'package:activity/core/networks/sockets/web.dart'
if (dart.library.io) 'package:activity/core/networks/sockets/io.dart';

typedef OnSuccess = void Function();
typedef OnFailure = void Function();
typedef OnClose = void Function();
typedef OnMessage = void Function(dynamic data);


enum WebSocketState {
  isConnecting,
  isOpen,
  isClosing,
  isClosed,
}

enum WebOpenStatus {
  pending,
  success,
  failed,
}

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
