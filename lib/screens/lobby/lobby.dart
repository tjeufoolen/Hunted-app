import 'package:flutter/material.dart';
import 'package:hunted_app/routes/Routes.dart';
import 'package:hunted_app/screens/game/gameArguments.dart';
import 'package:hunted_app/screens/lobby/lobbyArguments.dart';

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
  Widget build(BuildContext context) {
    final LobbyArguments arguments = ModalRoute.of(context).settings.arguments;
    loggedInPlayer = arguments.loggedInPlayer;
    return _LobbyView(this);
  }

  _LobbyController() {
    _socketService.getSocket().on('gameStarted', (_) {
      setState(() {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed(
            Routes.Game,
            arguments: GameArguments(loggedInPlayer));
      });
    });
  }

  Player loggedInPlayer;
  String gameId;
  SocketService _socketService = SocketService();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        gameId = loggedInPlayer?.game?.id?.toString();
      });
    });
    // Continue initialization. Should be after own code.
    super.initState();
  }

  void _bottomNavTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, Routes.Login);
        break;
      default:
    }
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
        title: Text("Wachtruimte - Spel ${state.gameId ?? ''}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Wachtruimte",
              style: TextStyle(fontSize: 48),
            ),
            Text(
              "Je bevind je momenteel in de wachtruimte van spel ${state.gameId ?? ''}.\nHet spel start automatisch, zodra de spelleider dit heeft aangegeven.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Wachtruimte",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Terug",
          ),
        ],
        onTap: state._bottomNavTapped,
      ),
    );
  }
}
