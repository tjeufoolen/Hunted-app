import 'package:hunted_app/models/GameLocation.dart';

class Game {
  final int id;
  final DateTime startAt;
  final bool isStarted;
  final int minutes;
  final List<GameLocation> gameLocations;

  Game({
    this.id,
    this.startAt,
    this.isStarted,
    this.minutes,
    this.gameLocations,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        id: json['id'],
        startAt: DateTime.parse(json['startAt']),
        isStarted: json['isStarted'],
        minutes: json['minutes'],
        gameLocations: List<GameLocation>.from(json["gameLocations"]
            .toList()
            .map((data) => GameLocation.fromJson(data))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startAt': startAt.toIso8601String(),
        'isStarted': isStarted,
        'minutes': minutes,
        'gameLocations': gameLocations.map((obj) => obj.toJson()).toList()
      };
}
