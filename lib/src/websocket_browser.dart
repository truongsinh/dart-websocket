library websocket;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import './websocket_stub.dart' as stub;

class WebSocket implements stub.WebSocket {
  html.WebSocket _socket;

  WebSocket._(this._socket) {
    _socket.onClose.listen((html.CloseEvent event) {
      closeCode = event.code;
      closeReason = event.reason;
      _streamController.close();
    });

    _socket.onError.listen((html.Event error) {
      _streamController.addError(error);
    });
    _socket.onMessage.listen((html.MessageEvent message) async {
      final data = message.data;
      if (data is String) {
        _streamController.add(data);
        return;
      }
      if (data is html.Blob) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(data);
        await reader.onLoad.first;
        _streamController.add(reader.result);
        return;
      }

      throw UnsupportedError('unspported data type $data');
    });
  }

  static Future<WebSocket> connect(
    String url, {
    Iterable<String> protocols,
  }) async {
    final s = html.WebSocket(url, protocols);
    await s.onOpen.first;
    return WebSocket._(s);
  }

  @override
  void add(/*String|List<int>*/ data) {
    if (data is String) {
      return _socket.send(data);
    }
    if (data is List<int>) {
      return _socket.sendByteBuffer(Uint8List.fromList(data).buffer);
    }

    throw UnsupportedError('unspported data type $data');
  }

  @override
  Future addStream(Stream stream) {
    final completer = Completer();
    stream.listen((data) {
      _socket.send(data);
    }, onError: (error) {
      _socket.send(error.toString());
      completer.completeError(error);
    }, onDone: () => completer.complete());
    return completer.future;
  }

  @override
  void addUtf8Text(List<int> bytes) =>
      _socket.send(utf8.decode(bytes));

  @override
  Future close([int code, String reason]) {
    if (code != null) {
      _socket.close(code, reason);
    } else {
      _socket.close();
    }
    return _socket.onClose.first;
  }

  @override
  int closeCode;

  @override
  String closeReason;

  @override
  String get extensions => _socket.extensions;

  @override
  String get protocol => _socket.protocol;

  @override
  int get readyState => _socket.readyState;

  @override
  void addError(Object error, [StackTrace stackTrace]) =>
      _streamController.addError(error, stackTrace);

  @override
  Future get done => _socket.onClose.first;

  StreamController<dynamic /*String|List<int>*/ > _streamController =
      StreamController.broadcast(); //Add .broadcast here

  @override
  Stream<dynamic /*String|List<int>*/ > get stream => _streamController.stream;
}
