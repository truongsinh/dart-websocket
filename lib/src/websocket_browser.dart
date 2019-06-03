library websocket;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import './websocket_stub.dart' as stub;

class WebSocket implements stub.WebSocket {
  html.WebSocket _socket;
  final StreamController _streamConsumer = StreamController();

  WebSocket._(this._socket) : done = _socket.onClose.first {
    _streamConsumer.stream.listen(
      (data) => _send(data),
      onError: (error) => _send(error.toString()),
    );
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

  void _send(/*String|List<int>*/ data) {
    if (data is String) {
      return _socket.send(data);
    }
    if (data is List<int>) {
      return _socket.sendByteBuffer(Uint8List.fromList(data).buffer);
    }

    throw UnsupportedError('unspported data type $data');
  }

  @override
  void add(/*String|List<int>*/ data) => _streamConsumer.add(data);

  @override
  Future addStream(Stream stream) => _streamConsumer.addStream(stream);

  @override
  void addUtf8Text(List<int> bytes) => _streamConsumer.add(utf8.decode(bytes));

  @override
  Future close([int code, String reason]) {
    _streamConsumer.close();
    if (code != null) {
      _socket.close(code, reason);
    } else {
      _socket.close();
    }
    return done;
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
  final Future done;

  StreamController<dynamic /*String|List<int>*/ > _streamController =
      StreamController.broadcast();

  @override
  Stream<dynamic /*String|List<int>*/ > get stream => _streamController.stream;
}
