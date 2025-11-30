import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/database/database_service.dart';
import 'package:se202_project_refind/database/mock_data.dart';
import 'package:se202_project_refind/models/claim.dart';
import 'database_test_helper.dart';

void main() {
  late DatabaseService dbService;

  setUp(() async {
    // Setup fresh database and load mock data
    dbService = await DatabaseTestHelper.setupTestDatabase();
    await MockData.initializeMockData();
  });

  group('Mock Data Integration Tests', () {
    test('should have mock data loaded', () async {
      final users = await dbService.getAllUsers();
      final categories = await dbService.getAllCategories();
      final items = await dbService.getAllItems();

      expect(users.length, equals(3), reason: 'Should have 3 mock users');
      expect(categories.length, equals(4), reason: 'Should have 4 mock categories');
      expect(items.length, equals(6), reason: 'Should have 6 mock items');
    });

    group('Category Tests', () {
      test('should get all categories', () async {
        final categories = await dbService.getAllCategories();
        
        expect(categories.length, equals(4));
        expect(categories.any((c) => c.name == 'Wallet'), isTrue);
        expect(categories.any((c) => c.name == 'Keys'), isTrue);
        expect(categories.any((c) => c.name == 'Phone'), isTrue);
        expect(categories.any((c) => c.name == 'Bag'), isTrue);
      });

      test('should get category by name', () async {
        final walletCategory = await dbService.getCategoryByName('Wallet');
        expect(walletCategory, isNotNull);
        expect(walletCategory!.name, equals('Wallet'));

        final keysCategory = await dbService.getCategoryByName('Keys');
        expect(keysCategory, isNotNull);
        expect(keysCategory!.name, equals('Keys'));
      });

      test('should get items by category name', () async {
        final walletItems = await dbService.getItemsByCategoryName('Wallet');
        expect(walletItems.length, greaterThan(0));
        expect(walletItems.every((item) => 
          item.categoryId != null
        ), isTrue);

        // Verify category relationship
        final walletCategory = await dbService.getCategoryByName('Wallet');
        final walletItemsById = await dbService.getItemsByCategoryId(walletCategory!.categoryId!);
        expect(walletItems.length, equals(walletItemsById.length));
      });

      test('should get items by category ID', () async {
        final walletCategory = await dbService.getCategoryByName('Wallet');
        final walletItems = await dbService.getItemsByCategoryId(walletCategory!.categoryId!);
        
        expect(walletItems.length, greaterThan(0));
        expect(walletItems.every((item) => item.categoryId == walletCategory.categoryId), isTrue);
      });

      test('should filter items by category and type', () async {
        final walletCategory = await dbService.getCategoryByName('Wallet');
        final foundWallets = await dbService.getItemsByCategoryId(
          walletCategory!.categoryId!,
          type: 'found',
        );
        final lostWallets = await dbService.getItemsByCategoryId(
          walletCategory.categoryId!,
          type: 'lost',
        );

        expect(foundWallets.every((item) => item.type == 'found'), isTrue);
        expect(lostWallets.every((item) => item.type == 'lost'), isTrue);
      });
    });

    group('Search Tests', () {
      test('should search items by query text', () async {
        // Search for "wallet"
        final walletResults = await dbService.searchItems(query: 'wallet');
        expect(walletResults.length, greaterThan(0));
        expect(walletResults.every((item) => 
          item.title.toLowerCase().contains('wallet') ||
          (item.description != null && item.description!.toLowerCase().contains('wallet'))
        ), isTrue);

        // Search for "keys"
        final keysResults = await dbService.searchItems(query: 'keys');
        expect(keysResults.length, greaterThan(0));
        expect(keysResults.every((item) => 
          item.title.toLowerCase().contains('key') ||
          (item.description != null && item.description!.toLowerCase().contains('key'))
        ), isTrue);
      });

      test('should search items by type (lost/found)', () async {
        final foundItems = await dbService.searchItems(type: 'found');
        final lostItems = await dbService.searchItems(type: 'lost');

        expect(foundItems.length, greaterThan(0));
        expect(foundItems.every((item) => item.type == 'found'), isTrue);

        expect(lostItems.length, greaterThan(0));
        expect(lostItems.every((item) => item.type == 'lost'), isTrue);
      });

      test('should search items by category', () async {
        final walletCategory = await dbService.getCategoryByName('Wallet');
        final walletItems = await dbService.searchItems(categoryId: walletCategory!.categoryId);

        expect(walletItems.length, greaterThan(0));
        expect(walletItems.every((item) => item.categoryId == walletCategory.categoryId), isTrue);
      });

      test('should search with multiple filters', () async {
        final walletCategory = await dbService.getCategoryByName('Wallet');
        
        // Search for found wallets
        final foundWallets = await dbService.searchItems(
          query: 'wallet',
          type: 'found',
          categoryId: walletCategory!.categoryId,
        );

        expect(foundWallets.length, greaterThan(0));
        expect(foundWallets.every((item) => 
          item.type == 'found' && 
          item.categoryId == walletCategory.categoryId &&
          (item.title.toLowerCase().contains('wallet') ||
           (item.description != null && item.description!.toLowerCase().contains('wallet')))
        ), isTrue);
      });

      test('should search items by location bounds', () async {
        // Tashkent area bounds
        final tashkentItems = await dbService.searchItems(
          minLat: 41.300000,
          maxLat: 41.330000,
          minLng: 69.230000,
          maxLng: 69.260000,
        );

        expect(tashkentItems.length, equals(6)); // All mock items are in Tashkent
        expect(tashkentItems.every((item) => 
          item.latitude >= 41.300000 && 
          item.latitude <= 41.330000 &&
          item.longitude >= 69.230000 && 
          item.longitude <= 69.260000
        ), isTrue);
      });

      test('should return only active items in search', () async {
        final allActiveItems = await dbService.searchItems();
        expect(allActiveItems.every((item) => item.status == 'active'), isTrue);
      });
    });

    group('Claims Tests', () {
      late int itemId;
      late int claimantId;
      late int ownerId;

      setUp(() async {
        // Get a found item to claim
        final foundItems = await dbService.getActiveItems(type: 'found');
        expect(foundItems.length, greaterThan(0), reason: 'Should have found items');
        itemId = foundItems.first.itemId!;

        // Get the item owner
        final item = await dbService.getItemById(itemId);
        ownerId = item!.userId;

        // Get a different user as claimant
        final users = await dbService.getAllUsers();
        final claimant = users.firstWhere((u) => u.userId != ownerId);
        claimantId = claimant.userId!;
      });

      test('should create a claim for an item', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'This is my wallet! I lost it yesterday.',
        ));

        expect(claimId, greaterThan(0));

        final claim = await dbService.getClaimById(claimId);
        expect(claim, isNotNull);
        expect(claim!.itemId, equals(itemId));
        expect(claim.claimantId, equals(claimantId));
        expect(claim.message, equals('This is my wallet! I lost it yesterday.'));
        expect(claim.status, equals('pending'));
      });

      test('should get all claims for an item', () async {
        // Create multiple claims for the same item
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Claim 1',
        ));

        final otherUsers = await dbService.getAllUsers();
        final otherClaimant = otherUsers.firstWhere((u) => 
          u.userId != ownerId && u.userId != claimantId
        );

        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: otherClaimant.userId!,
          message: 'Claim 2',
        ));

        final claims = await dbService.getClaimsByItemId(itemId);
        expect(claims.length, equals(2));
        expect(claims.every((c) => c.itemId == itemId), isTrue);
      });

      test('should get claims by claimant', () async {
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'My claim',
        ));

        final claims = await dbService.getClaimsByClaimantId(claimantId);
        expect(claims.length, greaterThan(0));
        expect(claims.every((c) => c.claimantId == claimantId), isTrue);
      });

      test('should get pending claims for an item', () async {
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Pending claim',
          status: 'pending',
        ));

        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Approved claim',
          status: 'approved',
        ));

        final pendingClaims = await dbService.getPendingClaimsByItemId(itemId);
        expect(pendingClaims.length, equals(1));
        expect(pendingClaims.first.status, equals('pending'));
        expect(pendingClaims.first.message, equals('Pending claim'));
      });

      test('should update claim status', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Test claim',
          status: 'pending',
        ));

        // Approve the claim
        final updateResult = await dbService.updateClaimStatus(claimId, 'approved');
        expect(updateResult, equals(1));

        final updatedClaim = await dbService.getClaimById(claimId);
        expect(updatedClaim!.status, equals('approved'));

        // Reject the claim
        await dbService.updateClaimStatus(claimId, 'rejected');
        final rejectedClaim = await dbService.getClaimById(claimId);
        expect(rejectedClaim!.status, equals('rejected'));
      });

      test('should update full claim', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Original message',
        ));

        final originalClaim = await dbService.getClaimById(claimId);
        final updatedClaim = Claim(
          claimId: claimId,
          itemId: originalClaim!.itemId,
          claimantId: originalClaim.claimantId,
          message: 'Updated message',
          status: 'approved',
        );

        final updateResult = await dbService.updateClaim(updatedClaim);
        expect(updateResult, equals(1));

        final result = await dbService.getClaimById(claimId);
        expect(result!.message, equals('Updated message'));
        expect(result.status, equals('approved'));
      });

      test('should get user claims (as claimant and owner)', () async {
        // Create a claim
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Claim as claimant',
        ));

        // Get another item owned by the same user
        final ownerItems = await dbService.getAllItems();
        final ownerItem = ownerItems.firstWhere((item) => item.userId == ownerId);
        
        final otherUsers = await dbService.getAllUsers();
        final otherClaimant = otherUsers.firstWhere((u) => u.userId != ownerId);
        
        await dbService.insertClaim(Claim(
          itemId: ownerItem.itemId!,
          claimantId: otherClaimant.userId!,
          message: 'Claim on owner item',
        ));

        final userClaims = await dbService.getUserClaims(ownerId);
        
        // Should have claims as owner
        expect(userClaims['asOwner']!.length, greaterThan(0));
        expect(userClaims['asOwner']!.every((c) => 
          ownerItems.any((item) => item.itemId == c.itemId && item.userId == ownerId)
        ), isTrue);
      });

      test('should delete a claim', () async {
        final claimId = await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'To be deleted',
        ));

        final deleteResult = await dbService.deleteClaim(claimId);
        expect(deleteResult, equals(1));

        final deletedClaim = await dbService.getClaimById(claimId);
        expect(deletedClaim, isNull);
      });

      test('should filter claims by status', () async {
        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Pending',
          status: 'pending',
        ));

        await dbService.insertClaim(Claim(
          itemId: itemId,
          claimantId: claimantId,
          message: 'Approved',
          status: 'approved',
        ));

        final pendingClaims = await dbService.getClaimsByItemId(itemId, status: 'pending');
        final approvedClaims = await dbService.getClaimsByItemId(itemId, status: 'approved');

        expect(pendingClaims.length, equals(1));
        expect(pendingClaims.first.status, equals('pending'));

        expect(approvedClaims.length, equals(1));
        expect(approvedClaims.first.status, equals('approved'));
      });
    });

    group('Item Images Tests', () {
      test('should get images for items', () async {
        final items = await dbService.getAllItems();
        
        for (final item in items) {
          final images = await dbService.getImagesByItemId(item.itemId!);
          final firstImage = await dbService.getFirstImageByItemId(item.itemId!);
          
          if (images.isNotEmpty) {
            expect(firstImage, isNotNull);
            expect(firstImage, equals(images.first.filePath));
          }
        }
      });

      test('should verify items with images from mock data', () async {
        final items = await dbService.getAllItems();
        final itemsWithImages = <int>[];

        for (final item in items) {
          final image = await dbService.getFirstImageByItemId(item.itemId!);
          if (image != null) {
            itemsWithImages.add(item.itemId!);
          }
        }

        // Mock data should have at least some items with images
        expect(itemsWithImages.length, greaterThan(0));
      });
    });

    group('Active Items Tests', () {
      test('should get only active items', () async {
        final activeItems = await dbService.getActiveItems();
        expect(activeItems.length, equals(6)); // All mock items are active
        expect(activeItems.every((item) => item.status == 'active'), isTrue);
      });

      test('should filter active items by type', () async {
        final activeFound = await dbService.getActiveItems(type: 'found');
        final activeLost = await dbService.getActiveItems(type: 'lost');

        expect(activeFound.length, greaterThan(0));
        expect(activeFound.every((item) => 
          item.status == 'active' && item.type == 'found'
        ), isTrue);

        expect(activeLost.length, greaterThan(0));
        expect(activeLost.every((item) => 
          item.status == 'active' && item.type == 'lost'
        ), isTrue);
      });
    });
  });
}

