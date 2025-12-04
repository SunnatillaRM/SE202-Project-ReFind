import 'database_service.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_image.dart';

class MockData {
  static final DatabaseService _dbService = DatabaseService();

  static Future<void> initializeMockData() async {
    print('Initializing mock data...');
    // Check if data already exists
    final existingItems = await _dbService.getAllItems();
    print('Existing items count: ${existingItems.length}');
    if (existingItems.isNotEmpty) {
      print('Mock data already exists, skipping initialization');
      return; // Data already exists
    }
    
    print('No existing data found, creating mock data...');

    // Create users
    print('Creating users...');
    final user1 = await _dbService.insertUser(User(
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+998901234567',
      username: 'johndoe',
    ));
    print('Created user1 with ID: $user1');

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

    final user4 = await _dbService.insertUser(User(
      name: 'Alice Williams',
      email: 'alice.williams@example.com',
      phoneNumber: '+998901234570',
      username: 'alicew',
    ));

    final user5 = await _dbService.insertUser(User(
      name: 'Charlie Brown',
      email: 'charlie.brown@example.com',
      phoneNumber: '+998901234571',
      username: 'charlieb',
    ));

    final user6 = await _dbService.insertUser(User(
      name: 'Diana Prince',
      email: 'diana.prince@example.com',
      phoneNumber: '+998901234572',
      username: 'dianap',
    ));

    // Create categories
    print('Creating categories...');
    final category1 = await _dbService.insertCategory(Category(
      name: 'Wallet',
      iconPath: 'assets/images/wallet.png',
    ));
    print('Created category1 with ID: $category1');

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

    final category5 = await _dbService.insertCategory(Category(
      name: 'Documents',
      iconPath: null,
    ));

    final category6 = await _dbService.insertCategory(Category(
      name: 'Jewelry',
      iconPath: null,
    ));

    final category7 = await _dbService.insertCategory(Category(
      name: 'Electronics',
      iconPath: null,
    ));

    final category8 = await _dbService.insertCategory(Category(
      name: 'Clothing',
      iconPath: null,
    ));

    final category9 = await _dbService.insertCategory(Category(
      name: 'Glasses',
      iconPath: null,
    ));

    final category10 = await _dbService.insertCategory(Category(
      name: 'Pet',
      iconPath: null,
    ));

    // Create items (Lost items)
    print('Creating items...');
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
    print('Created item1 with ID: $item1');

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

    final item7 = await _dbService.insertItem(Item(
      userId: user4,
      categoryId: category5,
      title: 'Lost Passport',
      description: 'Lost my passport yesterday. It\'s a blue passport with my photo. Please contact if found!',
      type: 'lost',
      latitude: 41.300081,
      longitude: 69.230562,
      addressText: 'Airport Area, Tashkent',
    ));

    final item8 = await _dbService.insertItem(Item(
      userId: user5,
      categoryId: category6,
      title: 'Gold Watch Found',
      description: 'Found a gold wristwatch at the restaurant. Looks expensive. Please claim with description.',
      type: 'found',
      latitude: 41.318081,
      longitude: 69.248562,
      addressText: 'Restaurant District, Tashkent',
    ));

    final item9 = await _dbService.insertItem(Item(
      userId: user1,
      categoryId: category7,
      title: 'Lost Laptop',
      description: 'Lost my MacBook Pro 13" in a black case. Last seen at the coffee shop. Reward offered!',
      type: 'lost',
      latitude: 41.307081,
      longitude: 69.237562,
      addressText: 'Coffee Shop, Tashkent',
    ));

    final item10 = await _dbService.insertItem(Item(
      userId: user6,
      categoryId: category8,
      title: 'Red Jacket Found',
      description: 'Found a red winter jacket at the park. Size M, has a hood. Please contact to claim.',
      type: 'found',
      latitude: 41.315081,
      longitude: 69.245562,
      addressText: 'Amir Temur Park, Tashkent',
    ));

    final item11 = await _dbService.insertItem(Item(
      userId: user2,
      categoryId: category3,
      title: 'Samsung Galaxy S21',
      description: 'Lost my Samsung phone. It has a blue case and screen protector. Please help!',
      type: 'lost',
      latitude: 41.310081,
      longitude: 69.241562,
      addressText: 'Shopping Center, Tashkent',
    ));

    final item12 = await _dbService.insertItem(Item(
      userId: user3,
      categoryId: category9,
      title: 'Ray-Ban Sunglasses',
      description: 'Found black Ray-Ban sunglasses at the gym. Classic aviator style.',
      type: 'found',
      latitude: 41.313081,
      longitude: 69.243562,
      addressText: 'Fitness Center, Tashkent',
    ));

    final item13 = await _dbService.insertItem(Item(
      userId: user4,
      categoryId: category2,
      title: 'Office Keys',
      description: 'Lost my office keys. There are 3 keys on a blue keychain with a company logo.',
      type: 'lost',
      latitude: 41.304081,
      longitude: 69.234562,
      addressText: 'Business District, Tashkent',
    ));

    final item14 = await _dbService.insertItem(Item(
      userId: user5,
      categoryId: category4,
      title: 'Blue Backpack',
      description: 'Found a blue backpack with school supplies. Has stickers on it.',
      type: 'found',
      latitude: 41.319081,
      longitude: 69.251562,
      addressText: 'School Area, Tashkent',
    ));

    final item15 = await _dbService.insertItem(Item(
      userId: user6,
      categoryId: category1,
      title: 'Lost Wallet with ID',
      description: 'Lost my wallet containing my ID card and some money. Please return if found!',
      type: 'lost',
      latitude: 41.306081,
      longitude: 69.236562,
      addressText: 'City Center, Tashkent',
    ));

    final item16 = await _dbService.insertItem(Item(
      userId: user1,
      categoryId: category7,
      title: 'AirPods Pro Found',
      description: 'Found white AirPods Pro in a case. Please describe the case to claim.',
      type: 'found',
      latitude: 41.314081,
      longitude: 69.244562,
      addressText: 'Tech Store Area, Tashkent',
    ));

    final item17 = await _dbService.insertItem(Item(
      userId: user2,
      categoryId: category5,
      title: 'Driver License Lost',
      description: 'Lost my driver\'s license. It\'s a new format license. Please contact if found.',
      type: 'lost',
      latitude: 41.302081,
      longitude: 69.232562,
      addressText: 'Traffic Office, Tashkent',
    ));

    final item18 = await _dbService.insertItem(Item(
      userId: user3,
      categoryId: category10,
      title: 'Lost Dog',
      description: 'Lost my golden retriever named Max. He\'s friendly and has a blue collar. Last seen near the park.',
      type: 'lost',
      latitude: 41.316081,
      longitude: 69.246562,
      addressText: 'Dog Park, Tashkent',
    ));

    final item19 = await _dbService.insertItem(Item(
      userId: user4,
      categoryId: category8,
      title: 'Black Umbrella Found',
      description: 'Found a black umbrella with wooden handle at the bus stop. Please claim if yours.',
      type: 'found',
      latitude: 41.311081,
      longitude: 69.240562,
      addressText: 'Bus Stop #5, Tashkent',
    ));

    final item20 = await _dbService.insertItem(Item(
      userId: user5,
      categoryId: category6,
      title: 'Silver Ring',
      description: 'Lost my silver ring with a small diamond. It has sentimental value. Reward for return!',
      type: 'lost',
      latitude: 41.308081,
      longitude: 69.238562,
      addressText: 'Jewelry District, Tashkent',
    ));

    final item21 = await _dbService.insertItem(Item(
      userId: user6,
      categoryId: category3,
      title: 'iPhone 12 Found',
      description: 'Found an iPhone 12 with a clear case. Locked screen. Please contact with proof of ownership.',
      type: 'found',
      latitude: 41.312081,
      longitude: 69.242562,
      addressText: 'Metro Station Entrance, Tashkent',
    ));

    final item22 = await _dbService.insertItem(Item(
      userId: user1,
      categoryId: category4,
      title: 'Gym Bag Lost',
      description: 'Lost my gym bag with workout clothes and water bottle. Black bag with Nike logo.',
      type: 'lost',
      latitude: 41.313081,
      longitude: 69.243562,
      addressText: 'Sports Complex, Tashkent',
    ));

    final item23 = await _dbService.insertItem(Item(
      userId: user2,
      categoryId: category9,
      title: 'Prescription Glasses',
      description: 'Found prescription glasses in a black case. Please describe the frame to claim.',
      type: 'found',
      latitude: 41.309081,
      longitude: 69.239562,
      addressText: 'Medical Center, Tashkent',
    ));

    final item24 = await _dbService.insertItem(Item(
      userId: user3,
      categoryId: category2,
      title: 'Bicycle Lock Keys',
      description: 'Lost my bicycle lock keys. There are 2 keys on a red keychain.',
      type: 'lost',
      latitude: 41.317081,
      longitude: 69.247562,
      addressText: 'Bike Rental Area, Tashkent',
    ));

    final item25 = await _dbService.insertItem(Item(
      userId: user4,
      categoryId: category7,
      title: 'Tablet Found',
      description: 'Found a Samsung tablet in a cafe. Please contact with device details to claim.',
      type: 'found',
      latitude: 41.305081,
      longitude: 69.235562,
      addressText: 'Cafe Central, Tashkent',
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
      itemId: item3,
      filePath: 'assets/images/wallet.png', // Placeholder for phone
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item4,
      filePath: 'assets/images/wallet.png', // Placeholder for backpack
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item6,
      filePath: 'assets/images/wallet.png',
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item8,
      filePath: 'assets/images/wallet.png', // Placeholder for watch
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item9,
      filePath: 'assets/images/wallet.png', // Placeholder for laptop
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item10,
      filePath: 'assets/images/wallet.png', // Placeholder for jacket
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item11,
      filePath: 'assets/images/wallet.png', // Placeholder for phone
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item12,
      filePath: 'assets/images/wallet.png', // Placeholder for sunglasses
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item14,
      filePath: 'assets/images/wallet.png', // Placeholder for backpack
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item16,
      filePath: 'assets/images/wallet.png', // Placeholder for AirPods
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item18,
      filePath: 'assets/images/wallet.png', // Placeholder for pet
    ));

    await _dbService.insertItemImage(ItemImage(
      itemId: item21,
      filePath: 'assets/images/wallet.png', // Placeholder for phone
    ));
    
    print('Mock data initialization complete!');
    // Verify data was created
    final verifyItems = await _dbService.getAllItems();
    final verifyCategories = await _dbService.getAllCategories();
    print('Verification: ${verifyItems.length} items, ${verifyCategories.length} categories');
  }
}

