// models/runner.dart

enum RunnerState { running, jumping, dead }

class Runner {
  double y;
  double velocityY;
  bool hasShield;
  RunnerState state;

  // Ukuran hitbox runner
  static const double width = 40;
  static const double height = 60;

  // Posisi X runner selalu tetap (endless runner)
  static const double posX = 80;

  Runner({
    required this.y,
    this.velocityY = 0,
    this.hasShield = false,
    this.state = RunnerState.running,
  });

  // Nanti swap ke: Sprite.load('assets/images/game/runner/run_1.png')
}
