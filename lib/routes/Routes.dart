// https://itnext.io/flutter-navigation-routing-made-easy-816ddf9e2857
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hunted_app/screens/game/game.dart' as screens;
import 'package:hunted_app/screens/lobby/lobby.dart' as screens;
import 'package:hunted_app/screens/login/login.dart' as screens;

class Routes {
  static const String Login = '/login';
  static const String Lobby = '/lobby';
  static const String Game = '/game';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget Function(BuildContext, Animation<double>, Animation<double>) builder;

    switch (settings.name) {
      case Routes.Login:
        builder = (context, animation1, animation2) => screens.Login();
        break;
      case Routes.Lobby:
        builder = (context, animation1, animation2) => screens.Lobby();
        break;
      case Routes.Game:
        builder = (context, animation1, animation2) => screens.Game();
        break;
      default:
        builder = (context, animation1, animation2) => screens.Login();
        break;
    }

    return PageRouteBuilder(
      pageBuilder: builder,
      transitionDuration: Duration(seconds: 0),
      settings: settings,
    );
  }
}
