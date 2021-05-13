import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:hunted_app/routes/Routes.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:location/location.dart';

import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/screens/game/gameArguments.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:hunted_app/util/CronHelper.dart';
import 'package:hunted_app/widgets/MapWidgets/GameMap.dart';
import 'package:hunted_app/widgets/WidgetView.dart';

// Widget
class Game extends StatefulWidget {
  @override
  _GameController createState() => _GameController();
}

// Controller
class _GameController extends State<Game> {
  Widget build(BuildContext context) {
    final GameArguments arguments = ModalRoute.of(context).settings.arguments;
    loggedInPlayer = arguments.loggedInPlayer;
    return _GameView(this);
  }

  Player loggedInPlayer;
  List<Widget> gameBodyOptions = <Widget>[Text("Loading...")];
  int selectedIndex = 0;

  SocketService _socketService = new SocketService();
  CronHelper _cronHelper = new CronHelper();
  Cron cron;
  Socket socket;

  int countdownEnd = 0;
  CountdownTimerController countdownController;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _socketService.initializeSocket(loggedInPlayer.game.id);
      cron = _cronHelper.initializeCron(loggedInPlayer);
      gameBodyOptions = _getGameBodyOptions();

      setState(() {
        countdownEnd = loggedInPlayer.game.startAt
            .add(Duration(minutes: loggedInPlayer.game.minutes))
            .millisecondsSinceEpoch;
        countdownController =
            CountdownTimerController(endTime: countdownEnd, onEnd: _endGame);
      });
    });
  }

  // This method returns an array of possible options of the game body
  // and is used for navigation using the bottomnav.
  List<Widget> _getGameBodyOptions() {
    return <Widget>[GameMap(loggedInPlayer: loggedInPlayer)];
  }

  void _endGame() {
    cron.close();
    Navigator.pushReplacementNamed(context, Routes.Login);
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        setState(() {
          selectedIndex = index;
        });
        break;
      case 1:
        _endGame();
        break;
      default:
    }
  }
}

// View
class _GameView extends WidgetView<Game, _GameController> {
  final state;
  const _GameView(this.state) : super(state);

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
        title:
            Text("game ${state?.loggedInPlayer?.game?.id?.toString() ?? ''}"),
        actions: [
          CountdownTimer(
            endTime: state.countdownEnd,
            controller: state.countdownController,
            widgetBuilder: (_, CurrentRemainingTime time) {
              if (time == null) {
                return Text("");
              }
              return Center(
                child: Text(
                  "${_formatNumber(time.hours)} : ${_formatNumber(time.min)} : ${_formatNumber(time.sec)}  ",
                  style: TextStyle(fontSize: 18),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(child: state.gameBodyOptions.elementAt(state.selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Game"),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Logout",
          )
        ],
        onTap: state._onBottomNavTap,
      ),
    );
  }
}
