export 'src/websocket_stub.dart'
    if (dart.library.html) 'src/websocket_browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'src/websocket_io.dart';
export 'src/websocket_status.dart';
