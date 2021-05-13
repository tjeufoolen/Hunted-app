// https://itnext.io/flutter-navigation-routing-made-easy-816ddf9e2857
import 'package:flutter/widgets.dart';
import 'package:hunted_app/screens/game/game.dart' as screens;
import 'package:hunted_app/screens/lobby/lobby.dart' as screens;
import 'package:hunted_app/screens/login/login.dart' as screens;

class Routes {
  static const String Login = '/login';
  static const String Lobby = '/lobby';
  static const String Game = '/game';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      Routes.Login: (context) => screens.Login(),
      Routes.Lobby: (context) => screens.Lobby(),
      Routes.Game: (context) => screens.Game()
    };
  }
}
