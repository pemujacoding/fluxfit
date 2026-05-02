import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/models/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

class UserController {
  final DBHelper _dbHelper = DBHelper();

  // ENCRYPT
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // SAFE INSERT (Gunakan ini di UI)
  Future<String?> insertUserSafe(User user) async {
    final db = await _dbHelper.database;

    try {
      // Buat map baru agar kita tidak mengubah objek user asli
      Map<String, dynamic> userMap = user.toMap();

      // WAJIB: Hash password sebelum simpan
      userMap['password'] = hashPassword(user.password);

      await db.insert('users', userMap);
      return null;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return "USERNAME_EXISTS";
      }
      return "DB_ERROR";
    }
  }

  // LOGIN (Harus di-hash juga untuk membandingkan)
  Future<User?> checkAccount(String username, String password) async {
    final db = await _dbHelper.database;

    // Hash password inputan user untuk dicocokkan dengan hasil hash di DB
    final hashedPassword = hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Perbaikan pada Method READ/UPDATE/DELETE (Pastikan nama kolom benar)
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'user_id = ?', // Gunakan user_id sesuai model
      whereArgs: [id],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?', // Gunakan user_id sesuai model
      whereArgs: [user.userId],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('users', where: 'user_id = ?', whereArgs: [id]);
  }

  // update password lwt profile page
  Future<int> updatePasswordSafe(String username, String newPassword) async {
    // WAJIB: Hash dulu sebelum dikirim ke database
    final hashedPassword = hashPassword(newPassword);

    // Panggil helper untuk update
    return await _dbHelper.updatePassword(username, hashedPassword);
  }
}
