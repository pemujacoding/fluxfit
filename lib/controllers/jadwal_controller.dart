import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/jadwal.dart';

class JadwalController {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(Jadwal data) async {
    final db = await _dbHelper.database;
    return db.insert('jadwal', data.toMap());
  }

  Future<List<Jadwal>> getAll() async {
    final db = await _dbHelper.database;
    final res = await db.query('jadwal');
    return res.map((e) => Jadwal.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('jadwal', where: 'jadwal_id = ?', whereArgs: [id]);
  }
}
