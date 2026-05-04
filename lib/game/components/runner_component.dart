// game/components/runner_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/runner.dart';
import '../../controllers/game_controller.dart';

class RunnerComponent extends PositionComponent {
  final GameController controller;
  late TextComponent _emoji;
  late TextComponent _shieldEmoji;

  RunnerComponent({required this.controller})
    : super(
        position: Vector2(Runner.posX, 0),
        size: Vector2(Runner.width, Runner.height),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position.y = controller.groundY - Runner.height;

    _emoji = TextComponent(
      text: '🏃‍➡️',
      textRenderer: TextPaint(style: const TextStyle(fontSize: 48)),
    );
    add(_emoji);

    _shieldEmoji = TextComponent(
      text: '🛡️',
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24)),
      position: Vector2(Runner.width - 10, -10),
    );
  }

  @override
  void update(double dt) {
    position.y = controller.runner.y;

    if (controller.gameState.hasShield && !children.contains(_shieldEmoji)) {
      add(_shieldEmoji);
    } else if (!controller.gameState.hasShield &&
        children.contains(_shieldEmoji)) {
      _shieldEmoji.removeFromParent();
    }
  }
}
