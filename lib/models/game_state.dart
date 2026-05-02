// models/game_state.dart

enum GameStatus { idle, running, paused, dead }

class GameState {
  GameStatus status;
  int score;
  int highestScore;
  double speed;
  bool isDoubleScore;
  double doubleScoreTimer;
  bool hasShield;

  static const double baseSpeed = 200; // pixel per detik
  static const double maxSpeed = 500;

  GameState({
    this.status = GameStatus.idle,
    this.score = 0,
    this.highestScore = 0,
    this.speed = baseSpeed,
    this.isDoubleScore = false,
    this.doubleScoreTimer = 0,
    this.hasShield = false,
  });

  void reset() {
    status = GameStatus.running;
    score = 0;
    speed = baseSpeed;
    isDoubleScore = false;
    doubleScoreTimer = 0;
    hasShield = false;
  }
}
