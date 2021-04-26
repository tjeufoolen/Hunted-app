import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:location/location.dart';

import 'package:hunted_app/exceptions/HTTPResponseException.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/AuthDataService.dart';
import 'package:hunted_app/widgets/WidgetView.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


// Widget
class Login extends StatefulWidget {
  @override
  _LoginController createState() => _LoginController();
}

// Controller
class _LoginController extends State<Login> {
  Widget build(BuildContext context) => _LoginView(this);

  final _formKey = GlobalKey<FormState>();

  AuthDataService authService;
  String currentInviteCode;

  @override
  void initState() {
    authService = AuthDataService();
    print('connecting to socket');
    Socket socket = io('http://10.0.2.2:3000',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()  // disable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    socket.connect();

    print('should be connected?');
    socket.onConnect((_) {
      print('connected');
      socket.emit('join_room', 'test');
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
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
            handleFailedLogin("Game already ended");
            return;
          }

          handleSuccessfulLogin(value);
        }).catchError((e) => handleFailedLogin(e.message),
            test: (e) => e is HTTPResponseException);
        return;
      }

      handleFailedLogin(
          "This application requires location permissions to function. Please enable location permissions on this device in order to continue.");
    }
  }

  void handleSuccessfulLogin(Player joinedAsPlayer) async {
    FlutterSession().set("LoggedInPlayer", joinedAsPlayer).then((value) {
      // The game has already started, navigate to game
      if (joinedAsPlayer.game.startAt
          .toUtc()
          .isBefore(DateTime.now().toUtc())) {
        Navigator.pushReplacementNamed(context, '/game');
      } else {
        Navigator.pushReplacementNamed(context, '/lobby');
      }
    });
  }

  void handleFailedLogin(String error) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Failed to join game"),
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
    if (value.isEmpty) return "Please enter a invite token";

    RegExp matchesFormat = new RegExp('((.{5})-){7}(.{5})');
    if (!matchesFormat.hasMatch(value)) return "Invited code is invalid";

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
          title: Text("Login Page"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 150,
                    child: Image.asset('assets/images/flutter-logo.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  validator: (value) => state.validateInviteToken(value),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Invite code',
                      hintText: 'Enter a valid invite code'),
                  onChanged: (value) {
                    state.currentInviteCode = value;
                  },
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
                    'Join Game',
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
