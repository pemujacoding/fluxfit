class Game {
  final int userId;
  final int highestSkor;

  Game({required this.userId, required this.highestSkor});

  Map<String, dynamic> toMap() {
    return {'user_id': userId, 'highest_skor': highestSkor};
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(userId: map['user_id'], highestSkor: map['highest_skor']);
  }
}
