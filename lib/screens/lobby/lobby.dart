import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:hunted_app/widgets/WidgetView.dart';
import 'package:hunted_app/models/Player.dart';

// Widget
class Lobby extends StatefulWidget {
  @override
  _LobbyController createState() => _LobbyController();
}

// Controller
class _LobbyController extends State<Lobby> {
  _LobbyController() {
    _socketService.getSocket().on('gameStarted', (_) {
      setState(() {
        Navigator.pushReplacementNamed(context, '/game');
      });
    });
  }

  Widget build(BuildContext context) => _LobbyView(this);

  Player loggedInPlayer;
  String gameId;
  SocketService _socketService = SocketService();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayer().then((player) {
        setState(() {
          loggedInPlayer = player;
          gameId = loggedInPlayer?.game?.id?.toString();
        });
      });
    });
    // Continue initialization. Should be after own code.
    super.initState();
  }

  Future<Player> _loadPlayer() async {
    return Player.fromJson(await FlutterSession().get("LoggedInPlayer"));
  }
}

// View
class _LobbyView extends WidgetView<Lobby, _LobbyController> {
  final state;
  const _LobbyView(this.state) : super(state);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Lobby - Game ${state.gameId ?? ''}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Lobby",
              style: TextStyle(fontSize: 48),
            ),
            Text(
              "Je bevind je momenteel in de lobby van game ${state.gameId ?? ''}.\nHet spel start automatisch, zodra de spelleider dit heeft aangegeven.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
