import 'package:hunted_app/models/GameLocation.dart';

class Game {
  final int id;
  final DateTime startAt;
  final int minutes;
  final List<GameLocation> gameLocations;
  final num gameAreaLatitude;
  final num gameAreaLongitude;
  final num gameAreaRadius;

  Game(
      {this.id,
      this.startAt,
      this.minutes,
      this.gameLocations,
      this.gameAreaLatitude,
      this.gameAreaLongitude,
      this.gameAreaRadius});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        id: json['id'],
        startAt: DateTime.parse(json['startAt']),
        minutes: json['minutes'],
        gameAreaLatitude: json['gameAreaLatitude'],
        gameAreaLongitude: json['gameAreaLongitude'],
        gameAreaRadius: json['gameAreaRadius'],
        gameLocations: List<GameLocation>.from(json["gameLocations"]
            .toList()
            .map((data) => GameLocation.fromJson(data))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startAt': startAt.toIso8601String(),
        'minutes': minutes,
        'gameAreaLatitude': gameAreaLatitude,
        'gameAreaLongitude': gameAreaLongitude,
        'gameAreaRadius': gameAreaRadius,
        'gameLocations': gameLocations.map((obj) => obj.toJson()).toList()
      };
}
