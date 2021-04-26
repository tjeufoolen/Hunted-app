import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class CustomMarker extends Marker {
  CustomMarker(MarkerId markerId, LatLng location, BitmapDescriptor icon)
      : super(markerId: markerId, position: location, icon: icon);
}
