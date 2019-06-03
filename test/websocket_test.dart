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
      socket.close();
    });
    test('close connection from client side', () async {
      final socket = await WebSocket.connect(url);
      expect(socket.readyState, 1);
      await expectLater(socket.stream, emitsInOrder([]));
      socket.close(3001, 'reason 3001');
      await expectLater(socket.stream, emitsDone);
      expect(socket.closeCode, 3001);
      expect(socket.closeReason, 'reason 3001');
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
      // socket?.close();
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
      tearDown(() {
        // otherwise socket?.close(); in other teadDown will throw error
        // Bad state: StreamSink is already bound to a stream
        socket = null;
      });
      test('single-subscription stream', () async {
        final stream1 = StreamController();
        socket.addStream(stream1.stream);

        stream1.add('frame1');
        stream1.add('frame3');

        await expectLater(
            socket.stream,
            emitsInOrder([
              'frame1',
              'frame3',
            ]));
      });
      test('multiple streams throw error', () async {
        final stream1 = StreamController();
        socket.addStream(stream1.stream);
        final stream2 = StreamController();
        await expect(
            () => socket.addStream(stream2.stream), throwsA(isStateError));
      });
      test('cannot send more data after addStream', () async {
        final stream1 = StreamController();
        socket.addStream(stream1.stream);
        await expect(() => socket.add('a'), throwsA(isStateError));
        await expect(() => socket.addUtf8Text([0, 1]), throwsA(isStateError));
        await expect(() => socket.close(), throwsA(isStateError));
      }, skip: true);
      test('broadcast stream', () async {
        final stream1 = StreamController.broadcast();
        socket.addStream(stream1.stream);

        stream1.add('frame1');
        stream1.add('frame3');

        await expectLater(
            socket.stream,
            emitsInOrder([
              'frame1',
              'frame3',
            ]));
      });
      test('multiple broadcast streams throw error', () async {
        final stream1 = StreamController.broadcast();
        socket.addStream(stream1.stream);
        final stream2 = StreamController.broadcast();
        await expect(
            () => socket.addStream(stream2.stream), throwsA(isStateError));
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
