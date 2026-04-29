import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/checkin.dart';

class CheckinController {
  final DBHelper _dbHelper = DBHelper();

  // INSERT CHECKIN
  Future<void> insertCheckin(Checkin checkin) async {
    final db = await _dbHelper.database;
    await db.insert('checkin', checkin.toMap());
  }

  // CEK SUDAH CHECKIN HARI INI BELUM
  Future<bool> isCheckedInToday(int userId) async {
    final db = await _dbHelper.database;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final result = await db.rawQuery(
      '''
      SELECT * FROM checkin
      WHERE user_id = ?
      AND substr(datetime, 1, 10) = ?
      ''',
      [userId, today],
    );

    return result.isNotEmpty;
  }

  // AMBIL 7 HARI TERAKHIR
  Future<List<bool>> getWeeklyStatus(int userId) async {
    final db = await _dbHelper.database;

    // Pastikan kita mulai dari jam 00:00:00 di hari Senin
    DateTime now = DateTime.now();
    DateTime monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final start = monday.toIso8601String();
    final end = monday.add(const Duration(days: 7)).toIso8601String();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
    SELECT datetime FROM checkin 
    WHERE user_id = ? 
    AND datetime >= ? 
    AND datetime < ?
    ''',
      [userId, start, end],
    );

    List<bool> weekly = List.generate(7, (_) => false);

    for (var row in result) {
      final dateValue = row['datetime'];
      if (dateValue != null) {
        DateTime date = DateTime.parse(dateValue.toString());
        int index = date.weekday - 1;

        if (index >= 0 && index < 7) {
          weekly[index] = true;
        }
      }
    }

    return weekly;
  }

  Future<List<Map<String, dynamic>>> getCheckinByDate(
    int userId,
    String date,
  ) async {
    final db = await _dbHelper.database;

    return await db.query(
      'checkin',
      where: 'user_id = ? AND substr(datetime,1,10) = ?',
      whereArgs: [userId, date],
    );
  }

  Future<List<String>> getAllCheckinDates(int userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT datetime FROM checkin WHERE user_id = ?',
      [userId],
    );

    return result
        .map((e) => e['datetime'].toString().substring(0, 10))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getWeeklyResult(int userId) async {
    final db = await _dbHelper.database;

    return await db.query(
      'checkin',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'datetime DESC',
      limit: 7,
    );
  }
}
