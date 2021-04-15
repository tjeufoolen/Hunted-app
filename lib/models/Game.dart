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

// {
//   id: 1,
//   gameId: 3,
//   code: $2a$1-0$OPj-1ZwWu-3JYYE-nhHZZ-y02uv-vNET0-mrqw7-0u.O1-YdrFU-.v6fF-9VkxW,
//   playerRole: 0,
//   outOfTheGame: false,
//   locationId: null,
//   createdAt: 2021-04-15T10:44:04.000Z,
//   GameId: 3,
//   Game: {
//     id: 3,
//     userId: 1,
//     startAt: 2021-04-15T18:00:00.000Z,
//     minutes: 180,
//     layoutTemplateId: 0,
//     createdAt: 2021-04-15T10:44:04.000Z
//     }
// }
