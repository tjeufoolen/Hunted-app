import 'package:flutter_session/flutter_session.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/Markers/CustomMarker.dart';
import 'package:hunted_app/models/Player.dart';

class TreasureMarker extends CustomMarker {
  int _id;

  TreasureMarker(MarkerId markerId, LatLng location, int id)
      : super(markerId, location, 'map-markers/treasure_marker.png', 75){
        _id = id;
      }

  @override
  Future<void> onClick() async {
    // TODO: implement onClick
    Player player = Player.fromJson(await FlutterSession().get("LoggedInPlayer"));

    print("id:");
    print(_id);
  }
}
