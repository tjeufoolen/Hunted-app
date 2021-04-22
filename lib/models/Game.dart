import 'package:hunted_app/models/GameLocation.dart';
import 'dart:convert' as convert;

class Game {
  final int id;
  final DateTime startAt;
  final int minutes;
  final List<GameLocation> gameLocations;

  Game({this.id, this.startAt, this.minutes, this.gameLocations});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        id: json['id'],
        startAt: DateTime.parse(json['startAt']),
        minutes: json['minutes'],
        gameLocations: (convert.json.decode(json['gameLocations']))
            .map((i) => GameLocation.fromJson(i))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startAt': startAt.toIso8601String(),
        'minutes': minutes,
        'gameLocations': convert.json
            .encode(List<dynamic>.from(gameLocations.map((i) => i.toJson())))
      };
}
