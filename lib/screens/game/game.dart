import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/widgets/WidgetView.dart';

// Widget
class Game extends StatefulWidget {
  @override
  _GameController createState() => _GameController();
}

// Controller
class _GameController extends State<Game> {
  Widget build(BuildContext context) => _GameView(this);
  Player loggedInPlayer;

  @override
  void initState() {
    super.initState();

    _loadPlayer().then((player) {
      setState(() {
        loggedInPlayer = player;
      });
    });
  }

  Future<Player> _loadPlayer() async {
    return Player.fromJson(await FlutterSession().get("LoggedInPlayer"));
  }
}

// View
class _GameView extends WidgetView<Game, _GameController> {
  final state;
  const _GameView(this.state) : super(state);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text("game ${state?.loggedInPlayer?.game?.id?.toString() ?? ''}"),
      ),
      body: Center(
        child: Text(
          "Game ${state?.loggedInPlayer?.game?.id?.toString() ?? ''}",
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}
