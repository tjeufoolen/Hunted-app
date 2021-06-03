import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:location/location.dart';

import 'package:hunted_app/routes/Routes.dart';
import 'package:hunted_app/screens/game/gameArguments.dart';
import 'package:hunted_app/screens/lobby/lobbyArguments.dart';
import 'package:hunted_app/services/SocketService.dart';
import 'package:hunted_app/util/CronHelper.dart';
import 'package:hunted_app/exceptions/HTTPResponseException.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/AuthDataService.dart';
import 'package:hunted_app/widgets/WidgetView.dart';
import 'package:hunted_app/screens/login/loginArguments.dart';

// Widget
class Login extends StatefulWidget {
  @override
  _LoginController createState() => _LoginController();
}

// Controller
class _LoginController extends State<Login> {
  Widget build(BuildContext context) {
    final LoginArguments arguments = ModalRoute.of(context).settings.arguments;
    if (arguments?.initialJoinCode != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        currentInviteCode = arguments?.initialJoinCode;
        codeController.text = currentInviteCode;
        handleLoginPressed();
      });
    }
    return _LoginView(this);
  }

  final _formKey = GlobalKey<FormState>();

  AuthDataService authService;
  String currentInviteCode;
  SocketService socketService = SocketService();

  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    authService = AuthDataService();
    super.initState();
  }

  void handleLoginPressed() async {
    if (_formKey.currentState.validate()) {
      bool hasLocationAccess = await handleLocationPermissions();

      if (hasLocationAccess) {
        authService.joinGame(currentInviteCode).then((value) async {
          var gameEnd =
              value.game.startAt.add(Duration(minutes: value.game.minutes));

          if (gameEnd.isBefore(DateTime.now())) {
            handleFailedLogin("Het spel is al afgelopen");
            return;
          }

          handleSuccessfulLogin(value);
        }).catchError(
            (e) => handleFailedLogin(
                "De ingevoerde uitnodigscode kan niet gevonden worden"),
            test: (e) => e is HTTPResponseException);
        return;
      }

      handleFailedLogin(
          "Deze app heeft toegang nodig tot de gps van uw apparaat. Gelieve de app toegang te verlenen voor deze rechten in de instellingen van uw apparaat.");
    }
  }

  void handleSuccessfulLogin(Player joinedAsPlayer) async {
    FlutterSession().set("LoggedInPlayer", joinedAsPlayer).then((value) {
      // The game has already started, navigate to game
      socketService.initializeSocket(
          joinedAsPlayer.game.id,
          joinedAsPlayer
              .playerRole); //TODO: second parameter is placeholder for when enums are available

      CronHelper().initializeCron(joinedAsPlayer);

      if (joinedAsPlayer.game.isStarted &&
          joinedAsPlayer.game.startAt
              .toUtc()
              .isBefore(DateTime.now().toUtc())) {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed(
            Routes.Game,
            arguments: GameArguments(joinedAsPlayer));
      } else {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed(
            Routes.Lobby,
            arguments: LobbyArguments(joinedAsPlayer));
      }
    });
  }

  void handleFailedLogin(String error) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Spel betreden mislukt"),
            content: Text(error),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<bool> handleLocationPermissions() async {
    Location _location = Location();

    if (await _location.hasPermission() == PermissionStatus.GRANTED) {
      return true;
    }

    return await _location.requestPermission() == PermissionStatus.GRANTED;
  }

  String validateInviteToken(String value) {
    if (value.trim().isEmpty) return "Voer een uitnodigingscode in";
    return null;
  }
}

// View
class _LoginView extends WidgetView<Login, _LoginController> {
  final state;
  const _LoginView(this.state) : super(state);

  Widget build(BuildContext context) {
    return Form(
      key: state._formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Hunted"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Container(
                    width: 266,
                    height: 200,
                    child: Image.asset('assets/images/logo-icon.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  validator: (value) => state.validateInviteToken(value),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Uitnodigingscode',
                      hintText: 'Voer een uitnodigingscode in'),
                  onChanged: (value) {
                    state.currentInviteCode = value;
                  },
                  controller: state.codeController,
                ),
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                    state.handleLoginPressed();
                  },
                  child: Text(
                    'Spel betreden',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
