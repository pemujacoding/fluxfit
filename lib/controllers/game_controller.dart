import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/game.dart';

class GameController {
  final DBHelper _dbHelper = DBHelper();

  Future<Game?> getByUser(int userId) async {
    final db = await _dbHelper.database;

    final res = await db.query(
      'game',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (res.isNotEmpty) {
      return Game.fromMap(res.first);
    }
    return null;
  }

  Future<int> updateScore(int userId, int score) async {
    final db = await _dbHelper.database;

    return db.rawUpdate(
      '''
      UPDATE game
      SET highest_skor = MAX(highest_skor, ?)
      WHERE user_id = ?
    ''',
      [score, userId],
    );
  }
}
