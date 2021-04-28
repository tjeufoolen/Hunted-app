import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/widgets/MapWidgets/GameMap.dart';
import 'package:hunted_app/widgets/WidgetView.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:location/location.dart';


// Widget
class Game extends StatefulWidget {
  @override
  _GameController createState() => _GameController();
}

// Controller
class _GameController extends State<Game> {
  Widget build(BuildContext context) => _GameView(this);
  Player loggedInPlayer;
  Location _location = Location();
  Cron cron;
  Socket socket;

  int countdownEnd = 0;
  CountdownTimerController countdownController;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _initializeCron();

    _loadPlayer().then((player) {
      setState(() {
        loggedInPlayer = player;
        countdownEnd = loggedInPlayer.game.startAt
            .add(Duration(minutes: loggedInPlayer.game.minutes))
            .millisecondsSinceEpoch;
        countdownController =
            CountdownTimerController(endTime: countdownEnd, onEnd: _endGame);
      });
    });
  }

  void _initializeSocket() {
    print('connecting to socket');
    socket = io(FlutterConfig.get('API_URL'),
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .build());
    socket.connect();
    socket.onConnect((_) {
      print('connected');
      socket.emit('join_room', loggedInPlayer.game.id);
    });
    // Out commented code is for debugging purposes
    // socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    // socket.on('fromServer', (_) => print(_));
  }

  void _initializeCron() {
    cron = new Cron();
    cron.schedule(new Schedule.parse('*/1 * * * *'), () async {
      _location.getLocation().then((newLocation) {
        var message = {
          "id": loggedInPlayer.id,
          "latitude": newLocation.latitude,
          "longitude": newLocation.longitude
        };
        print("location sent");
        socket.emit('send_location', message);
      });
    });
  }

  void _endGame() {
    cron.close();
    Navigator.pushReplacementNamed(context, '/login');
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
      body: Center(
        child: GameMap(loggedInPlayer: state.loggedInPlayer),
      ),
    );
  }
}
