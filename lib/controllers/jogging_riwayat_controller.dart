import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/jogging_riwayat.dart';

class JoggingRiwayatController {
  final DBHelper _dbHelper = DBHelper();

  // 🔥 CREATE
  Future<int> insertJogging(JoggingRiwayat jogging) async {
    final db = await _dbHelper.database;
    return await db.insert('jogging_riwayat', jogging.toMap());
  }

  // 🔥 READ ALL (by user)
  Future<List<JoggingRiwayat>> getJoggingByUser(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'jogging_riwayat',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'datetime_start DESC', // ✅ Sesuaikan nama kolom
    );
    return result.map((e) => JoggingRiwayat.fromMap(e)).toList();
  }

  // 🔥 READ BY DATE (untuk Calendar)
  Future<List<Map<String, dynamic>>> getJoggingByDate(
    int userId,
    String date,
  ) async {
    final db = await _dbHelper.database;
    return await db.query(
      'jogging_riwayat',
      // substr(datetimeStart, 1, 10) akan mengambil 'YYYY-MM-DD'
      where: 'user_id = ? AND substr(datetime_start, 1, 10) = ?',
      whereArgs: [userId, date],
      orderBy: 'datetime_start DESC',
    );
  }

  // 🔥 UPDATE
  Future<int> updateJogging(JoggingRiwayat jogging) async {
    final db = await _dbHelper.database;

    return await db.update(
      'jogging_riwayat',
      jogging.toMap(),
      where: 'jogging_id = ?',
      whereArgs: [jogging.joggingId],
    );
  }

  // 🔥 DELETE
  Future<int> deleteJogging(int id) async {
    final db = await _dbHelper.database;

    return await db.delete(
      'jogging_riwayat',
      where: 'jogging_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getLast3Sessions(int userId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'jogging_riwayat',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'datetime_start DESC',
      limit: 3,
    );
  }
}
