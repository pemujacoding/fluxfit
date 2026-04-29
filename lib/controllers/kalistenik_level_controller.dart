import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/kalistenik_level.dart';

class KalistenikLevelController {
  final DBHelper _dbHelper = DBHelper();

  Future<List<KalistenikLevel>> getAll() async {
    final db = await _dbHelper.database;
    final res = await db.query('kalistenik_level');
    return res.map((e) => KalistenikLevel.fromMap(e)).toList();
  }
}