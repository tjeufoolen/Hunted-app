import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/GameLocation.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/util/MarkerFactory.dart';
import 'package:location/location.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:socket_io_client/socket_io_client.dart';



import '../WidgetView.dart';

class GameMap extends StatefulWidget {
  final Player loggedInPlayer;
  const GameMap({Key key, this.loggedInPlayer}) : super(key: key);

  @override
  _GameMapController createState() => _GameMapController();
}

// Controller
class _GameMapController extends State<GameMap> {

  bool socketNotSetupYet = true;
  @override
  Widget build(BuildContext context) {

    if(socketNotSetupYet){
      if (widget?.loggedInPlayer?.game?.gameLocations != null) {
        MarkerFactory()
            .createAll(widget.loggedInPlayer.game.gameLocations)
            .then((value) {
          setState(() {
            _markers = value.toSet();
          });
        });
      }
      Socket socket = _socketService.getSocket();
      socket.on('locations', (data) => _onLocationsReceived(data));
      socketNotSetupYet = false;
      // socket.on('locations', _onLocationsReceived);
    }

    return _GameMapView(this);
  }

  String _mapStyle;
  GoogleMapController _controller;
  Location _location = Location();
  SocketService _socketService = SocketService();

  Set<Marker> _markers = {};
  // Only used for initial loading, will be replaced as soon as user location is fetched.
  LatLng _playerPosition = LatLng(51.6978162, 5.3036748);

  @override
  void initState() {
    super.initState();

    // Load the map style from the assets
    rootBundle
        .loadString('assets/styles/light-map.json')
        .then((value) => _mapStyle = value);
  }
  
  void _onLocationsReceived(locations){
    print(locations);
    List<GameLocation> parsedLocations = List<GameLocation>.from(locations.toList().map((data) => GameLocation.fromJson(data)));
    MarkerFactory()
        .createAll(parsedLocations)
        .then((value) {
      setState(() {
        _markers = value.toSet();
      });
    });
  }

  void _onMapCreated(GoogleMapController mapController) {
    _controller = mapController;
    _controller.setMapStyle(_mapStyle);

    _location.getLocation().then((newLocation) {
      _playerPosition = LatLng(newLocation.latitude, newLocation.longitude);
      moveCameraToCurrentLocation();
    });

    _location.onLocationChanged().listen((LocationData newLocation) {
      _playerPosition = LatLng(newLocation.latitude, newLocation.longitude);
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
