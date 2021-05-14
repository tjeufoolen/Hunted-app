import 'package:flutter_config/flutter_config.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:socket_io_client/socket_io_client.dart';


class SocketService {
  static final SocketService _instance = SocketService._internal();

  Socket _socket;

  // TODO move to a constructor
  Socket initializeSocket(gameId, playerType){
    _socket = io(FlutterConfig.get('API_URL'),
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .build());
    _socket.connect();
    _socket.onConnect((_) {
      print('join the room');
      _socket.emit('join_room', gameId);

      if(playerType == PlayerRolesEnum.POLICE) {
        _socket.emit('join_room', "police_" + gameId.toString());
      } else if (playerType == PlayerRolesEnum.THIEF) {
        _socket.emit('join_room', "thiefs_" + gameId.toString());
      }

    });
    // TODO remove when no longer necessary
    // Out commented code is for debugging purposes
    // _socket.onDisconnect((_) => print('disconnect'));
    // _socket.on('fromServer', (_) => print(_));
    print('socket should be setup');
    return _socket;
  }

  void emitData(event, data){
    _socket.emit(event, data);
  }

  Socket getSocket(){
    return _socket;
  }

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();
}
