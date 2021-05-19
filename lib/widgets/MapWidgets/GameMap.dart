import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/GameLocation.dart';
import 'package:hunted_app/models/LocationTypeEnum.dart';
import 'package:hunted_app/util/ColorHelper.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maptoolkit;
import 'package:hunted_app/models/Game.dart';
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


  String _mapStyle;
  GoogleMapController _controller;

  Location _location = Location();
  SocketService _socketService = SocketService();

  Set<Marker> _markers = {};
  Set<Circle> _gameAreas = {};
  Circle _gameArea;

  bool _gameAreaDialogIsShowing = false;
  bool _socketOnIsSetUp = false;
  bool _startUpLocationsSetup = false;

  // Only used for initial loading, will be replaced as soon as user location is fetched.
  LatLng _playerPosition = LatLng(51.6978162, 5.3036748);

  @override
  Widget build(BuildContext context) {
    final Game currentGame = widget?.loggedInPlayer?.game;

    if (currentGame != null) {
      _setGameArea(currentGame);
      if(!_startUpLocationsSetup){
        _setGameLocations(currentGame);
        _startUpLocationsSetup = true;
      }
    }

    if (!_socketOnIsSetUp) {
      Socket socket = _socketService.getSocket();
      socket.on('locations', (data) => _onLocationsReceived(data));
      _socketOnIsSetUp = true;
    }


    return _GameMapView(this);
  }

  @override
  void initState() {
    super.initState();

    // Load the map style from the assets
    rootBundle
        .loadString('assets/styles/light-map.json')
        .then((value) => _mapStyle = value);
  }
  
  void _onLocationsReceived(locations){
    List<GameLocation> parsedLocations = List<GameLocation>.from(locations.toList().map((data) => GameLocation.fromJson(data)));
    for(int i = 0; i < parsedLocations.length; i ++){
      if(parsedLocations[i].locationType == LocationType.POLICE || parsedLocations[i].locationType == LocationType.THIEF){
         if(parsedLocations[i].id == widget?.loggedInPlayer?.id) {
           parsedLocations.removeAt(i);
           break;
         }
      }
    }

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
      _checkIfPlayerOutsideOfGame();
    });
  }

  void _checkIfPlayerOutsideOfGame() {
    if (_gameArea != null) {
      final playerLocation = maptoolkit.LatLng(
          _playerPosition.latitude, _playerPosition.longitude);
      final centerGameAreaLocation = maptoolkit.LatLng(
          _gameArea.center.latitude, _gameArea.center.longitude);
      final range = _gameArea.radius;

      if (maptoolkit.SphericalUtil.computeDistanceBetween(
              playerLocation, centerGameAreaLocation) >
          range) {
        _triggerPlayerOutsideOfGame();
      }
    }
  }

  void _triggerPlayerOutsideOfGame() {
    if (!_gameAreaDialogIsShowing) {
      _gameAreaDialogIsShowing = true;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Leaving gamearea!"),
              content: Text("Turn back immediately"),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _gameAreaDialogIsShowing = false;
                  },
                )
              ],
            );
          });
    }
  }

  void _setGameLocations(Game currentGame) {
    if (currentGame?.gameLocations != null) {
      MarkerFactory().createAll(currentGame.gameLocations).then((value) {
        setState(() {
          _markers = value.toSet();
        });
      });
    }
  }

  void _setGameArea(Game currentGame) {
    bool gameHasLatitude = currentGame.gameAreaLatitude != null;
    bool gameHasLongitude = currentGame.gameAreaLongitude != null;
    bool gameHasAreaRadius = currentGame.gameAreaRadius != null;

    if (gameHasLatitude && gameHasLongitude && gameHasAreaRadius) {
      _gameArea = Circle(
        circleId: CircleId('gameArea'),
        center:
            LatLng(currentGame.gameAreaLatitude, currentGame.gameAreaLongitude),
        radius: currentGame.gameAreaRadius.toDouble(),
        strokeWidth: 5,
        strokeColor: ColorHelper.gameAreaOutline,
        fillColor: ColorHelper.gameAreaFill,
      );

      setState(() {
        _gameAreas = {_gameArea};
      });
    }
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
        circles: state._gameAreas,
      ),
    );
  }
}
