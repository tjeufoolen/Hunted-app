import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/util/ImageHelper.dart';

abstract class CustomMarker {
  MarkerId _markerId;
  LatLng _location;
  String _iconPath;
  int _iconWidthScalar;

  CustomMarker(
      this._markerId, this._location, this._iconPath, this._iconWidthScalar);

  Future<Marker> getGoogleMarker() async {
    return getIcon().then((bitmapIcon) => Marker(
          markerId: this._markerId,
          position: this._location,
          icon: bitmapIcon,
          onTap: onClick,
        ));
  }

  Future<BitmapDescriptor> getIcon() async {
    return await ImageHelper().getImage(this._iconPath, this._iconWidthScalar);
  }

  void onClick();
}
