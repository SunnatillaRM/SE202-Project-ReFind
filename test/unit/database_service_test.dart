import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/database/database_service.dart';
import 'package:se202_project_refind/database/mock_data.dart';
import 'package:se202_project_refind/models/item.dart';
import 'package:se202_project_refind/models/category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // For tests, we use web/in-memory database
    DatabaseService.forceWebMode();
    await MockData.initializeMockData();
  });

  tearDownAll(() {
    DatabaseService.resetWebMode();
  });

  group('DatabaseService (web/mock mode)', () {
    test('loads all items from mock data', () async {
      // Use the real API name from your service
      final service = DatabaseService();
      final List<Item> items = await service.getAllItems();

      expect(items, isNotEmpty);
      for (final item in items) {
        expect(item.itemId, isNotNull);
        expect(item.title, isNotEmpty);
        expect(item.type, isNotEmpty);
      }
    });

    test('loads all categories from mock data', () async {
      final service = DatabaseService();
      final List<Category> categories = await service.getAllCategories();

      expect(categories, isNotEmpty);
      for (final category in categories) {
        expect(category.categoryId, isNotNull);
        expect(category.name, isNotEmpty);
      }
    });

    test('items have valid coordinates for map display', () async {
      final service = DatabaseService();
      final List<Item> items = await service.getAllItems();

      for (final item in items) {
        // allow nulls but if present, they must be in valid range
        if (item.latitude != null && item.longitude != null) {
          expect(item.latitude! >= -90 && item.latitude! <= 90, isTrue);
          expect(item.longitude! >= -180 && item.longitude! <= 180, isTrue);
        }
      }
    });
  });
}
