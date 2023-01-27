library active_websocket;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:activity/core/networks/active_socket.dart';

class WebSocket implements ActiveSocket {
  html.WebSocket? _socket;

  OnSuccess? _onSuccess;
  OnFailure? _onFailure;
  OnClose? _onClose;
  OnMessage? _onMessage;

  @override
  onSuccess(OnSuccess callback) {
    _onSuccess = callback;
  }

  @override
  onFailure(OnFailure callback) {
    _onFailure = callback;
  }

  @override
  onClose(OnClose callback) {
    _onClose = callback;
  }

  @override
  onMessage(OnMessage callback) {
    _onMessage = callback;
  }

  @override
  open(String url) {

    var openStatus = WebOpenStatus.pending;

    close();
    _socket = html.WebSocket(url);
    _socket!.binaryType = "arraybuffer";

    _socket!.onOpen.first.then((value) {
      openStatus = WebOpenStatus.success;
      if (_onSuccess != null) {
        _onSuccess!();
      }
    });

    _socket!.onError.first.then((value) {
      openStatus = WebOpenStatus.failed;
      if (_onFailure != null) {
        _onFailure!();
      }
      _socket = null;
    });

    _socket!.onClose.first.then((value) {
      if (_onClose != null && openStatus != WebOpenStatus.failed) {
        _onClose!();
      }
      _socket = null;
    });

    _socket!.onMessage.listen((event) {
      if (_onMessage != null) {
        if (event.data is ByteBuffer) {
          var buf = event.data as ByteBuffer;
          _onMessage!(buf.asUint8List());
        } else {
          _onMessage!(event.data);
        }
      }
    });
  }

  @override
  close() {
    _socket?.close();
    _socket = null;
  }

  @override
  send(String data) {
    _socket?.sendString(data);
  }

  @override
  sendUint8List(Uint8List data) {
    _socket?.sendByteBuffer(data.buffer);
  }

  @override
  WebSocketState state() {
    return WebSocketState.values[_socket?.readyState ?? 3];
  }
}
