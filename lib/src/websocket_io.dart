library websocket;

import 'dart:async';
import 'dart:io' as io;
import './websocket_stub.dart' as stub;

class WebSocket implements stub.WebSocket {
  io.WebSocket _socket;

  WebSocket._(this._socket);

  static Future<WebSocket> connect(
    String url, {
    Iterable<String> protocols,
  }) async {
    return WebSocket._(await io.WebSocket.connect(url, protocols: protocols));
  }

  @override
  void add(/*String|List<int>*/ data) => _socket.add(data);

  @override
  Future addStream(Stream stream) => _socket.addStream(stream);

  @override
  void addUtf8Text(List<int> bytes) => _socket.addUtf8Text(bytes);

  @override
  Future close([int code, String reason]) => _socket.close(code, reason);

  @override
  int get closeCode => _socket.closeCode;

  @override
  String get closeReason => _socket.closeReason;

  @override
  String get extensions => _socket.extensions;

  @override
  String get protocol => _socket.protocol;

  @override
  int get readyState => _socket.readyState;

  @override
  Future get done => _socket.done;

  Stream _stream;

  @override
  Stream<dynamic /*String|List<int>*/ > get stream =>
      _stream ??= _socket.asBroadcastStream();
}
