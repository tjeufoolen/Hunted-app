import 'package:flutter_config/flutter_config.dart';
import 'package:socket_io_client/socket_io_client.dart';


class SocketService {
  static final SocketService _instance = SocketService._internal();

  Socket _socket;

  // TODO move to a constructor
  Socket initializeSocket(gameId){
    _socket = io(FlutterConfig.get('API_URL'),
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .build());
    _socket.connect();
    _socket.onConnect((_) {
      _socket.emit('join_room', gameId);
    });
    // TODO remove when no longer necessary
    // Out commented code is for debugging purposes
    // _socket.on('event', (data) => print(data));
    // _socket.onDisconnect((_) => print('disconnect'));
    // _socket.on('fromServer', (_) => print(_));

    return _socket;
  }

  void emitData(event, data){
    _socket.emit(event, data);
  }

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();
}
