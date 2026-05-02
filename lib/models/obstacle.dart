// models/obstacle.dart

enum ObstacleType { short, tall }

class Obstacle {
  double x;
  double y;
  final ObstacleType type;

  // Ukuran hitbox berdasarkan tipe
  double get width => 70;
  double get height => type == ObstacleType.tall ? 120 : 70;

  Obstacle({required this.x, required this.y, required this.type});

  // Nanti swap ke: Sprite.load('assets/images/game/obstacles/obstacle_short.png')
  //               Sprite.load('assets/images/game/obstacles/obstacle_tall.png')
}
