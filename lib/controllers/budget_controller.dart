import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/budget.dart';
import 'package:fluxfit/models/budget_list.dart';

class BudgetController {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getBudgetDetailed(int budgetId) async {
    final db = await _dbHelper.database;

    return await db.rawQuery(
      '''
    SELECT bl.jumlah, a.*
    FROM budget_list bl
    JOIN alat a ON a.alat_id = bl.alat_id
    WHERE bl.budget_id = ?
    ''',
      [budgetId],
    );
  }

  Future<List<Budget>> getBudgetUser(int userId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'budget',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'datetime DESC',
    );

    return result.map((e) => Budget.fromMap(e)).toList();
  }

  Future<int> insertBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.insert('budget', budget.toMap());
  }

  Future<int> insertBudgetList(BudgetList budgetList) async {
    final db = await _dbHelper.database;
    return await db.insert('budget_list', budgetList.toMap());
  }

  Future<int> getTotalBudget(int budgetId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
    SELECT SUM(a.harga * bl.jumlah) as total
    FROM budget_list bl
    JOIN alat a ON a.alat_id = bl.alat_id
    WHERE bl.budget_id = ?
    ''',
      [budgetId],
    );

    return result.first['total'] as int? ?? 0;
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

  Future<int> updateBudgetName(String newName, int budgetId) async {
    final db = await _dbHelper.database;

    return await db.update(
      'budget',
      {'nama': newName},
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
  }
}
