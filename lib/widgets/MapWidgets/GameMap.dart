import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/util/ImageHelper.dart';
import 'package:location/location.dart';

import '../WidgetView.dart';

class GameMap extends StatefulWidget {
  @override
  _GameMapController createState() => _GameMapController();
}

// Controller
class _GameMapController extends State<GameMap> {
  Widget build(BuildContext context) => _GameMapView(this);

  String _mapStyle;
  GoogleMapController _controller;
  Location _location = Location();

  BitmapDescriptor pinIcon;
  Set<Marker> _markers = {};
  // Only used for initial loading, will be replaced as soon as user location is fetched.
  LatLng _playerPosition = LatLng(51.6978162, 5.3036748);

  @override
  void initState() {
    // Load the map style from the assets
    rootBundle
        .loadString('assets/styles/light-map.json')
        .then((value) => _mapStyle = value);

    // Load the icon from storage
    ImageHelper.getBytesFromAsset(
            rootBundle, 'assets/images/map-markers/police_marker.png', 75)
        .then((value) {
      pinIcon = BitmapDescriptor.fromBytes(value);
    });

    super.initState();
  }

  void _onMapCreated(GoogleMapController mapController) {
    _controller = mapController;
    _controller.setMapStyle(_mapStyle);

    addPin();

    _location.getLocation().then((newLocation) {
      _playerPosition = LatLng(newLocation.latitude, newLocation.longitude);
      moveCameraToCurrentLocation();
    });

    _location.onLocationChanged().listen((LocationData newLocation) {
      _playerPosition = LatLng(newLocation.latitude, newLocation.longitude);
    });
  }

  void addPin() {
    LatLng pinPosition = LatLng(51.525349, 5.483690);
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('example ID'),
          position: pinPosition,
          icon: pinIcon));
    });
  }

  // Moves the camera to the current location of the player
  void moveCameraToCurrentLocation() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_playerPosition.latitude, _playerPosition.longitude),
            zoom: 17),
      ),
    );
  }
}

// View
class _GameMapView extends WidgetView<GameMap, _GameMapController> {
  final state;
  const _GameMapView(this.state) : super(state);

  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: state._playerPosition),
        onMapCreated: state._onMapCreated,
        myLocationEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        buildingsEnabled: false,
        markers: state._markers,
      ),
    );
  }
}
