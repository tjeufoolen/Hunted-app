import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:hunted_app/util/CronHelper.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/routes/Routes.dart';
import 'package:hunted_app/routes/GameRoutes.dart';
import 'package:hunted_app/screens/game/gameArguments.dart';
import 'package:hunted_app/widgets/WidgetView.dart';

import 'mapScreenArguments.dart';

// Widget
class Game extends StatefulWidget {
  @override
  _GameController createState() => _GameController();
}

// Controller
class _GameController extends State<Game> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  Widget build(BuildContext context) {
    final GameArguments arguments = ModalRoute.of(context).settings.arguments;
    loggedInPlayer = arguments.loggedInPlayer;
    return _GameView(this);
  }

  Player loggedInPlayer;
  int currentIndex = 0;

  // TODO: CHANGE CRONHELPER TO SINGLETON AND SET IT HERE
  // Cron cron;
  Socket socket;

  int countdownEnd = 0;
  CountdownTimerController countdownController;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        countdownEnd = loggedInPlayer.game.startAt
            .add(Duration(minutes: loggedInPlayer.game.minutes))
            .millisecondsSinceEpoch;
        countdownController =
            CountdownTimerController(endTime: countdownEnd, onEnd: _endGame);
      });
    });
  }

  void _endGame() {
    CronHelper().locationSentCronJob.close();
    SocketService().getSocket().emit("leave_rooms");
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(Routes.Login);
  }

  void _bottomNavClicked(int index) {
    if (currentIndex != index) {
      switch (index) {
        case 0:
          currentIndex = 0;
          navigatorKey.currentState.pushNamed(GameRoutes.GameMapScreen,
              arguments: MapScreenArguments(loggedInPlayer));
          break;
        case 1:
          currentIndex = 1;
          _endGame();
          break;
        default:
      }
    }
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
            Text("Spel ${state?.loggedInPlayer?.game?.id?.toString() ?? ''}"),
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
      body: Navigator(
        key: state.navigatorKey,
        initialRoute: GameRoutes.GameMapScreen,
        onGenerateInitialRoutes: (navigator, initialRoute) {
          return [
            navigator.widget.onGenerateRoute(RouteSettings(
                name: GameRoutes.GameMapScreen,
                arguments: MapScreenArguments(state.loggedInPlayer)))
          ];
        },
        onGenerateRoute: GameRoutes.generateRoute,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Spel"),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: "Uitloggen",
          )
        ],
        onTap: state._bottomNavClicked,
      ),
    );
  }

  String _formatNumber(int number) {
    if (number == null) return "00";
    if (number < 10) {
      return "0" + number.toString();
    }
    return number.toString();
  }
}
