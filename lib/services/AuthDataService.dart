import 'dart:convert';

import 'package:hunted_app/models/Player.dart';
import 'package:hunted_app/services/dataservice.dart';

class AuthDataService extends DataService<Player> {
  AuthDataService() : super(genericEndpoint: '');

  Future<Player> joinGame(String code) async {
    return executeRequest(http_methods.POST,
        endpoint: "/join", content: {'code': code}).then((value) {
      var player = convert(json.decode(value));
      return player;
    });
  }

  @override
  convert(Map<String, dynamic> json) => Player.fromJson(json);

  @override
  convertArray(Map<String, dynamic> json) {
    // TODO: implement convertArray
    throw UnimplementedError();
  }
}
