import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('goldapp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabel harga emas
    await db.execute('''
      CREATE TABLE gold_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        buy_price INTEGER NOT NULL,
        sell_price INTEGER NOT NULL,
        info TEXT
      )
    ''');

    // Tabel user untuk login/registrasi
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  // CRUD Gold Prices (opsional, kalau perlu)

  Future<int> insertPrice(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('gold_prices', row);
  }

  Future<List<Map<String, dynamic>>> queryAllPrices() async {
    final db = await instance.database;
    return await db.query('gold_prices', orderBy: 'id DESC');
  }

  Future<int> deletePrice(int id) async {
    final db = await instance.database;
    return await db.delete('gold_prices', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Users

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
