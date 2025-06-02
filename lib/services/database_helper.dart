import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel untuk menyimpan data user
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        email TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel untuk menyimpan riwayat harga emas
    await db.execute('''
      CREATE TABLE gold_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        buy_price REAL NOT NULL,
        sell_price REAL NOT NULL,
        date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel untuk menyimpan riwayat kalkulasi
    await db.execute('''
      CREATE TABLE calculations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        gold_weight REAL NOT NULL,
        price_type TEXT NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        currency TEXT NOT NULL,
        calculated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tabel untuk menyimpan lokasi toko favorit
    await db.execute('''
      CREATE TABLE favorite_stores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        store_name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  // Gold price operations
  Future<int> insertGoldPrice(Map<String, dynamic> price) async {
    final db = await database;
    return await db.insert('gold_prices', price);
  }

  Future<List<Map<String, dynamic>>> getGoldPrices() async {
    final db = await database;
    return await db.query('gold_prices', orderBy: 'date DESC');
  }

  // Calculation history operations
  Future<int> insertCalculation(Map<String, dynamic> calculation) async {
    final db = await database;
    return await db.insert('calculations', calculation);
  }

  Future<List<Map<String, dynamic>>> getUserCalculations(int userId) async {
    final db = await database;
    return await db.query(
      'calculations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'calculated_at DESC',
    );
  }

  // Favorite store operations
  Future<int> insertFavoriteStore(Map<String, dynamic> store) async {
    final db = await database;
    return await db.insert('favorite_stores', store);
  }

  Future<List<Map<String, dynamic>>> getUserFavoriteStores(int userId) async {
    final db = await database;
    return await db.query(
      'favorite_stores',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'added_at DESC',
    );
  }

  Future<int> deleteFavoriteStore(int storeId) async {
    final db = await database;
    return await db.delete(
      'favorite_stores',
      where: 'id = ?',
      whereArgs: [storeId],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 