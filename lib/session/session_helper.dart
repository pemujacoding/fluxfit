import 'package:shared_preferences/shared_preferences.dart';

class SessionHelper {
  static const String userIdKey = 'user_id';

  // 🔥 simpan session
  static Future<void> saveUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userIdKey, userId);
  }

  // 🔥 ambil session
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  // 🔥 logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
  }
}
