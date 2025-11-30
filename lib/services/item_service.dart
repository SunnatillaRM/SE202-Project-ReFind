import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class ItemService {
  static final ItemService _instance = ItemService._internal();
  factory ItemService() => _instance;

  ItemService._internal();

  static Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), "refind.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            item_id       INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id   INTEGER,
            title         TEXT NOT NULL,
            description   TEXT,
            type          TEXT NOT NULL,
            latitude      REAL NOT NULL,
            longitude     REAL NOT NULL,
            address_text  TEXT,
            created_at    INTEGER,
            updated_at    INTEGER,
            tags          TEXT,                -- CSV
            image_paths   TEXT                 -- CSV
          );
        ''');
      },
    );

    return _db!;
  }

  Future<int> insertItem(Item item) async {
    final db = await _getDb();
    return await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Item>> getAllItems() async {
    final db = await _getDb();
    final rows = await db.query(
      'items',
      orderBy: 'created_at DESC',
    );

    return rows.map((m) => Item.fromMap(m)).toList();
  }

  Future<Item?> getItem(int id) async {
    final db = await _getDb();
    final rows = await db.query(
      'items',
      where: 'item_id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) return null;
    return Item.fromMap(rows.first);
  }

  Future<int> updateItem(Item item) async {
    if (item.itemId == null) {
      throw Exception("Cannot update item: itemId is null");
    }

    final db = await _getDb();
    return await db.update(
      'items',
      item.toMap(),
      where: 'item_id = ?',
      whereArgs: [item.itemId],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await _getDb();
    return await db.delete(
      'items',
      where: 'item_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Item>> searchItems(String query) async {
    final db = await _getDb();
    final rows = await db.query(
      'items',
      where: '''
        title LIKE ? OR 
        description LIKE ? OR 
        address_text LIKE ?
      ''',
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
      ],
    );

    return rows.map((m) => Item.fromMap(m)).toList();
  }
}
