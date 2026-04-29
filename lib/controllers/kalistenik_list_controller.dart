import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/kalistenik_list.dart';

class KalistenikListController {
  final DBHelper _dbHelper = DBHelper();

  Future<List<KalistenikList>> getByLevel(int levelId) async {
    final db = await _dbHelper.database;

    final res = await db.query(
      'kalistenik_list',
      where: 'level_id = ?',
      whereArgs: [levelId],
    );

    return res.map((e) => KalistenikList.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getKalistenikByLevel(int levelId) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
    SELECT k.*, kl.set_count
    FROM kalistenik k
    JOIN kalistenik_list kl ON k.kalistenik_id = kl.kalistenik_id
    WHERE kl.level_id = ?
  ''',
      [levelId],
    );
  }
}
