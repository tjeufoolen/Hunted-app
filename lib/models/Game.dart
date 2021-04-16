class Game {
  final int id;
  final int userId;
  final DateTime startAt;
  final int minutes;

  Game({this.id, this.userId, this.startAt, this.minutes});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        id: json['id'],
        userId: json['userId'],
        startAt: DateTime.parse(json['startAt']),
        minutes: json['minutes']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'startAt': startAt.toIso8601String(),
        'minutes': minutes,
      };
}
