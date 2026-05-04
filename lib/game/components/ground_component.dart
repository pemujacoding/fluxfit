// game/components/ground_component.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GroundComponent extends PositionComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Posisi & ukuran di-set setelah game size tersedia
  }

  @override
  void render(Canvas canvas) {
    final screenSize = gameRef.size;
    final groundY = screenSize.y * 0.80;
    final groundHeight = screenSize.y - groundY;

    // ─── SWAP ASSET DI SINI ───────────────────────────────
    // Sekarang: flat color
    // Nanti: TiledComponent atau SpriteComponent repeating tile
    //   ground tile → 'assets/images/game/background/ground.png'
    // ─────────────────────────────────────────────────────

    // Ground fill
    final groundPaint = Paint()..color = const Color(0xFF639922);
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, screenSize.x, groundHeight),
      groundPaint,
    );

    // Ground line
    final linePaint = Paint()
      ..color = const Color(0xFF3B6D11)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, groundY),
      Offset(screenSize.x, groundY),
      linePaint,
    );
  }
}
