import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/database/database_helper_web.dart';

void main() {
  group('DatabaseHelperWeb basic CRUD', () {
    test('insert and query items table', () async {
      final db = DatabaseHelperWeb.instance;

      // Insert first item
      final id1 = await db.insert('items', {
        'title': 'Wallet',
        'type': 'lost',
        'status': 'active',
        'latitude': 41.31,
        'longitude': 69.24,
      });

      // Insert second item
      final id2 = await db.insert('items', {
        'title': 'Phone',
        'type': 'found',
        'status': 'active',
        'latitude': 41.32,
        'longitude': 69.25,
      });

      expect(id1, 1);
      expect(id2, 2);

      final all = await db.query('items');
      expect(all.length, 2);
      expect(all[0]['item_id'], 1);
      expect(all[1]['item_id'], 2);
    });

    test('query with where and orderBy', () async {
      final db = DatabaseHelperWeb.instance;

      final lostItems = await db.query(
        'items',
        where: 'type = ?',
        whereArgs: ['lost'],
      );

      expect(lostItems, isNotEmpty);
      for (final row in lostItems) {
        expect(row['type'], 'lost');
      }
    });

    test('update and delete', () async {
      final db = DatabaseHelperWeb.instance;

      // Update item 1 status
      final updated = await db.update(
        'items',
        {'status': 'resolved'},
        where: 'item_id = ?',
        whereArgs: [1],
      );
      expect(updated, 1);

      final resolvedItems = await db.query(
        'items',
        where: 'status = ?',
        whereArgs: ['resolved'],
      );
      expect(resolvedItems.length, 1);
      expect(resolvedItems.first['item_id'], 1);

      // Delete item 2
      final deleted = await db.delete(
        'items',
        where: 'item_id = ?',
        whereArgs: [2],
      );
      expect(deleted, 1);

      final remaining = await db.query('items');
      expect(remaining.length, 1);
    });
  });
}
