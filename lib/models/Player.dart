import 'Game.dart';

class Player {
  final int id;
  final Game game;
  final int playerRole;
  final bool outOfTheGame;
  // Location location;

  Player({
    this.id,
    this.game,
    this.playerRole,
    this.outOfTheGame,
  });

  Player.withoutLocation(
      {this.id, this.game, this.playerRole, this.outOfTheGame});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      game: Game.fromJson(json['game']),
      playerRole: json['playerRole'],
      outOfTheGame: json['outOfTheGame'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'game': game.toJson(),
        'playerRole': playerRole,
        'outOfTheGame': outOfTheGame,
      };
}
