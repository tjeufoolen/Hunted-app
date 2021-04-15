import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
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
  int countdownEnd = 0;

  @override
  void initState() {
    super.initState();

    _loadPlayer().then((player) {
      setState(() {
        loggedInPlayer = player;
        countdownEnd = loggedInPlayer.game.startAt
            .add(Duration(minutes: loggedInPlayer.game.minutes))
            .millisecondsSinceEpoch;
      });
    });
  }

  void endGame() {}

  Future<Player> _loadPlayer() async {
    return Player.fromJson(await FlutterSession().get("LoggedInPlayer"));
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
            onEnd: state.endGame,
            endTime: state.countdownEnd,
            widgetBuilder: (_, CurrentRemainingTime time) {
              if (time == null) {
                return Text("");
              }
              return Center(
                child: Text(
                  "${_formatNumber(time.hours)} : ${_formatNumber(time.min)} : ${_formatNumber(time.sec)}  ",
                  style: TextStyle(fontSize: 22),
                ),
              );
            },
          ),
        ],
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