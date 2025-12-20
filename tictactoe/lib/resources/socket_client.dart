import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static SocketClient? _instance;
  IO.Socket? socket;

  SocketClient._internal() {
    socket = IO.io(
      'http://10.25.185.20:3000',
      {
        'transports': ['websocket'],
        'autoConnect': true, // ✅ MUST be true
      },
    );

    socket!.onConnect((_) {
      print('✅ Flutter connected to server');
    });

    socket!.onConnectError((err) {
      print('❌ Connect error: $err');
    });

    socket!.onDisconnect((_) {
      print('❌ Disconnected');
    });
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
