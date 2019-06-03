library websocket;

import 'dart:async';

final _unsupportedError = UnsupportedError(
    'Cannot work with WebSocket without dart:html or dart:io.');

class WebSocket implements StreamConsumer<dynamic /*String|List<int>*/ > {
  static Future<WebSocket> connect(
    String url, {
    Iterable<String> protocols,
  }) async =>
      throw _unsupportedError;

  void add(/*String|List<int>*/ data) => throw _unsupportedError;

  Future addStream(Stream stream) => throw _unsupportedError;

  void addUtf8Text(List<int> bytes) => throw _unsupportedError;

  Future close([int code, String reason]) => throw _unsupportedError;

  int get closeCode => throw _unsupportedError;

  String get closeReason => throw _unsupportedError;

  String get extensions => throw _unsupportedError;

  String get protocol => throw _unsupportedError;

  int get readyState => throw _unsupportedError;

  Future get done => throw _unsupportedError;

  Stream<dynamic /*String|List<int>*/ > get stream => throw _unsupportedError;
}
