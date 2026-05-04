import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/alat.dart';

class AlatController {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Alat>> getAll() async {
    final db = await _dbHelper.database;
    final res = await db.query('alat');
    return res.map((e) => Alat.fromMap(e)).toList();
  }

  Future<void> deleteBudget(int budgetId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // 🔥 Hapus semua item di budget_list dulu
      await txn.delete(
        'budget_list',
        where: 'budget_id = ?',
        whereArgs: [budgetId],
      );

      // 🔥 Baru hapus budget
      await txn.delete('budget', where: 'budget_id = ?', whereArgs: [budgetId]);
    });
  }
}
