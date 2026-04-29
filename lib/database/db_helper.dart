import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'fluxfit.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      username UNIQUE TEXT NOT NULL,
      password TEXT NOT NULL,
      gender TEXT CHECK(gender IN ('male', 'female', 'unknown')),
      tanggal_lahir TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS checkin (
      checkin_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      datetime TEXT,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS jogging_riwayat (
      jogging_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      datetime TEXT NOT NULL,
      jarak REAL,
      langkah INTEGER,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kalistenik_level(
      level_id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kalistenik (
      kalistenik_id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT NOT NULL,
      deskripsi TEXT,
      gambar TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kalistenik_riwayat (
      riwayat_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      level_id INTEGER NOT NULL,
      datetime TEXT NOT NULL,
      progress REAL,
      FOREIGN KEY (user_id) REFERENCES users(user_id),
      FOREIGN KEY (level_id) REFERENCES kalistenik_level(level_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS kalistenik_list(
      list_id INTEGER PRIMARY KEY AUTOINCREMENT,
      level_id INTEGER NOT NULL,
      kalistenik_id INTEGER NOT NULL,
      set_count INTEGER,
      FOREIGN KEY (level_id) REFERENCES kalistenik_level(level_id),
      FOREIGN KEY (kalistenik_id) REFERENCES kalistenik(kalistenik_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS alat(
      alat_id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT NOT NULL,
      harga INTEGER NOT NULL,
      deskripsi TEXT,
      gambar TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS budget(
      budget_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      nama TEXT NOT NULL,
      datetime TEXT,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS budget_list(
      list_id INTEGER PRIMARY KEY AUTOINCREMENT,
      budget_id INTEGER NOT NULL,
      alat_id INTEGER NOT NULL,
      jumlah INTEGER,
      FOREIGN KEY (budget_id) REFERENCES budget(budget_id),
      FOREIGN KEY (alat_id) REFERENCES alat(alat_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS jadwal(
      jadwal_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      nama TEXT NOT NULL,
      start_time TEXT,
      end_time TEXT,
      hari TEXT,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS game(
      user_id INTEGER PRIMARY KEY,
      highest_skor INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');
  }
}
