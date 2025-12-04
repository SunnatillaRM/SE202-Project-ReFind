import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_helper.dart';
import 'database_helper_web.dart';
import 'database_interface.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_image.dart';
import '../models/claim.dart';

// Adapter for sqflite Database
class SqfliteAdapter implements IDatabase {
  final dynamic _db; // Database from sqflite

  SqfliteAdapter(this._db);

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return await _db.insert(table, data);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await _db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs}) async {
    return await _db.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    return await _db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> close() async {
    await _db.close();
  }
}

class DatabaseService {
  IDatabase? _db;
  bool _initialized = false;
  static bool _forceWebMode = false;
  
  static void forceWebMode() {
    _forceWebMode = true;
  }

  static void resetWebMode() {
    _forceWebMode = false;
  }

  Future<IDatabase> get _database async {
    if (_db != null && _initialized) return _db!;
    
    // In web mode or when forced, use web database directly
    if (kIsWeb || _forceWebMode) {
      final webHelper = DatabaseHelperWeb.instance;
      await webHelper.initialize();
      _db = webHelper;
    } else {
      // Use SQLite for mobile
      try {
        final dbHelper = DatabaseHelper.instance;
        final db = await dbHelper.database;
        _db = SqfliteAdapter(db);
      } catch (e) {
        // Fallback to web version if SQLite fails
        // Suppress error message in test-like scenarios (when error mentions databaseFactory)
        final errorMsg = e.toString();
        if (!errorMsg.contains('databaseFactory')) {
          print('SQLite not available, using web database: $e');
        }
        final webHelper = DatabaseHelperWeb.instance;
        await webHelper.initialize();
        _db = webHelper;
      }
    }
    _initialized = true;
    return _db!;
  }

  // ========== Users ==========
  Future<int> insertUser(User user) async {
    final db = await _database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final db = await _database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserById(int userId) async {
    final db = await _database;
    final maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // ========== Categories ==========
  Future<int> insertCategory(Category category) async {
    final db = await _database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int categoryId) async {
    final db = await _database;
    final maps = await db.query(
      'categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(Category category) async {
    final db = await _database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'category_id = ?',
      whereArgs: [category.categoryId],
    );
  }

  Future<int> deleteCategory(int categoryId) async {
    final db = await _database;
    return await db.delete(
      'categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  // Get items by category
  Future<List<Item>> getItemsByCategoryId(int categoryId, {String? status, String? type}) async {
    final db = await _database;
    List<String> whereConditions = ['category_id = ?'];
    List<dynamic> whereArgs = [categoryId];

    if (status != null) {
      whereConditions.add('status = ?');
      whereArgs.add(status);
    } else {
      whereConditions.add('status = ?');
      whereArgs.add('active'); // Default to active items
    }

    if (type != null) {
      whereConditions.add('type = ?');
      whereArgs.add(type);
    }

    final maps = await db.query(
      'items',
      where: whereConditions.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  // ========== Items ==========
  Future<int> insertItem(Item item) async {
    final db = await _database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getAllItems({String? status, String? type}) async {
    final db = await _database;
    String? where;
    List<dynamic>? whereArgs;

    if (status != null && type != null) {
      where = 'status = ? AND type = ?';
      whereArgs = [status, type];
    } else if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    } else if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    }

    final maps = await db.query(
      'items',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<List<Item>> getActiveItems({String? type}) async {
    return getAllItems(status: 'active', type: type);
  }

  Future<Item?> getItemById(int itemId) async {
    final db = await _database;
    final maps = await db.query(
      'items',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateItem(Item item) async {
    final db = await _database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'item_id = ?',
      whereArgs: [item.itemId],
    );
  }

  Future<int> deleteItem(int itemId) async {
    final db = await _database;
    return await db.delete(
      'items',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
  }

  // ========== Item Images ==========
  Future<int> insertItemImage(ItemImage image) async {
    final db = await _database;
    return await db.insert('item_images', image.toMap());
  }

  Future<List<ItemImage>> getImagesByItemId(int itemId) async {
    final db = await _database;
    final maps = await db.query(
      'item_images',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => ItemImage.fromMap(maps[i]));
  }

  Future<String?> getFirstImageByItemId(int itemId) async {
    final images = await getImagesByItemId(itemId);
    return images.isNotEmpty ? images.first.filePath : null;
  }

  // ========== Claims ==========
  Future<int> insertClaim(Claim claim) async {
    final db = await _database;
    return await db.insert('claims', claim.toMap());
  }

  Future<List<Claim>> getAllClaims({String? status}) async {
    final db = await _database;
    String? where;
    List<dynamic>? whereArgs;

    if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    }

    final maps = await db.query(
      'claims',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Claim.fromMap(maps[i]));
  }

  Future<Claim?> getClaimById(int claimId) async {
    final db = await _database;
    final maps = await db.query(
      'claims',
      where: 'claim_id = ?',
      whereArgs: [claimId],
    );
    if (maps.isNotEmpty) {
      return Claim.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Claim>> getClaimsByItemId(int itemId, {String? status}) async {
    final db = await _database;
    String? where = 'item_id = ?';
    List<dynamic> whereArgs = [itemId];

    if (status != null) {
      where += ' AND status = ?';
      whereArgs.add(status);
    }

    final maps = await db.query(
      'claims',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Claim.fromMap(maps[i]));
  }

  Future<List<Claim>> getClaimsByClaimantId(int claimantId, {String? status}) async {
    final db = await _database;
    String? where = 'claimant_id = ?';
    List<dynamic> whereArgs = [claimantId];

    if (status != null) {
      where += ' AND status = ?';
      whereArgs.add(status);
    }

    final maps = await db.query(
      'claims',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Claim.fromMap(maps[i]));
  }

  Future<int> updateClaim(Claim claim) async {
    final db = await _database;
    return await db.update(
      'claims',
      claim.toMap(),
      where: 'claim_id = ?',
      whereArgs: [claim.claimId],
    );
  }

  Future<int> updateClaimStatus(int claimId, String status) async {
    final db = await _database;
    return await db.update(
      'claims',
      {'status': status},
      where: 'claim_id = ?',
      whereArgs: [claimId],
    );
  }

  Future<int> deleteClaim(int claimId) async {
    final db = await _database;
    return await db.delete(
      'claims',
      where: 'claim_id = ?',
      whereArgs: [claimId],
    );
  }

  // ========== Search Items ==========
  /// Search for items with various filters
  /// [query] - Text search in title and description
  /// [type] - Filter by 'lost' or 'found'
  /// [categoryId] - Filter by category ID
  /// [status] - Filter by status (defaults to 'active')
  /// [minLat, maxLat, minLng, maxLng] - Location bounds for filtering
  Future<List<Item>> searchItems({
    String? query,
    String? type,
    int? categoryId,
    String? status,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
  }) async {
    final db = await _database;
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    // Default to active items if status not specified
    if (status != null) {
      whereConditions.add('status = ?');
      whereArgs.add(status);
    } else {
      whereConditions.add('status = ?');
      whereArgs.add('active');
    }

    if (type != null) {
      whereConditions.add('type = ?');
      whereArgs.add(type);
    }

    if (categoryId != null) {
      whereConditions.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    if (query != null && query.isNotEmpty) {
      whereConditions.add('(title LIKE ? OR description LIKE ?)');
      final searchQuery = '%$query%';
      whereArgs.add(searchQuery);
      whereArgs.add(searchQuery);
    }

    if (minLat != null && maxLat != null) {
      whereConditions.add('latitude BETWEEN ? AND ?');
      whereArgs.add(minLat);
      whereArgs.add(maxLat);
    }

    if (minLng != null && maxLng != null) {
      whereConditions.add('longitude BETWEEN ? AND ?');
      whereArgs.add(minLng);
      whereArgs.add(maxLng);
    }

    final maps = await db.query(
      'items',
      where: whereConditions.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  /// Get items by category name (more user-friendly than ID)
  Future<List<Item>> getItemsByCategoryName(String categoryName, {String? status, String? type}) async {
    final category = await getCategoryByName(categoryName);
    if (category == null) return [];
    return getItemsByCategoryId(category.categoryId!, status: status, type: type);
  }

  /// Get category by name
  Future<Category?> getCategoryByName(String name) async {
    final db = await _database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  /// Get pending claims for an item (useful for item owners)
  Future<List<Claim>> getPendingClaimsByItemId(int itemId) async {
    return getClaimsByItemId(itemId, status: 'pending');
  }

  /// Get all claims for a user (both as claimant and as item owner)
  Future<Map<String, List<Claim>>> getUserClaims(int userId) async {
    // Claims where user is the claimant
    final asClaimant = await getClaimsByClaimantId(userId);
    
    // Claims where user owns the item
    final userItems = await getAllItems();
    final userItemIds = userItems.where((item) => item.userId == userId).map((item) => item.itemId).toList();
    final asOwner = <Claim>[];
    for (final itemId in userItemIds) {
      if (itemId != null) {
        final claims = await getClaimsByItemId(itemId);
        asOwner.addAll(claims);
      }
    }

    return {
      'asClaimant': asClaimant,
      'asOwner': asOwner,
    };
  }
}

