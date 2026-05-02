// game/components/item_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_item.dart';
import 'dart:math';

class ItemComponent extends PositionComponent {
  final GameItem item;
  double _bounceTimer = 0;

  ItemComponent({required this.item})
    : super(
        position: Vector2(item.x, item.y),
        size: Vector2(GameItem.size, GameItem.size),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final emoji = item.type == ItemType.energyGel ? '🔋' : '👟';

    add(
      TextComponent(
        text: emoji,
        textRenderer: TextPaint(style: const TextStyle(fontSize: 36)),
      ),
    );
  }

  @override
  void update(double dt) {
    position.x = item.x;

    // Efek bounce naik turun
    _bounceTimer += dt;
    position.y = item.y + (4 * sin(_bounceTimer * 3));

    if (item.collected || item.x < -size.x) removeFromParent();
  }
}
