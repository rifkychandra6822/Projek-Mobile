import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  static const int _version = 2; // Increment version number

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('gold_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: _version,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN profile_picture TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
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
        password TEXT NOT NULL,
        email TEXT,
        nim TEXT,
        kesan_pesan TEXT,
        profile_picture TEXT,
        created_at TEXT
      )
    ''');
  }

  // CRUD Gold Prices

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

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    
    // Remove any binary data that shouldn't be stored directly in SQLite
    final updateData = Map<String, dynamic>.from(user);
    if (updateData.containsKey('profile_picture_data')) {
      updateData.remove('profile_picture_data');
    }
    
    return await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
