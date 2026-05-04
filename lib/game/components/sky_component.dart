// game/components/sky_component.dart

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';

class _Star {
  double x, y, radius, opacity;
  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}

class _Cloud {
  double x, y, speed, scale;
  _Cloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.scale,
  });
}

class _Bird {
  double x, y, speed, baseY, bounceOffset;
  _Bird({
    required this.x,
    required this.y,
    required this.speed,
    required this.baseY,
    this.bounceOffset = 0,
  });
}

class SkyComponent extends PositionComponent with HasGameRef {
  final GameController controller;
  final Random _random = Random();

  final List<_Star> _stars = [];
  final List<_Cloud> _clouds = [];
  final List<_Bird> _birds = [];

  double _cloudSpawn = 0;
  double _birdSpawn = 0;
  double _timer = 0;

  // Sky cycle: pagi → siang → sore → malam → loop

  static const double _cycleDuration = 40;

  static const List<Color> _skyColors = [
    Color(0xFFB8E0FF), // pagi — biru muda
    Color(0xFF87CEEB), // siang — biru cerah
    Color(0xFFFF9966), // sore — oranye
    Color(0xFF1A1A3E), // malam — biru gelap
  ];

  SkyComponent({required this.controller});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Spawn awan awal biar langsung ada
    for (int i = 0; i < 4; i++) {
      _spawnCloud(initialX: _random.nextDouble() * 800);
    }

    _generateStars();
  }

  @override
  void update(double dt) {
    _timer += dt;

    // Update awan
    _cloudSpawn -= dt;
    if (_cloudSpawn <= 0) {
      _spawnCloud();
      _cloudSpawn = 3.0 + _random.nextDouble() * 3.0;
    }
    for (final c in _clouds) {
      c.x -= c.speed * dt;
    }
    _clouds.removeWhere((c) => c.x < -200);

    // Update burung
    _birdSpawn -= dt;
    if (_birdSpawn <= 0) {
      _spawnBird();
      _birdSpawn = 5.0 + _random.nextDouble() * 6.0;
    }
    for (final b in _birds) {
      b.x -= b.speed * dt;
      b.bounceOffset += dt * 2.5;
      b.y = b.baseY + sin(b.bounceOffset) * 10;
    }
    _birds.removeWhere((b) => b.x < -100);

    // ini bintang pas malem
    for (final s in _stars) {
      s.opacity += (_random.nextDouble() - 0.5) * 0.02;
      s.opacity = s.opacity.clamp(0.3, 1.0);
    }
  }

  void _generateStars() {
    final screenW = gameRef.size.x;
    final screenH = gameRef.size.y;

    for (int i = 0; i < 50; i++) {
      _stars.add(
        _Star(
          x: _random.nextDouble() * screenW,
          y: _random.nextDouble() * screenH * 0.6,
          radius: 1 + _random.nextDouble() * 1.5,
          opacity: 0.5 + _random.nextDouble() * 0.5,
        ),
      );
    }
  }

  void _spawnCloud({double? initialX}) {
    final screenW = gameRef.size.x;
    final screenH = gameRef.size.y;
    _clouds.add(
      _Cloud(
        x: initialX ?? screenW + 50,
        y: screenH * 0.05 + _random.nextDouble() * screenH * 0.25,
        speed: 20 + _random.nextDouble() * 20,
        scale: 0.6 + _random.nextDouble() * 0.8,
      ),
    );
  }

  void _spawnBird({double? initialX}) {
    final screenW = gameRef.size.x;
    final screenH = gameRef.size.y;
    final baseY = screenH * 0.05 + _random.nextDouble() * screenH * 0.2;
    _birds.add(
      _Bird(
        x: initialX ?? screenW + 50,
        y: baseY,
        baseY: baseY,
        speed: 60 + _random.nextDouble() * 40,
        bounceOffset: _random.nextDouble() * pi * 2,
      ),
    );
  }

  Color get _currentSkyColor {
    final progress = (_timer % _cycleDuration) / _cycleDuration;
    final totalPhases = _skyColors.length;
    final phaseProgress = progress * totalPhases;
    final phaseIndex = phaseProgress.floor() % totalPhases;
    final nextIndex = (phaseIndex + 1) % totalPhases;
    final t = phaseProgress - phaseProgress.floor();
    return Color.lerp(_skyColors[phaseIndex], _skyColors[nextIndex], t)!;
  }

  bool get _isNight {
    final progress = (_timer % _cycleDuration) / _cycleDuration;
    return progress > 0.75;
  }

  @override
  void render(Canvas canvas) {
    final screenW = gameRef.size.x;
    final screenH = gameRef.size.y;
    final groundY = screenH * 0.80;
    final skyColor = _currentSkyColor;

    // Langit
    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenW, groundY),
      Paint()..color = skyColor,
    );

    // Bintang saat malam
    if (_isNight) {
      for (final s in _stars) {
        final paint = Paint()..color = Colors.white.withOpacity(s.opacity);

        canvas.drawCircle(Offset(s.x, s.y), s.radius, paint);
      }
    }

    // Awan
    final cloudColor = _isNight
        ? Colors.blueGrey.withOpacity(0.4)
        : Colors.white.withOpacity(0.85);
    for (final c in _clouds) {
      _drawCloud(canvas, c.x, c.y, c.scale, cloudColor);
    }

    // Burung
    final birdColor = _isNight ? Colors.white.withOpacity(0.6) : Colors.black87;
    for (final b in _birds) {
      _drawBird(canvas, b.x, b.y, birdColor);
    }
  }

  void _drawCloud(
    Canvas canvas,
    double x,
    double y,
    double scale,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final s = scale * 30;
    canvas.drawCircle(Offset(x, y), s, paint);
    canvas.drawCircle(Offset(x + s * 1.1, y + s * 0.2), s * 0.8, paint);
    canvas.drawCircle(Offset(x - s * 1.0, y + s * 0.2), s * 0.7, paint);
    canvas.drawCircle(Offset(x + s * 0.4, y - s * 0.5), s * 0.75, paint);
  }

  void _drawBird(Canvas canvas, double x, double y, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Dua sayap melengkung — bentuk M kecil
    final path = Path()
      ..moveTo(x - 12, y)
      ..quadraticBezierTo(x - 6, y - 8, x, y)
      ..quadraticBezierTo(x + 6, y - 8, x + 12, y);

    canvas.drawPath(path, paint);
  }
}
