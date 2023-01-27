library active_websocket;
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:activity/activity.dart';

class WebSocket implements ActiveSocket {
  io.WebSocket? _socket;

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
    _open(url);
  }

  _open(String url) async {
    close();

    try {
      _socket = await io.WebSocket.connect(url);

      if (_socket!.readyState == io.WebSocket.open) {
        if (_onSuccess != null) {
          _onSuccess!();
        }
      }

      _socket!.listen((event) {
        if (_onMessage != null) {
          _onMessage!(event);
        }
      }, onDone: () {
        if (_onClose != null) {
          _onClose!();
        }
        _socket = null;
      });
    } catch (e) {
      if (_onFailure != null) {
        _onFailure!();
      }
      _socket = null;
    }
  }

  @override
  close() {
    _socket?.close();
    _socket = null;
  }

  @override
  send(String data) {
    _socket?.add(data);
  }

  @override
  sendUint8List(Uint8List data) {
    _socket?.addUtf8Text(data.toList());
  }

  @override
  WebSocketState state() {
    return WebSocketState.values[_socket?.readyState ?? 3];
  }
}
