// game/flux_run_game.dart

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:fluxfit/game/components/sky_component.dart';
import '../models/game_state.dart';
import '../controllers/game_controller.dart';
import 'components/runner_component.dart';
import 'components/obstacle_component.dart';
import 'components/item_component.dart';
import 'components/ground_component.dart';

class FluxRunGame extends FlameGame with TapDetector {
  final GameController controller;
  late RunnerComponent runnerComponent;

  FluxRunGame({required this.controller});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ground
    add(GroundComponent());

    // sky
    add(SkyComponent(controller: controller));

    // Runner
    runnerComponent = RunnerComponent(controller: controller);
    add(runnerComponent);

    // Spawn loop obstacle & item dihandle di controller via update()
  }

  @override
  void update(double dt) {
    super.update(dt);
    controller.update(dt, size, this);
  }

  @override
  void onTap() {
    // Hanya handle tap kalau status running
    // Kalau dead/idle, biarkan Flutter overlay yang handle
    if (controller.gameState.status == GameStatus.running) {
      controller.onTap();
    }
  }

  @override
  Color backgroundColor() => const Color(0xFFEAF3DE); // hijau muda/cerah

  // Dipanggil controller saat spawn obstacle baru
  void addObstacle(ObstacleComponent obstacle) => add(obstacle);

  // Dipanggil controller saat spawn item baru
  void addItem(ItemComponent item) => add(item);
}
