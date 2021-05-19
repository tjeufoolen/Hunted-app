import 'package:flutter/material.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/widgets/MapWidgets/GameMap.dart';
import 'package:hunted_app/widgets/WidgetView.dart';

import 'mapScreenArguments.dart';

// Widget
class MapScreen extends StatefulWidget {
  @override
  _MapScreenController createState() => _MapScreenController();
}

// Controller
class _MapScreenController extends State<MapScreen> {
  Widget build(BuildContext context) {
    final MapScreenArguments arguments =
        ModalRoute.of(context).settings.arguments;
    loggedInPlayer = arguments.loggedInPlayer;
    return _MapScreenView(this);
  }

  Player loggedInPlayer;
}

// View
class _MapScreenView extends WidgetView<MapScreen, _MapScreenController> {
  final state;
  const _MapScreenView(this.state) : super(state);

  Widget build(BuildContext context) {
    return GameMap(loggedInPlayer: state.loggedInPlayer);
  }
}
