import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/database/database_service.dart';
import 'database_test_helper.dart';
import 'package:se202_project_refind/models/user.dart';
import 'package:se202_project_refind/models/category.dart';
import 'package:se202_project_refind/models/item.dart';
import 'package:se202_project_refind/models/item_image.dart';
import 'package:se202_project_refind/models/claim.dart';

void main() {
  late DatabaseService dbService;

  setUp(() async {
    dbService = await DatabaseTestHelper.setupTestDatabase();
  });

  group('Database Service Tests', () {
    group('Users CRUD', () {
      test('should insert a user', () async {
        final user = User(
          name: 'Test User',
          email: 'test@example.com',
          phoneNumber: '+1234567890',
          username: 'testuser',
        );

        final userId = await dbService.insertUser(user);
        expect(userId, greaterThan(0));
      });

      test('should get all users', () async {
        await dbService.insertUser(User(name: 'User 1', email: 'user1@test.com'));
        await dbService.insertUser(User(name: 'User 2', email: 'user2@test.com'));

        final users = await dbService.getAllUsers();
        expect(users.length, equals(2));
        expect(users.any((u) => u.name == 'User 1'), isTrue);
        expect(users.any((u) => u.name == 'User 2'), isTrue);
      });

      test('should get user by id', () async {
        final userId = await dbService.insertUser(
          User(name: 'Test User', email: 'test@example.com'),
        );

        final user = await dbService.getUserById(userId);
        expect(user, isNotNull);
        expect(user!.name, equals('Test User'));
        expect(user.email, equals('test@example.com'));
      });
    });

    group('Categories CRUD', () {
      test('should insert a category', () async {
        final category = Category(
          name: 'Wallet',
          iconPath: 'assets/images/wallet.png',
        );

        final categoryId = await dbService.insertCategory(category);
        expect(categoryId, greaterThan(0));
      });

      test('should get all categories', () async {
        await dbService.insertCategory(Category(name: 'Wallet'));
        await dbService.insertCategory(Category(name: 'Keys'));

        final categories = await dbService.getAllCategories();
        expect(categories.length, equals(2));
      });

      test('should get category by id', () async {
        final categoryId = await dbService.insertCategory(
          Category(name: 'Phone'),
        );

        final category = await dbService.getCategoryById(categoryId);
        expect(category, isNotNull);
        expect(category!.name, equals('Phone'));
      });

      test('should get category by name', () async {
        await dbService.insertCategory(Category(name: 'Bag'));

        final category = await dbService.getCategoryByName('Bag');
        expect(category, isNotNull);
        expect(category!.name, equals('Bag'));
      });

      test('should update category', () async {
        final categoryId = await dbService.insertCategory(
          Category(name: 'Old Name'),
        );

        final category = await dbService.getCategoryById(categoryId);
        final updatedCategory = Category(
          categoryId: categoryId,
          name: 'New Name',
          iconPath: category!.iconPath,
        );

        final result = await dbService.updateCategory(updatedCategory);
        expect(result, equals(1));

        final updated = await dbService.getCategoryById(categoryId);
        expect(updated!.name, equals('New Name'));
      });

      test('should delete category', () async {
        final categoryId = await dbService.insertCategory(
          Category(name: 'To Delete'),
        );

        final result = await dbService.deleteCategory(categoryId);
        expect(result, equals(1));

        final deleted = await dbService.getCategoryById(categoryId);
        expect(deleted, isNull);
      });
    });

    group('Items CRUD', () {
      late int userId;
      late int categoryId;

      setUp(() async {
        userId = await dbService.insertUser(
          User(name: 'Item Owner', email: 'owner@test.com'),
        );
        categoryId = await dbService.insertCategory(
          Category(name: 'Test Category'),
        );
      });

      test('should insert an item', () async {
        final item = Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Test Item',
          description: 'Test Description',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        );

        final itemId = await dbService.insertItem(item);
        expect(itemId, greaterThan(0));
      });

      test('should get all items', () async {
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Item 1',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Item 2',
          type: 'lost',
          latitude: 41.315081,
          longitude: 69.245562,
        ));

        final items = await dbService.getAllItems();
        expect(items.length, equals(2));
      });

      test('should get active items only', () async {
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Active Item',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
          status: 'active',
        ));
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Resolved Item',
          type: 'found',
          latitude: 41.315081,
          longitude: 69.245562,
          status: 'resolved',
        ));

        final activeItems = await dbService.getActiveItems();
        expect(activeItems.length, equals(1));
        expect(activeItems.first.title, equals('Active Item'));
      });

      test('should get items by category', () async {
        final categoryId2 = await dbService.insertCategory(
          Category(name: 'Category 2'),
        );

        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Item in Category 1',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId2,
          title: 'Item in Category 2',
          type: 'found',
          latitude: 41.315081,
          longitude: 69.245562,
        ));

        final items = await dbService.getItemsByCategoryId(categoryId);
        expect(items.length, equals(1));
        expect(items.first.title, equals('Item in Category 1'));
      });

      test('should get item by id', () async {
        final itemId = await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Test Item',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));

        final item = await dbService.getItemById(itemId);
        expect(item, isNotNull);
        expect(item!.title, equals('Test Item'));
      });

      test('should update item', () async {
        final itemId = await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Old Title',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));

        final item = await dbService.getItemById(itemId);
        final updatedItem = Item(
          itemId: itemId,
          userId: userId,
          categoryId: categoryId,
          title: 'New Title',
          description: item!.description,
          type: item.type,
          latitude: item.latitude,
          longitude: item.longitude,
        );

        final result = await dbService.updateItem(updatedItem);
        expect(result, equals(1));

        final updated = await dbService.getItemById(itemId);
        expect(updated!.title, equals('New Title'));
      });

      test('should delete item', () async {
        final itemId = await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'To Delete',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));

        final result = await dbService.deleteItem(itemId);
        expect(result, equals(1));

        final deleted = await dbService.getItemById(itemId);
        expect(deleted, isNull);
      });
    });

    group('Item Images CRUD', () {
      late int userId;
      late int categoryId;
      late int itemId;

      setUp(() async {
        userId = await dbService.insertUser(
          User(name: 'Item Owner', email: 'owner@test.com'),
        );
        categoryId = await dbService.insertCategory(
          Category(name: 'Test Category'),
        );
        itemId = await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId,
          title: 'Test Item',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));
      });

      test('should insert item image', () async {
        final image = ItemImage(
          itemId: itemId,
          filePath: 'assets/images/test.png',
        );

        final imageId = await dbService.insertItemImage(image);
        expect(imageId, greaterThan(0));
      });

      test('should get images by item id', () async {
        await dbService.insertItemImage(ItemImage(
          itemId: itemId,
          filePath: 'assets/images/image1.png',
        ));
        await dbService.insertItemImage(ItemImage(
          itemId: itemId,
          filePath: 'assets/images/image2.png',
        ));

        final images = await dbService.getImagesByItemId(itemId);
        expect(images.length, equals(2));
      });

      test('should get first image by item id', () async {
        await dbService.insertItemImage(ItemImage(
          itemId: itemId,
          filePath: 'assets/images/first.png',
        ));
        await dbService.insertItemImage(ItemImage(
          itemId: itemId,
          filePath: 'assets/images/second.png',
        ));

        final firstImage = await dbService.getFirstImageByItemId(itemId);
        expect(firstImage, isNotNull);
        expect(firstImage, equals('assets/images/first.png'));
      });
    });

    group('Claims CRUD', () {
      late int userId1;
      late int userId2;
      late int categoryId;
      late int itemId;

      setUp(() async {
        userId1 = await dbService.insertUser(
          User(name: 'Item Owner', email: 'owner@test.com'),
        );
        userId2 = await dbService.insertUser(
          User(name: 'Claimant', email: 'claimant@test.com'),
        );
        categoryId = await dbService.insertCategory(
          Category(name: 'Test Category'),
        );
        itemId = await dbService.insertItem(Item(
          userId: userId1,
          categoryId: categoryId,
          title: 'Test Item',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));
      });

      test('should insert a claim', () async {
        final claim = Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'This is my item!',
        );

        final claimId = await dbService.insertClaim(claim);
        expect(claimId, greaterThan(0));
      });

      test('should get claims by item id', () async {
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'Claim 1',
        ));
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'Claim 2',
        ));

        final claims = await dbService.getClaimsByItemId(itemId);
        expect(claims.length, equals(2));
      });

      test('should get claims by claimant id', () async {
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'My claim',
        ));

        final claims = await dbService.getClaimsByClaimantId(userId2);
        expect(claims.length, equals(1));
        expect(claims.first.message, equals('My claim'));
      });

      test('should get claim by id', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'Test Claim',
        ));

        final claim = await dbService.getClaimById(claimId);
        expect(claim, isNotNull);
        expect(claim!.message, equals('Test Claim'));
      });

      test('should update claim status', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'Pending Claim',
        ));

        final result = await dbService.updateClaimStatus(claimId, 'approved');
        expect(result, equals(1));

        final updated = await dbService.getClaimById(claimId);
        expect(updated!.status, equals('approved'));
      });

      test('should get pending claims by item id', () async {
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'Pending',
          status: 'pending',
        ));
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'Approved',
          status: 'approved',
        ));

        final pendingClaims = await dbService.getPendingClaimsByItemId(itemId);
        expect(pendingClaims.length, equals(1));
        expect(pendingClaims.first.status, equals('pending'));
      });

      test('should delete claim', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: userId2,
          message: 'To Delete',
        ));

        final result = await dbService.deleteClaim(claimId);
        expect(result, equals(1));

        final deleted = await dbService.getClaimById(claimId);
        expect(deleted, isNull);
      });
    });

    group('Search Functionality', () {
      late int userId;
      late int categoryId1;
      late int categoryId2;

      setUp(() async {
        userId = await dbService.insertUser(
          User(name: 'Test User', email: 'test@test.com'),
        );
        categoryId1 = await dbService.insertCategory(
          Category(name: 'Wallet'),
        );
        categoryId2 = await dbService.insertCategory(
          Category(name: 'Keys'),
        );

        // Create test items
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId1,
          title: 'Black Leather Wallet',
          description: 'Found near bus stop',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId2,
          title: 'Car Keys',
          description: 'Lost my keys',
          type: 'lost',
          latitude: 41.315081,
          longitude: 69.245562,
        ));
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: categoryId1,
          title: 'Brown Wallet',
          description: 'Found wallet with cards',
          type: 'found',
          latitude: 41.320081,
          longitude: 69.250562,
        ));
      });

      test('should search items by query', () async {
        final results = await dbService.searchItems(query: 'wallet');
        expect(results.length, equals(2));
        expect(results.every((item) => 
          item.title.toLowerCase().contains('wallet') ||
          item.description!.toLowerCase().contains('wallet')
        ), isTrue);
      });

      test('should search items by type', () async {
        final foundItems = await dbService.searchItems(type: 'found');
        expect(foundItems.length, equals(2));
        expect(foundItems.every((item) => item.type == 'found'), isTrue);

        final lostItems = await dbService.searchItems(type: 'lost');
        expect(lostItems.length, equals(1));
        expect(lostItems.first.type, equals('lost'));
      });

      test('should search items by category', () async {
        final walletItems = await dbService.searchItems(categoryId: categoryId1);
        expect(walletItems.length, equals(2));
        expect(walletItems.every((item) => item.categoryId == categoryId1), isTrue);
      });

      test('should search items with multiple filters', () async {
        final results = await dbService.searchItems(
          query: 'wallet',
          type: 'found',
          categoryId: categoryId1,
        );
        expect(results.length, equals(2));
        expect(results.every((item) => 
          item.type == 'found' && 
          item.categoryId == categoryId1
        ), isTrue);
      });
    });

    group('Category Filtering', () {
      late int userId;
      late int walletCategoryId;
      late int keysCategoryId;

      setUp(() async {
        userId = await dbService.insertUser(
          User(name: 'Test User', email: 'test@test.com'),
        );
        walletCategoryId = await dbService.insertCategory(
          Category(name: 'Wallet'),
        );
        keysCategoryId = await dbService.insertCategory(
          Category(name: 'Keys'),
        );

        await dbService.insertItem(Item(
          userId: userId,
          categoryId: walletCategoryId,
          title: 'Wallet Item',
          type: 'found',
          latitude: 41.311081,
          longitude: 69.240562,
        ));
        await dbService.insertItem(Item(
          userId: userId,
          categoryId: keysCategoryId,
          title: 'Keys Item',
          type: 'found',
          latitude: 41.315081,
          longitude: 69.245562,
        ));
      });

      test('should get items by category name', () async {
        final walletItems = await dbService.getItemsByCategoryName('Wallet');
        expect(walletItems.length, equals(1));
        expect(walletItems.first.title, equals('Wallet Item'));
      });

      test('should filter items by category and type', () async {
        final walletFoundItems = await dbService.getItemsByCategoryId(
          walletCategoryId,
          type: 'found',
        );
        expect(walletFoundItems.length, equals(1));
        expect(walletFoundItems.first.type, equals('found'));
      });
    });
  });
}

