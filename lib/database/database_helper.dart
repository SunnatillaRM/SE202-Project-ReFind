import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lostboard.db');
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
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone_number TEXT,
        username TEXT,
        photo_path TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT CHECK(type IN ('lost', 'found')) NOT NULL,
        status TEXT CHECK(status IN ('active', 'claimed', 'resolved', 'deleted')) DEFAULT 'active',
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address_text TEXT,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(user_id),
        FOREIGN KEY(category_id) REFERENCES categories(category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE item_images (
        image_id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        created_at INTEGER,
        FOREIGN KEY(item_id) REFERENCES items(item_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE claims (
        claim_id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        claimant_id INTEGER NOT NULL,
        message TEXT,
        status TEXT CHECK(status IN ('pending','approved','rejected')) DEFAULT 'pending',
        created_at INTEGER,
        FOREIGN KEY(item_id) REFERENCES items(item_id),
        FOREIGN KEY(claimant_id) REFERENCES users(user_id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

