import 'package:flutter_session/flutter_session.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/Markers/CustomMarker.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/SocketService.dart';

class ThiefMarker extends CustomMarker {
  int _id;

  ThiefMarker(MarkerId markerId, LatLng location, int id)
      : super(markerId, location, 'map-markers/thief_marker.png', 75){
        _id = id;
      }

  @override
  Future<void> onClick() async {
    Player player = Player.fromJson(await FlutterSession().get("LoggedInPlayer"));
    SocketService socket = SocketService();
    if(player.playerRole == PlayerRolesEnum.POLICE){
      socket.emitData('arrest_thief', {"playerId": player.id, "thiefId": _id});
    }
  }
}
