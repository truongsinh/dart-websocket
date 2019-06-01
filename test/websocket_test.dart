import 'package:test/test.dart';

import 'package:websocket/websocket.dart' show WebSocket;

void main() {
  final url = 'ws://localhost:8080';
  group('#connect', () {
    test('open connection', () async {
      final socket = await WebSocket.connect(url);
      expect(socket.readyState, 1);
      socket.close();
    });
    test('open connection with protocol', () async {
      final socket =
          await WebSocket.connect(url, protocols: ['weird-protocol']);
      expect(socket.readyState, 1);
      socket.close();
    }, skip: true);
    test('error connection', () {}, skip: true);
  });

  group('instance method', () {
    WebSocket socket;
    setUp(() async {
      socket = await WebSocket.connect(url);
    });
    tearDown(() {
      socket?.close();
    });
    group('#add', () {
      test('String ASCII', () async {
        socket.add('string data');
        await expectLater(socket.stream, emits('string data'));
      });
      test('String Unicode/Emoji', () async {
        socket.add('string 👨‍👩‍👧‍👦');
        await expectLater(socket.stream, emits('string 👨‍👩‍👧‍👦'));
      });
      test('Bytes', () async {
        socket.add(<int>[0, 1, 195, 191]);
        // await expectLater(socket.stream, emits(<int>[0, 1, 195, 191]));
        expect(await socket.stream.first, <int>[0, 1, 195, 191]);
      });
    });

    group('#addUtf8Text', () {
      test('text', () async {
        socket.addUtf8Text(<int>[00, 1, 195, 191]);
        // await expectLater(socket.stream, emits('\u{0}\u{1}\u{FF}'));
        expect(await socket.stream.first, '\u{0}\u{1}\u{FF}');
      });
    });
  });
}
