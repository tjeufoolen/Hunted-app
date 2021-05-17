import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hunted_app/screens/game/mapScreen.dart' as screens;
import 'package:hunted_app/widgets/MapWidgets/GameMap.dart' as Widgets;

class GameRoutes {
  static const String GameMapScreen = "gameMap";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    WidgetBuilder builder;

    switch (settings.name) {
      case GameRoutes.GameMapScreen:
        builder = (BuildContext context) => screens.MapScreen();
        break;
      default:
        builder = (BuildContext context) => screens.MapScreen();
        break;
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
