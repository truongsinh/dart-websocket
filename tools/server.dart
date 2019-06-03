import 'dart:convert';
import 'dart:io';

const PORT = 5600;
void main() async {
  HttpServer server = await HttpServer.bind('localhost', PORT);
  server.transform(WebSocketTransformer()).listen((WebSocket client) {
    print('a client just connected');
    client.listen((data) {
      try {
        final parsed = jsonDecode(data);
        print('parsed: $parsed');
        final command = parsed['command'];
        if (command == 'close') {
          client.close(parsed['code'], parsed['reason']);
        }
      } catch (_) {
        print('message: $data');
        client.add(data);
      }
    }, onDone: () {
      print('close with ${client.closeCode} and ${client.closeReason}');
    });
  });
  print('listening on port: $PORT');
}
