// game/components/obstacle_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/obstacle.dart';

class ObstacleComponent extends PositionComponent {
  final Obstacle obstacle;

  ObstacleComponent({required this.obstacle})
    : super(
        position: Vector2(obstacle.x, obstacle.y),
        size: Vector2(obstacle.width, obstacle.height),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final emoji = obstacle.type == ObstacleType.tall ? '🚧' : '🪨';
    final fontSize = obstacle.type == ObstacleType.tall ? 52.0 : 40.0;

    add(
      TextComponent(
        text: emoji,
        textRenderer: TextPaint(style: TextStyle(fontSize: fontSize)),
      ),
    );
  }

  @override
  void update(double dt) {
    position.x = obstacle.x;
    if (obstacle.x < -size.x) removeFromParent();
  }
}
