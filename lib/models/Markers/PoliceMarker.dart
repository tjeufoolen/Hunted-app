import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/Markers/CustomMarker.dart';

class PoliceMarker extends CustomMarker {
  PoliceMarker(MarkerId markerId, LatLng location)
      : super(markerId, location, 'map-markers/police_marker.png', 75);

  @override
  void onClick() {
    // TODO: implement onClick
  }
}
