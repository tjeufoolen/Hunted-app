import 'package:flutter_config/flutter_config.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();

  Socket _socket;
  Socket initializeSocket(gameId, playerType, playerId) {
    _socket = io(
        FlutterConfig.get('API_URL'),
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    _socket.connect();

    _socket.onConnect((_) {
      _socket.emit('join_room', gameId);

      if(playerType == PlayerRolesEnum.POLICE) {
        _socket.emit('join_room', "police_" + gameId.toString());
      } else if (playerType == PlayerRolesEnum.THIEF) {
        _socket.emit('join_room', "thiefs_" + gameId.toString());
        _socket.emit('join_room', "thief_" + playerId.toString());
      }
    });

    return _socket;
  }

  void emitData(event, data) {
    _socket.emit(event, data);
  }


  Socket getSocket() {
    return _socket;
  }

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();
}
