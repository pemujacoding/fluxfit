import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/jadwal.dart';

class JadwalController {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(Jadwal data) async {
    final db = await _dbHelper.database;
    return db.insert('jadwal', data.toMap());
  }

  Future<List<Jadwal>> getAllbyUser(int userId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'jadwal',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map((e) => Jadwal.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('jadwal', where: 'jadwal_id = ?', whereArgs: [id]);
  }

  Future<int> updateJadwaltName(String newName, int jadwalId) async {
    final db = await _dbHelper.database;

    return await db.update(
      'jadwal',
      {'nama': newName},
      where: 'jadwal_id = ?',
      whereArgs: [jadwalId],
    );
  }
}
