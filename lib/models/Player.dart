import 'package:hunted_app/models/Location.dart';
import 'Game.dart';

class Player {
  final int id;
  final Game game;
  final String code;
  final int playerRole;
  final bool outOfTheGame;
  Location location;

  Player(
      {this.id,
      this.game,
      this.code,
      this.playerRole,
      this.outOfTheGame,
      this.location});

  Player.withoutLocation(
      {this.id, this.game, this.code, this.playerRole, this.outOfTheGame});

  factory Player.fromJson(Map<String, dynamic> json) {
    print(json);

    return Player(
        id: json['id'],
        game: Game.fromJson(json['game']),
        code: json['code'],
        playerRole: json['playerRole'],
        outOfTheGame: json['outOfTheGame'],
        location: Location.fromJson(json['location']));
  }
}
