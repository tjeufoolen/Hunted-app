import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:hunted_app/screens/game/game.dart';
import 'package:hunted_app/screens/lobby/lobby.dart';

import 'package:hunted_app/screens/login/login.dart';

Future main() async {
  await DotEnv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hunted',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: "/login",
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          "/login": (BuildContext context) => new Login(),
          "/lobby": (BuildContext context) => new Lobby(),
          "/game": (BuildContext context) => new Game(),
        });
  }
}
