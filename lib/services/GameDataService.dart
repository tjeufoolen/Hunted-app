import 'dart:convert';

import 'package:hunted_app/models/game.dart';
import 'package:hunted_app/services/dataservice.dart';

class GameDataService extends DataService<Game> {
  GameDataService() : super(genericEndpoint: '');

  Future<Game> joinGame(String code) async {
    return executeRequest(endpoint: "/join/$code")
        .then((value) => convert(json.decode(value)));
  }

  @override
  convert(Map<String, dynamic> json) => Game.fromJson(json);

  @override
  convertArray(Map<String, dynamic> json) {
    // TODO: implement convertArray
    throw UnimplementedError();
  }
}
