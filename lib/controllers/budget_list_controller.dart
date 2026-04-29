import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/budget_list.dart';

class BudgetListController {
  final DBHelper _dbHelper = DBHelper();

  Future<List<BudgetList>> getByLevel(int budgetId) async {
    final db = await _dbHelper.database;

    final res = await db.query(
      'budget_list',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );

    return res.map((e) => BudgetList.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getKalistenikByLevel(int budgetId) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
    SELECT b.*, bl.jumlah
    FROM budget b
    JOIN budget_list bl ON b.kalistenik_id = bl.kalistenik_id
    WHERE bl.budget_id = ?
  ''',
      [budgetId],
    );
  }
}
