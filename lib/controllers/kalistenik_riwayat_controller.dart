import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/kalistenik_riwayat.dart';

class KalisteniRiwayatController {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertRiwayat(KalistenikRiwayat kalisternikRiwayat) async {
    final db = await _dbHelper.database;

    return await db.insert('kalistenik_riwayat', {
      'user_id': kalisternikRiwayat.userId,
      'level_id': kalisternikRiwayat.levelId,
      'datetime': kalisternikRiwayat.datetime,
      'progress': kalisternikRiwayat.progress,
    });
  }

  Future<List<Map<String, dynamic>>> getKalistenikByDate(
    int userId,
    String date,
  ) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
    SELECT kr.*, kl.nama as level_nama
    FROM kalistenik_riwayat kr
    JOIN kalistenik_level kl ON kr.level_id = kl.level_id
    WHERE kr.user_id = ?
    AND substr(kr.datetime, 1, 10) = ?
    ''',
      [userId, date],
    );
  }

Future<List<Map<String, dynamic>>> getLast3Sessions(int userId) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
    SELECT 
      kr.datetime,
      kr.progress,
      kl.nama AS level_nama
    FROM kalistenik_riwayat kr
    JOIN kalistenik_level kl ON kr.level_id = kl.level_id
    WHERE kr.user_id = ?
    ORDER BY kr.datetime DESC
    LIMIT 3
  ''',
      [userId],
    );
  }
  Future<void> delete(int id) async {
    final db = await _dbHelper.database;

    await db.delete(
      'kalistenik_riwayat',
      where: 'riwayat_id = ?',
      whereArgs: [id],
    );
  }
}
