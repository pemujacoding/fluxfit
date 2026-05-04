// pages/game_page.dart

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/game_controller.dart';
import 'package:fluxfit/game/components/item_component.dart';
import 'package:fluxfit/game/components/obstacle_component.dart';
import 'package:fluxfit/game/flux_run_game.dart';
import 'package:fluxfit/models/game_state.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final GameController _controller;
  late final FluxRunGame _game;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _game = FluxRunGame(controller: _controller);
    _controller.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) setState(() {});
  }

  Future<bool> _onWillPop() async {
    // langsung keluar kalau belum main / sudah mati
    if (_controller.gameState.status == GameStatus.idle ||
        _controller.gameState.status == GameStatus.dead) {
      return true;
    }

    _controller.pauseGame(); // pause dulu biar ga jalan di belakang

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Keluar Game?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Progress kamu akan hilang. Yakin mau keluar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'BATAL',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('KELUAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await _controller.saveScoreIfRunning(); // 🔥 penting!
      return true;
    } else {
      _controller.resumeGame(); // lanjut lagi kalau batal
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Flux Run'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            if (_controller.gameState.status == GameStatus.running)
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _controller.pauseGame,
              ),
          ],
        ),
        body: Stack(
          children: [
            // Flame game canvas
            GameWidget(game: _game),

            // HUD — score & highest score
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHudChip(
                    icon: Icons.straighten,
                    label: '${_controller.gameState.score}m',
                  ),
                  _buildHudChip(
                    icon: Icons.emoji_events,
                    label: '${_controller.gameState.highestScore}m',
                    color: Colors.amber,
                  ),
                ],
              ),
            ),

            // HUD — efek aktif (speed boost & shield)
            Positioned(
              top: 52,
              left: 16,
              child: Row(
                children: [
                  if (_controller.gameState.isDoubleScore)
                    _buildEffectChip(
                      icon: Icons.flash_on,
                      label:
                          '${_controller.gameState.doubleScoreTimer.toStringAsFixed(1)}s',
                      color: Colors.amber,
                    ),
                  if (_controller.gameState.hasShield) ...[
                    const SizedBox(width: 8),
                    _buildEffectChip(
                      icon: Icons.shield,
                      label: 'Shield',
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ),

            // Overlay: idle
            if (_controller.gameState.status == GameStatus.idle)
              _buildOverlay(
                title: 'Flux Run',
                subtitle: 'Tap untuk mulai!',
                buttonLabel: 'MULAI',
                onPressed: _controller.startGame,
              ),

            // Overlay: paused
            if (_controller.gameState.status == GameStatus.paused)
              _buildPauseOverlay(),

            // Overlay: dead
            if (_controller.gameState.status == GameStatus.dead)
              _buildOverlay(
                title: 'Game Over!',
                subtitle:
                    'Jarak: ${_controller.gameState.score}m\nRekor: ${_controller.gameState.highestScore}m',
                buttonLabel: 'MAIN LAGI',
                onPressed: () {
                  // Hapus semua obstacle & item lama sebelum restart
                  _game.children
                      .whereType<ObstacleComponent>()
                      .toList()
                      .forEach((c) => c.removeFromParent());
                  _game.children.whereType<ItemComponent>().toList().forEach(
                    (c) => c.removeFromParent(),
                  );
                  _controller.startGame();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudChip({
    required IconData icon,
    required String label,
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Paused',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.resumeGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LANJUT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await _controller.saveScoreIfRunning();
                    if (mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'BERHENTI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
