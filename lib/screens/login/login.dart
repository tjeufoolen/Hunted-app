import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:hunted_app/exceptions/HTTPResponseException.dart';
import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/AuthDataService.dart';
import 'package:hunted_app/widgets/WidgetView.dart';

class Login extends StatefulWidget {
  @override
  _LoginController createState() => _LoginController();
}

class _LoginController extends State<Login> {
  Widget build(BuildContext context) => _LoginView(this);

  final _formKey = GlobalKey<FormState>();

  AuthDataService authService;
  String currentInviteCode;

  @override
  void initState() {
    authService = AuthDataService();
  }

  void handleLoginPressed() async {
    if (_formKey.currentState.validate()) {
      authService.joinGame(currentInviteCode).then((value) async {
        handleSuccessfulLogin(value);
      }).catchError((e) => handleFailedLogin(e.message),
          test: (e) => e is HTTPResponseException);
    }
  }

  void handleSuccessfulLogin(Player joinedAsPlayer) async {
    await FlutterSession().set("LoggedInPlayer", joinedAsPlayer);
    print(Player.fromJson(await FlutterSession().get("LoggedInPlayer")));

    // Navigator.pushReplacementNamed(context, '/home');

    // print(joinedAsPlayer.game);
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

  String validateInviteToken(String value) {
    if (value.isEmpty) return "Please enter a invite token";

    RegExp matchesFormat = new RegExp('(([a-zA-Z0-9]{5})-){7}([a-zA-Z0-9]{5})');
    if (!matchesFormat.hasMatch(value)) return "Invited code is invalid";

    return null;
  }
}

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
        ));
  }
}
