import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:hunted_app/routes/Routes.dart';
import 'package:hunted_app/screens/game/gameArguments.dart';
import 'package:hunted_app/screens/lobby/lobbyArguments.dart';

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

  Player loggedInPlayer;
  String gameId;

  int countdownEnd = 0;
  CountdownTimerController countdownController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        gameId = loggedInPlayer?.game?.id?.toString();
        countdownEnd = loggedInPlayer.game.startAt.millisecondsSinceEpoch;
        countdownController =
            CountdownTimerController(endTime: countdownEnd, onEnd: _timerEnded);
      });
    });
    // Continue initialization. Should be after own code.
    super.initState();
  }

  void _timerEnded() {
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(Routes.Game,
        arguments: GameArguments(loggedInPlayer));
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
    String _formatNumber(int number) {
      if (number == null) return "00";
      if (number < 10) {
        return "0" + number.toString();
      }
      return number.toString();
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Lobby game ${state.gameId ?? ''}"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Game ${state.gameId ?? ''}",
                style: TextStyle(fontSize: 48),
              ),
              CountdownTimer(
                controller: state.countdownController,
                endTime: state.countdownEnd,
                widgetBuilder: (_, CurrentRemainingTime time) {
                  if (time == null) {
                    return Text("Game is starting...");
                  }
                  return Text(
                    "${_formatNumber(time.days)} : ${_formatNumber(time.hours)} : ${_formatNumber(time.min)} : ${_formatNumber(time.sec)}",
                    style: TextStyle(fontSize: 32),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Lobby"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Back"),
        ], onTap: state._bottomNavTapped));
  }
}
