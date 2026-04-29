import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/kalistenik.dart';

class KalistenikController {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Kalistenik>> getAll() async {
    final db = await _dbHelper.database;
    final res = await db.query('kalistenik');
    return res.map((e) => Kalistenik.fromMap(e)).toList();
  }
}
