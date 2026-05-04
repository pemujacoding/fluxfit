// controllers/game_controller.dart

import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../models/runner.dart';
import '../models/obstacle.dart';
import '../models/game_item.dart';
import '../models/game_state.dart';
import '../game/flux_run_game.dart';
import '../game/components/obstacle_component.dart';
import '../game/components/item_component.dart';
import 'package:fluxfit/controllers/game_score_controller.dart';
import 'package:fluxfit/session/session_helper.dart';

class GameController extends ChangeNotifier {
  final GameState gameState = GameState();
  late Runner runner;
  final Random _random = Random();
  final GameScoreController _scoreController = GameScoreController();

  double _obsCooldown = 0;
  double _itemCooldown = 0;
  static const double _obsInterval = 1.8;
  static const double _itemInterval = 4.0;

  double groundY = 0;

  static const double _gravity = 800;
  static const double _jumpForce = -500;
  static const int _maxJumps = 2;
  int _jumpCount = 0;

  GameController() {
    _initRunner();
    _loadHighestScore();
  }

  void _initRunner() {
    runner = Runner(y: 0);
  }

  Future<void> _loadHighestScore() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;
    final game = await _scoreController.getByUser(userId);
    if (game != null) {
      gameState.highestScore = game.highestSkor;
      notifyListeners();
    }
  }

  // ─── GAME LOOP ─────────────────────────────────────────────

  void update(double dt, Vector2 screenSize, FluxRunGame game) {
    if (gameState.status != GameStatus.running) return;

    groundY = screenSize.y * 0.80;

    if (runner.y == 0) {
      runner.y = groundY - Runner.height;
    }

    _updateScore(dt);
    _updateSpeed(dt);
    _updateRunner(dt);
    _spawnObstacles(dt, screenSize, game);
    _spawnItems(dt, screenSize, game);

    // Geser semua obstacle ke kiri
    for (final comp in game.children.whereType<ObstacleComponent>()) {
      comp.obstacle.x -= gameState.speed * dt;
    }

    // Geser semua item ke kiri
    for (final comp in game.children.whereType<ItemComponent>()) {
      comp.item.x -= gameState.speed * dt;
    }

    _checkCollisions(game);

    notifyListeners();
  }

  void _updateScore(double dt) {
    final multiplier = gameState.isDoubleScore ? 2 : 1;
    gameState.score += (gameState.speed * dt * 0.05 * multiplier).round();
  }

  void _updateSpeed(double dt) {
    gameState.speed = min(
      GameState.maxSpeed,
      GameState.baseSpeed + gameState.score * 0.4,
    );

    if (gameState.isDoubleScore) {
      gameState.doubleScoreTimer -= dt;
      if (gameState.doubleScoreTimer <= 0) {
        gameState.isDoubleScore = false;
      }
    }
  }

  void _updateRunner(double dt) {
    runner.velocityY += _gravity * dt;
    runner.y += runner.velocityY * dt;

    final groundLimit = groundY - Runner.height;
    if (runner.y >= groundLimit) {
      runner.y = groundLimit;
      runner.velocityY = 0;
      runner.state = RunnerState.running;
      _jumpCount = 0;
    }
  }

  void _spawnObstacles(double dt, Vector2 screenSize, FluxRunGame game) {
    _obsCooldown -= dt;
    if (_obsCooldown <= 0) {
      final type = _random.nextBool() ? ObstacleType.short : ObstacleType.tall;
      final obs = Obstacle(
        x: screenSize.x + 10,
        y: groundY - (type == ObstacleType.tall ? 60 : 35),
        type: type,
      );
      game.addObstacle(ObstacleComponent(obstacle: obs));
      _obsCooldown = max(0.8, _obsInterval - gameState.score * 0.001);
    }
  }

  void _spawnItems(double dt, Vector2 screenSize, FluxRunGame game) {
    _itemCooldown -= dt;
    if (_itemCooldown <= 0) {
      final type = _random.nextBool()
          ? ItemType.energyGel
          : ItemType.runningShoes;
      final item = GameItem(
        x: screenSize.x + 10,
        y: groundY - Runner.height - 40 - _random.nextDouble() * 60,
        type: type,
      );
      game.addItem(ItemComponent(item: item));
      _itemCooldown = _itemInterval;
    }
  }

  void _checkCollisions(FluxRunGame game) {
    final runnerRect = Rect.fromLTWH(
      Runner.posX + 4,
      runner.y + 4,
      Runner.width - 8,
      Runner.height - 8,
    );

    for (final comp in game.children.whereType<ObstacleComponent>()) {
      final obsRect = Rect.fromLTWH(
        comp.obstacle.x,
        comp.obstacle.y,
        comp.obstacle.width,
        comp.obstacle.height,
      );
      if (runnerRect.overlaps(obsRect)) {
        if (gameState.hasShield) {
          gameState.hasShield = false;
          runner.hasShield = false;
          comp.removeFromParent();
        } else {
          _onDead();
          return;
        }
      }
    }

    for (final comp in game.children.whereType<ItemComponent>()) {
      if (comp.item.collected) continue;
      final itemRect = Rect.fromLTWH(
        comp.item.x,
        comp.item.y,
        GameItem.size,
        GameItem.size,
      );
      if (runnerRect.overlaps(itemRect)) {
        _collectItem(comp.item);
      }
    }
  }

  void _collectItem(GameItem item) {
    item.collected = true;
    switch (item.type) {
      case ItemType.energyGel:
        gameState.isDoubleScore = true;
        gameState.doubleScoreTimer = GameItem.doubleScoreDuration;
        break;
      case ItemType.runningShoes:
        gameState.hasShield = true;
        runner.hasShield = true;
        break;
    }
    notifyListeners();
  }

  Future<void> _onDead() async {
    gameState.status = GameStatus.dead;
    runner.state = RunnerState.dead;
    final userId = await SessionHelper.getUserId();
    if (userId != null) {
      await _scoreController.updateScore(userId, gameState.score);
      await _loadHighestScore();
    }
    notifyListeners();
  }

  Future<void> saveScoreIfRunning() async {
    if (gameState.status != GameStatus.running &&
        gameState.status != GameStatus.paused) {
      return;
    }

    final userId = await SessionHelper.getUserId();
    if (userId != null) {
      await _scoreController.updateScore(userId, gameState.score);
      await _loadHighestScore();
    }
  }
  // ─── INPUT ─────────────────────────────────────────────────

  void onTap() {
    switch (gameState.status) {
      case GameStatus.idle:
      case GameStatus.dead:
        startGame();
        break;
      case GameStatus.running:
        _doJump();
        break;
      case GameStatus.paused:
        resumeGame();
        break;
    }
  }

  void _doJump() {
    if (_jumpCount < _maxJumps) {
      runner.velocityY = _jumpForce;
      runner.state = RunnerState.jumping;
      _jumpCount++;
    }
  }

  // ─── GAME STATE CONTROL ────────────────────────────────────

  void startGame() {
    gameState.reset();
    _initRunner();
    runner.y = groundY - Runner.height;
    _obsCooldown = _obsInterval;
    _itemCooldown = _itemInterval;
    _jumpCount = 0;
    notifyListeners();
  }

  void pauseGame() {
    gameState.status = GameStatus.paused;
    notifyListeners();
  }

  void resumeGame() {
    gameState.status = GameStatus.running;
    notifyListeners();
  }
}
