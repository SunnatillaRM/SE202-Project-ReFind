import 'database_service.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_image.dart';

class MockData {
  static final DatabaseService _dbService = DatabaseService();

  static Future<void> initializeMockData() async {
    // Check if data already exists
    final existingItems = await _dbService.getAllItems();
    if (existingItems.isNotEmpty) {
      return; // Data already exists
    }

    // Create users
    final user1 = await _dbService.insertUser(User(
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+998901234567',
      username: 'johndoe',
    ));

    final user2 = await _dbService.insertUser(User(
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      phoneNumber: '+998901234568',
      username: 'janesmith',
    ));

    final user3 = await _dbService.insertUser(User(
      name: 'Bob Johnson',
      email: 'bob.johnson@example.com',
      phoneNumber: '+998901234569',
      username: 'bobjohnson',
    ));

    // Create categories
    final category1 = await _dbService.insertCategory(Category(
      name: 'Wallet',
      iconPath: 'assets/images/wallet.png',
    ));

    final category2 = await _dbService.insertCategory(Category(
      name: 'Keys',
      iconPath: 'assets/images/keys.png',
    ));

    final category3 = await _dbService.insertCategory(Category(
      name: 'Phone',
      iconPath: null,
    ));

    final category4 = await _dbService.insertCategory(Category(
      name: 'Bag',
      iconPath: null,
    ));

    // Create items (Lost items)
    final item1 = await _dbService.insertItem(Item(
      userId: user1,
      categoryId: category1,
      title: 'Black Leather Wallet',
      description: 'Black leather wallet found near the bus stop. Contains some cards and cash.',
      type: 'found',
      latitude: 41.311081,
      longitude: 69.240562,
      addressText: 'Near Bus Stop, Tashkent',
    ));

    final item2 = await _dbService.insertItem(Item(
      userId: user2,
      categoryId: category2,
      title: 'Set of Car Keys',
      description: 'Set of car keys found in the park. Has a keychain with a small bear.',
      type: 'found',
      latitude: 41.315081,
      longitude: 69.245562,
      addressText: 'Central Park, Tashkent',
    ));

    final item3 = await _dbService.insertItem(Item(
      userId: user1,
      categoryId: category3,
      title: 'iPhone 13 Pro',
      description: 'Lost my iPhone near the shopping mall. It has a black case with a blue sticker.',
      type: 'lost',
      latitude: 41.308081,
      longitude: 69.238562,
      addressText: 'Near Shopping Mall, Tashkent',
    ));

    final item4 = await _dbService.insertItem(Item(
      userId: user3,
      categoryId: category4,
      title: 'Red Backpack',
      description: 'Found a red backpack at the university library. Contains books and notebooks.',
      type: 'found',
      latitude: 41.320081,
      longitude: 69.250562,
      addressText: 'University Library, Tashkent',
    ));

    final item5 = await _dbService.insertItem(Item(
      userId: user2,
      categoryId: category2,
      title: 'House Keys',
      description: 'Lost my house keys somewhere in the city center. Please help me find them.',
      type: 'lost',
      latitude: 41.305081,
      longitude: 69.235562,
      addressText: 'City Center, Tashkent',
    ));

    final item6 = await _dbService.insertItem(Item(
      userId: user3,
      categoryId: category1,
      title: 'Brown Wallet',
      description: 'Brown leather wallet with credit cards inside. Found at the metro station.',
      type: 'found',
      latitude: 41.312081,
      longitude: 69.242562,
      addressText: 'Metro Station, Tashkent',
    ));

    // Add images to items
    await _dbService.insertItemImage(ItemImage(
      itemId: item1,
      filePath: 'assets/images/wallet.png',
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item2,
      filePath: 'assets/images/keys.png',
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item4,
      filePath: 'assets/images/wallet.png', // Using wallet as placeholder for backpack
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item6,
      filePath: 'assets/images/wallet.png',
    ));
  }
}

