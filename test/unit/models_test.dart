import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/models/item.dart';
import 'package:se202_project_refind/models/category.dart';
import 'package:se202_project_refind/models/user.dart';

void main() {
  group('Item model', () {
    test('toMap and fromMap preserve fields', () {
      final now = DateTime.now().millisecondsSinceEpoch;

      final item = Item(
        itemId: 10,
        userId: 2,
        categoryId: 3,
        title: 'Test Item',
        description: 'Desc',
        type: 'lost',
        status: 'active',
        latitude: 41.31,
        longitude: 69.24,
        addressText: 'Tashkent',
        createdAt: now,
        updatedAt: now,
      );

      final map = item.toMap();

      expect(map['item_id'], 10);
      expect(map['user_id'], 2);
      expect(map['category_id'], 3);
      expect(map['title'], 'Test Item');
      expect(map['description'], 'Desc');
      expect(map['type'], 'lost');
      expect(map['status'], 'active');
      expect(map['latitude'], 41.31);
      expect(map['longitude'], 69.24);
      expect(map['address_text'], 'Tashkent');

      final roundTripped = Item.fromMap(map);

      expect(roundTripped.itemId, item.itemId);
      expect(roundTripped.userId, item.userId);
      expect(roundTripped.categoryId, item.categoryId);
      expect(roundTripped.title, item.title);
      expect(roundTripped.description, item.description);
      expect(roundTripped.type, item.type);
      expect(roundTripped.status, item.status);
      expect(roundTripped.latitude, item.latitude);
      expect(roundTripped.longitude, item.longitude);
      expect(roundTripped.addressText, item.addressText);
    });

    test('default status is active when missing', () {
      final map = {
        'item_id': 1,
        'user_id': 1,
        'category_id': 1,
        'title': 'No Status Item',
        'description': null,
        'type': 'lost',
        'latitude': 41.0,
        'longitude': 69.0,
        'address_text': null,
        'created_at': null,
        'updated_at': null,
      };

      final item = Item.fromMap(map);

      expect(item.status, 'active');
    });
  });

  group('Category model', () {
    test('toMap and fromMap preserve fields', () {
      final category = Category(
        categoryId: 1,
        name: 'Wallet',
        iconPath: 'assets/images/wallet.png',
      );

      final map = category.toMap();
      expect(map['category_id'], 1);
      expect(map['name'], 'Wallet');
      expect(map['icon_path'], 'assets/images/wallet.png');

      final roundTripped = Category.fromMap(map);
      expect(roundTripped.categoryId, category.categoryId);
      expect(roundTripped.name, category.name);
      expect(roundTripped.iconPath, category.iconPath);
    });
  });

  group('User model', () {
    test('toMap and fromMap preserve fields', () {
      final now = DateTime.now().millisecondsSinceEpoch;

      final user = User(
        userId: 5,
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+998901234567',
        username: 'johndoe',
        photoPath: 'path/to/photo.png',
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['user_id'], 5);
      expect(map['name'], 'John Doe');
      expect(map['email'], 'john@example.com');
      expect(map['phone_number'], '+998901234567');
      expect(map['username'], 'johndoe');
      expect(map['photo_path'], 'path/to/photo.png');
      expect(map['created_at'], isNotNull);

      final roundTripped = User.fromMap(map);
      expect(roundTripped.userId, user.userId);
      expect(roundTripped.name, user.name);
      expect(roundTripped.email, user.email);
      expect(roundTripped.phoneNumber, user.phoneNumber);
      expect(roundTripped.username, user.username);
      expect(roundTripped.photoPath, user.photoPath);
    });
  });
}
