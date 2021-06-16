import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hunted_app/models/GameLocation.dart';
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

  Map<int, GameLocation> _globalGameLocations = Map();
  Map<int, GameLocation> _nearbyGameLocations = Map();

  Set<Marker> _markers = {};
  Set<Circle> _gameAreas = {};
  Circle _gameArea;

  num _playerDistanceRadius = 200;

  bool _gameAreaDialogIsShowing = false;
  bool _socketOnIsSetUp = false;
  bool _startUpLocationsSetup = false;

  Socket socket;

  // Only used for initial loading, will be replaced as soon as user location is fetched.
  LatLng _playerPosition = LatLng(51.6978162, 5.3036748);

  @override
  Widget build(BuildContext context) {
    final Game currentGame = widget?.loggedInPlayer?.game;

    if (currentGame != null) {
      _playerDistanceRadius = currentGame.distanceThiefPolice;

      _setGameArea(currentGame);
      if (!_startUpLocationsSetup) {
        _setGameLocations(currentGame);
        _startUpLocationsSetup = true;
      }
    }

    if (!_socketOnIsSetUp) {
      socket = _socketService.getSocket();

      socket.on('locations', (data) {
        _onLocationsReceived(data, isNearby: false);
      });
      socket.on('nearby_locations_update', (data) {
        _onLocationsReceived(data, isNearby: true);
      });
      socket.on('pick_up_treasure_result', (data) {
        _triggerPlayerPickUp(jsonDecode(data));
      });

      _socketOnIsSetUp = true;
    }

    return _GameMapView(this);
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Load the map style from the assets
    rootBundle
        .loadString('assets/styles/light-map.json')
        .then((value) => _mapStyle = value);
  }

  void _onLocationsReceived(locations, {isNearby = false}) {
    Map<int, GameLocation> gameLocations = Map.fromIterable(
      locations.toList().map((data) => GameLocation.fromJson(data)),
      key: (e) => e.id,
      value: (e) => e,
    );

    if (isNearby) {
      _nearbyGameLocations = gameLocations;
    } else {
      _globalGameLocations = gameLocations;
    }

    _updatePlayerMarkers();
  }

  void _updatePlayerMarkers() {
    // Merge global and nearby game locations together.
    Map<int, GameLocation> gameLocations = {..._globalGameLocations};
    _nearbyGameLocations.forEach((key, value) => gameLocations[key] = value);

    // Remove own gameLocation from all
    gameLocations.remove(widget.loggedInPlayer?.id);

    // Create/Replace markers and update view
    MarkerFactory().createAll(gameLocations.values.toList()).then((value) {
      if (this.mounted) {
        setState(() => _markers = value.toSet());
      }
    });
  }

  void _triggerPlayerPickUp(message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message["title"]),
            content: Text(message["body"]),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
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
      _drawNearbyPlayersCircle();
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

  void _drawNearbyPlayersCircle() {
    String identifier = "nearbyPlayerCircle";
    _gameAreas
        .removeWhere((element) => element.circleId == CircleId(identifier));

    if (mounted) {
      setState(() {
        _gameAreas.add(
          Circle(
              circleId: CircleId(identifier),
              center: _playerPosition,
              radius: _playerDistanceRadius.toDouble(),
              fillColor: ColorHelper.nearbyPlayersCircleFill,
              strokeWidth: 0),
        );
      });
    }
  }

  void _triggerPlayerOutsideOfGame() {
    if (!_gameAreaDialogIsShowing) {
      _gameAreaDialogIsShowing = true;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Spel verlaten!"),
              content: Text(
                  "Je bent voorbij het spelgebied, gelieve terug te keren!"),
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
      _globalGameLocations = Map.fromIterable(
        currentGame.gameLocations
            .toList()
            .map((data) => GameLocation.fromJson(data)),
        key: (e) => e.id,
        value: (e) => e,
      );

      MarkerFactory().createAll(currentGame.gameLocations).then((value) {
        setState(() {
          _markers = value.toSet();
        });
      });
    }
  }

  void _setGameArea(Game currentGame) {
    String identifier = "gameArea";
    bool gameHasLatitude = currentGame.gameAreaLatitude != null;
    bool gameHasLongitude = currentGame.gameAreaLongitude != null;
    bool gameHasAreaRadius = currentGame.gameAreaRadius != null;

    if (gameHasLatitude && gameHasLongitude && gameHasAreaRadius) {
      _gameArea = Circle(
        circleId: CircleId(identifier),
        center:
            LatLng(currentGame.gameAreaLatitude, currentGame.gameAreaLongitude),
        radius: currentGame.gameAreaRadius.toDouble(),
        strokeWidth: 5,
        strokeColor: ColorHelper.gameAreaOutline,
        fillColor: ColorHelper.gameAreaFill,
      );

      _gameAreas
          .removeWhere((element) => element.circleId == CircleId(identifier));

      setState(() {
        _gameAreas.add(_gameArea);
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
