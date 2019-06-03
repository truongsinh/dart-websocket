import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';

import 'package:websocket/websocket.dart' show WebSocket;

void main() {
  final url = 'ws://localhost:5600';
  group('#connect', () {
    test('open connection', () async {
      final socket = await WebSocket.connect(url);
      expect(socket.readyState, 1);
      await socket.close();
      await socket.done;
    });
    test('close connection from client side', () async {
      final socket = await WebSocket.connect(url);
      expect(socket.readyState, 1);
      await expectLater(socket.stream, emitsInOrder([]));
      socket.close(3001, 'reason 3001');
      await expectLater(socket.stream, emitsDone);
      expect(socket.closeCode, 3001);
      expect(socket.closeReason, 'reason 3001');
      await socket.done;
    });
    test('close connection from server side', () async {
      final socket = await WebSocket.connect(url);
      expect(socket.readyState, 1);
      await socket.add(jsonEncode({
        'command': 'close',
        'code': 3002,
        'reason': 'reason 3002',
      }));
      await expectLater(socket.stream, emitsDone);
      expect(socket.closeCode, 3002);
      expect(socket.closeReason, 'reason 3002');
      await socket.done;
    });
    test('open connection with protocol', () async {
      final socket = await WebSocket.connect(url,
          protocols: ['weird-protocol', 'another-protocol']);
      expect(socket.readyState, 1);
      expect(socket.protocol, 'weird-protocol');
      if (socket.extensions is String) {
        // in browser
        expect(
            socket.extensions, 'permessage-deflate; client_max_window_bits=15');
      } else {
        expect(socket.extensions, null);
      }
      socket.close();
      await socket.done;
    });
    // test('error connection', () {}, skip: true);
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

    group('#addStream', () {
      StreamController stream1;
      StreamController stream2;
      setUp(() {
        stream1 = StreamController();
        stream2 = StreamController();
      });
      tearDown(() {
        stream1.close();
        stream2.close();
        // otherwise socket?.close(); in other teadDown will throw error
        // Bad state: StreamSink is already bound to a stream
        socket = null;
      });
      test('single-subscription stream', () async {
        stream1
          ..stream.pipe(socket)
          ..add('frame1')
          ..add('frame3');

        await expectLater(
            socket.stream,
            emitsInOrder([
              'frame1',
              'frame3',
            ]));
      });
      test('multiple streams throw error', () async {
        stream1.stream.pipe(socket);
        await expect(() => stream2.stream.pipe(socket), throwsA(isStateError));
      });
      test('cannot send more data after addStream', () async {
        stream1.stream.pipe(socket);
        await expect(() => socket.add('a'), throwsA(isStateError));
        await expect(() => socket.addUtf8Text([0, 1]), throwsA(isStateError));
        await expect(() => socket.close(), throwsA(isStateError));
      });
      test('broadcast stream', () async {
        stream1
          ..stream.pipe(socket)
          ..add('frame1')
          ..add('frame3');

        await expectLater(
            socket.stream,
            emitsInOrder([
              'frame1',
              'frame3',
            ]));
      });
      test('multiple broadcast streams throw error', () async {
        final stream1 = StreamController.broadcast();
        stream1.stream.pipe(socket);
        final stream2 = StreamController.broadcast();
        await expect(() => stream2.stream.pipe(socket), throwsA(isStateError));
        stream1.close();
        stream2.close();
      });
    });
    group('#addUtf8Text', () {
      test('text', () async {
        socket.addUtf8Text(<int>[00, 1, 195, 191]);
        expect(await socket.stream.first, '\u{0}\u{1}\u{FF}');
      });
    });
  });
}
