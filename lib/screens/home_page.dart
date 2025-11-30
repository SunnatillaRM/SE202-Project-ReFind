import 'package:flutter/material.dart';
import '/map.dart'; // make sure path is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Simple models for category & item
class _Category {
  final String id;
  final String name;

  const _Category({required this.id, required this.name});
}

class _Item {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String location;
  final double lat;
  final double lng;
  final String imagePath; // 🔹 image for framed marker on map

  const _Item({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.location,
    required this.lat,
    required this.lng,
    required this.imagePath,
  });
}

class _HomePageState extends State<HomePage> {
  static const headerColor = Color(0xFFF1D9D9);
  static const cardColor = Color(0xFF9B4B4B);

  // CATEGORIES
  final List<_Category> _categories = const [
    _Category(id: 'electronics', name: 'Electronics'),
    _Category(id: 'clothes', name: 'Clothes'),
    _Category(id: 'books', name: 'Books'),
    _Category(id: 'furniture', name: 'Furniture'),
    _Category(id: 'others', name: 'Others'),
  ];

  // ITEMS (with coordinates around Tashkent + imagePath)
  // ⚠️ Make sure these assets exist in pubspec.yaml (wallet.png, keys.png, etc.)
 final List<_Item> _items = const [
  _Item(
    id: '1',
    categoryId: 'electronics',
    title: 'Wireless Headphones',
    description: 'Noise-cancelling over-ear headphones, almost new.',
    location: 'Amir Temur Avenue, Tashkent',
    lat: 41.311081,
    lng: 69.240562,
    imagePath: 'assets/images/headphone.jpg',
  ),
  _Item(
    id: '2',
    categoryId: 'electronics',
    title: 'Smartphone (Samsung A52)',
    description: 'Found near bus stop, black case with cracked corner.',
    location: 'Chilonzor 3, Tashkent',
    lat: 41.315081,
    lng: 69.245562,
    imagePath: 'assets/images/samsung.jpg',
  ),
  _Item(
    id: '3',
    categoryId: 'clothes',
    title: 'Black Hoodie',
    description: 'Plain black hoodie, size M.',
    location: 'Magic City Park',
    lat: 41.320000,
    lng: 69.250000,
    imagePath: 'assets/images/hoodie.jpg',
  ),
  _Item(
    id: '4',
    categoryId: 'clothes',
    title: 'Blue Backpack',
    description: 'School backpack with keychain on zipper.',
    location: 'Minor metro station',
    lat: 41.305000,
    lng: 69.230000,
    imagePath: 'assets/images/backpack.jpg',
  ),
  _Item(
    id: '5',
    categoryId: 'books',
    title: 'Data Structures Book',
    description: 'English CS textbook left in reading room.',
    location: 'NUU Library, 2nd floor',
    lat: 41.310500,
    lng: 69.247000,
    imagePath: 'assets/images/book.jpg',
  ),
  _Item(
    id: '6',
    categoryId: 'furniture',
    title: 'Office Chair',
    description: 'Ergonomic chair, slightly damaged armrest.',
    location: 'Yunusabad office center',
    lat: 41.298000,
    lng: 69.240000,
    imagePath: 'assets/images/chair.jpg',
  ),
  _Item(
    id: '7',
    categoryId: 'others',
    title: 'Keychain with 3 Keys',
    description: 'Metal keychain with smiley face.',
    location: 'Next to coffee shop on campus',
    lat: 41.299500,
    lng: 69.241500,
    imagePath: 'assets/images/keys.jpg',
  ),
];

  late String _selectedCategoryId;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = _categories.first.id;

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter by category + search
    final List<_Item> filteredItems = _items
        .where((item) => item.categoryId == _selectedCategoryId)
        .where((item) {
          if (_searchQuery.isEmpty) return true;

          return item.title.toLowerCase().contains(_searchQuery) ||
              item.description.toLowerCase().contains(_searchQuery) ||
              item.location.toLowerCase().contains(_searchQuery);
        })
        .toList();

    final selectedCategory = _categories
        .firstWhere((c) => c.id == _selectedCategoryId, orElse: () => _categories.first);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ===== Content =====
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchBar(controller: _searchController),
                      const SizedBox(height: 16),

                      // Category section
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final bool isSelected =
                                category.id == _selectedCategoryId;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                });
                              },
                              child: _CategoryCard(
                                title: category.name,
                                color: cardColor,
                                isSelected: isSelected,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Items section
                      Text(
                        'Items (${selectedCategory.name})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (filteredItems.isEmpty)
                        const Text(
                          'No items yet in this category.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        )
                      else
                        Column(
                          children: filteredItems
                              .map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 16.0),
                                  child: _ItemCard(
                                    title: item.title,
                                    description: item.description,
                                    location: item.location,
                                    color: cardColor,
                                    onTap: () {
                                      // 👉 One-tap: open map focused on this item's location
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LostThingsMapPage(
                                            targetLat: item.lat,
                                            targetLng: item.lng,
                                            targetTitle: item.title,
                                            targetDescription: item.description,
                                            targetImagePath: item.imagePath,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== Bottom Navigation =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: headerColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        elevation: 0,
        onTap: (index) {
          if (index == 0) return; // already on Home

          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add item screen coming soon')),
            );
          }

          if (index == 2) {
            // Map icon opens normal map (no specific item)
            Navigator.pushNamed(context, '/map');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: '',
          ),
        ],
      ),
    );
  }
}

// ================== Helper Widgets ==================

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const Icon(Icons.search),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;

  const _CategoryCard({
    required this.title,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final Color color;
  final VoidCallback? onTap;

  const _ItemCard({
    required this.title,
    required this.description,
    required this.location,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // 👈 one tap = open map
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
