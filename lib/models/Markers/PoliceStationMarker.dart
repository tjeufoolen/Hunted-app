import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/Markers/CustomMarker.dart';
import 'package:hunted_app/util/ImageHelper.dart';

class PoliceStationMarker extends CustomMarker {
  static final String iconPath = 'map-markers/police_marker.png';
  static final int iconWidthScaler = 75;

  PoliceStationMarker(MarkerId markerId, LatLng location, BitmapDescriptor icon)
      : super(markerId, location, icon);

  static Future<PoliceStationMarker> create(
      MarkerId markerId, LatLng location) async {
    var icon = await ImageHelper().getImage(iconPath, iconWidthScaler);
    return PoliceStationMarker(markerId, location, icon);
  }

  static Future<BitmapDescriptor> getIcon() async {
    return await ImageHelper().getImage(iconPath, iconWidthScaler);
  }
}
