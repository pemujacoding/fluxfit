// models/game_item.dart

enum ItemType { energyGel, runningShoes }

class GameItem {
  double x;
  double y;
  final ItemType type;
  bool collected;

  static const double size = 60;

  // Durasi efek dalam detik
  static const double doubleScoreDuration = 8.0; // double score 
  static const double runningShoesDuration = 0; // shield, sekali pakai

  GameItem({
    required this.x,
    required this.y,
    required this.type,
    this.collected = false,
  });

  String get label {
    switch (type) {
      case ItemType.energyGel:
        return 'Energy Gel';
      case ItemType.runningShoes:
        return 'Running Shoes';
    }
  }

  // Nanti swap ke:
  // energyGel   → Sprite.load('assets/images/game/items/energy_gel.png')
  // runningShoes → Sprite.load('assets/images/game/items/running_shoes.png')
}
