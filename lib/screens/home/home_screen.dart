import 'package:flutter/material.dart';
import '/widgets/search_bar.dart';
import '/widgets/item_card.dart';
import '/models/item.dart';
import '/models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();

  late List<Category> categories;
  late List<Item> items;
  List<Item> filtered = [];

  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();

    loadMockData();
    _search.addListener(applyFilters);
  }

  void loadMockData() {
    // ---------- MOCK CATEGORIES ----------
    categories = [
      Category(categoryId: 1, name: "Wallet", iconPath: "assets/images/wallet.png"),
      Category(categoryId: 2, name: "Keys", iconPath: "assets/images/keys.png"),
      Category(categoryId: 3, name: "Phone", iconPath: null),
      Category(categoryId: 4, name: "Bag", iconPath: null),
    ];

    // ---------- MOCK ITEMS ----------
    items = [
      Item(
        itemId: 1,
        userId: 1,
        categoryId: 1,
        title: "Black Leather Wallet",
        description: "Found near bus stop.",
        type: "found",
        latitude: 41.31,
        longitude: 69.24,
        addressText: "Bus stop",
      ),
      Item(
        itemId: 2,
        userId: 1,
        categoryId: 2,
        title: "Car Keys",
        description: "Found in central park.",
        type: "found",
        latitude: 41.315,
        longitude: 69.245,
        addressText: "Central Park",
      ),
    ];

    // default selected category
    selectedCategoryId = categories.first.categoryId;

    applyFilters();
  }

  void applyFilters() {
    final query = _search.text.trim().toLowerCase();

    filtered = items.where((item) {
      final categoryMatch = item.categoryId == selectedCategoryId;

      final textMatch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          (item.description ?? "").toLowerCase().contains(query);

      return categoryMatch && textMatch;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF1D9D9),
            child: const Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: Colors.blueAccent),
                Spacer(),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(controller: _search),
                  const SizedBox(height: 20),

                  const Text("Category",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final c = categories[i];
                        final selected = c.categoryId == selectedCategoryId;

                        return GestureDetector(
                          onTap: () {
                            selectedCategoryId = c.categoryId;
                            applyFilters();
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9B4B4B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: selected
                                      ? Border.all(color: Colors.white, width: 3)
                                      : null,
                                ),
                                child: c.iconPath != null
                                    ? Image.asset(c.iconPath!, fit: BoxFit.cover)
                                    : const Icon(Icons.category, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Items",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (filtered.isEmpty)
                    const Text("No items found",
                        style: TextStyle(color: Colors.grey))
                  else
                    Column(
                      children: filtered
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ItemCard(item: item),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
