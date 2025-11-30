import 'package:flutter/material.dart';
import 'package:se202_project_refind/models/item.dart';
import 'package:se202_project_refind/widgets/item_card.dart';
import 'package:se202_project_refind/widgets/search_bar.dart';
import 'package:se202_project_refind/widgets/map.dart';
import 'package:se202_project_refind/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Category {
  final String id;
  final String name;
  const _Category({required this.id, required this.name});
}

class _HomePageState extends State<HomePage> {
  static const headerColor = Color(0xFFF1D9D9);
  static const cardColor = Color(0xFF9B4B4B);

  final List<_Category> _categories = const [
    _Category(id: 'electronics', name: 'Electronics'),
    _Category(id: 'clothes', name: 'Clothes'),
    _Category(id: 'books', name: 'Books'),
    _Category(id: 'furniture', name: 'Furniture'),
    _Category(id: 'others', name: 'Others'),
  ];

  final List<Item> _items = [
    Item(
      itemId: 1,
      title: 'Wireless Headphones',
      description: 'Noise-cancelling over-ear headphones.',
      type: 'lost',
      latitude: 41.311081,
      longitude: 69.240562,
      addressText: 'Amir Temur Avenue, Tashkent',
      createdAt: 0,
      updatedAt: 0,
      tags: ['electronics'],
      imagePaths: ['assets/images/headphone.jpg'],
      categoryId: null,
    ),
    Item(
      itemId: 2,
      title: 'Samsung A52 Smartphone',
      description: 'Found near bus stop, cracked case.',
      type: 'found',
      latitude: 41.315081,
      longitude: 69.245562,
      addressText: 'Chilonzor 3, Tashkent',
      createdAt: 0,
      updatedAt: 0,
      tags: ['electronics'],
      imagePaths: ['assets/images/samsung.jpg'],
      categoryId: null,
    ),
    Item(
      itemId: 3,
      title: 'Black Hoodie (M)',
      description: 'Plain black hoodie.',
      type: 'lost',
      latitude: 41.320000,
      longitude: 69.250000,
      addressText: 'Magic City Park',
      createdAt: 0,
      updatedAt: 0,
      tags: ['clothes'],
      imagePaths: ['assets/images/hoodie.jpg'],
      categoryId: null,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late String _selectedCategoryId;

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
    final List<Item> filteredItems = _items
        .where((i) => i.tags.contains(_selectedCategoryId))
        .where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.title.toLowerCase().contains(_searchQuery) ||
              i.description.toLowerCase().contains(_searchQuery) ||
              (i.addressText?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchBarWidget(controller: _searchController),
                    const SizedBox(height: 16),

                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _buildCategoryScroller(),

                    const SizedBox(height: 24),

                    Text(
                      'Items (${_categories.firstWhere((c) => c.id == _selectedCategoryId).name})',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (filteredItems.isEmpty)
                      const Text(
                        'No items yet in this category.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    else
                      Column(
                        children: filteredItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ItemCard(
                              item: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LostThingsMapPage(
                                      targetLat: item.latitude,
                                      targetLng: item.longitude,
                                      targetTitle: item.title,
                                      targetDescription: item.description,
                                      targetImagePath: item.imagePaths.first,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: AppNavbar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return; // Already on Home

          if (i == 1) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Add Item coming soon')));
          }

          if (i == 2) {
            Navigator.pushNamed(context, '/map');
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildCategoryScroller() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final c = _categories[index];
          final selected = c.id == _selectedCategoryId;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = c.id),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 70,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(4),
                    border: selected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
