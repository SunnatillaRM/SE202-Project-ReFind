import 'package:flutter/material.dart';
import '/widgets/search_bar.dart';
import '/widgets/item_card.dart';
import '/models/item.dart';
import '/models/category.dart';
import '/database/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  List<Category> categories = [];
  List<Item> filtered = [];
  bool isLoading = true;

  int? selectedCategoryId; // null means "All categories"

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      print('HomeScreen: Loading categories...');
      final loadedCategories = await _dbService.getAllCategories();
      print('HomeScreen: Loaded ${loadedCategories.length} categories');
      
      setState(() {
        categories = loadedCategories;
        // Don't auto-select a category - let user see all items by default
        // selectedCategoryId remains null to show all items
        isLoading = false;
      });
      
      await _applyFilters();
    } catch (e) {
      print('Error loading data: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    try {
      final query = _search.text.trim();
      print('HomeScreen: Applying filters - query: "$query", categoryId: $selectedCategoryId');
      
      final results = await _dbService.searchItems(
        query: query.isEmpty ? null : query,
        categoryId: selectedCategoryId,
        status: 'active',
      );
      
      print('HomeScreen: Found ${results.length} items');

      setState(() {
        filtered = results;
      });
    } catch (e) {
      print('Error applying filters: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        filtered = [];
      });
    }
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                            itemCount: categories.length + 1, // +1 for "All" option
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              // First item is "All"
                              if (i == 0) {
                                final selected = selectedCategoryId == null;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryId = null;
                                    });
                                    _applyFilters();
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
                                        child: const Icon(Icons.all_inclusive, color: Colors.white),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'All',
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
                              }
                              
                              // Other items are categories
                              final c = categories[i - 1];
                              final selected = c.categoryId == selectedCategoryId;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryId = c.categoryId;
                                  });
                                  _applyFilters();
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
