import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  final String baseUrl = 'http://localhost:3000/socket';
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  late IO.Socket socket;
  Timer? _reconnectTimer;

  SocketService._internal();

// 连接到 Socket.IO 服务器
  void connect(
      {required Map<String, String> params}) {
    final uri = Uri.parse(baseUrl).replace(queryParameters: params).toString();
    socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    

    socket.onConnect((_) {
      print('Connected from Socket.IO server');
      _reconnectTimer?.cancel(); 
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
      _startReconnect();
    });

    socket.onError((error) {
      print('Socket.IO error: $error');
    });
  }


  void _startReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (socket.disconnected) {
        print('Attempting to reconnect...');
        socket.connect();
      } else {
        timer.cancel();
      }
    });
  }

  void listen(String event, Function(dynamic) onMessage) {
    socket.on(event, onMessage);
  }

  void send(String event, dynamic message) {
    socket.emit(event, message);
  }

  void close() {
    _reconnectTimer?.cancel();
    socket.disconnect();
  }
}
