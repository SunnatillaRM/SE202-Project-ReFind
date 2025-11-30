import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import '/themes/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/screens/location_picker/location_picker_screen.dart';
import '/database/database_service.dart';
import '/models/item.dart';
import '/models/item_image.dart';
import '/models/category.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referencePointController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  bool _isLost = true;
  int _bottomIndex = 1; // middle tab selected

  // image picker
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imagePath; // Store the original image path if available

  // location from map
  LatLng? _pickedLocation;
  String? _selectedLocation;

  // category selection
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _referencePointController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _dbService.getAllCategories();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
        if (categories.isNotEmpty && _selectedCategory == null) {
          _selectedCategory = categories.first;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _loadingCategories = false;
      });
    }
  }

  void _onBottomTap(int index) {
    setState(() => _bottomIndex = index);
    // later you can navigate to other tabs here
  }

  Future<void> _post() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    try {
      const int defaultUserId = 1;
      final categoryId = _selectedCategory!.categoryId;

      final item = Item(
        userId: defaultUserId,
        categoryId: categoryId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        type: _isLost ? 'lost' : 'found',
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        addressText: _referencePointController.text.trim().isEmpty
            ? null
            : _referencePointController.text.trim(),
      );

      final itemId = await _dbService.insertItem(item);

      if (_imageBytes != null && itemId != null) {
        String imagePath;
        if (_imagePath != null) {
          imagePath = _imagePath!;
        } else {
          imagePath = 'assets/images/placeholder.png';
        }

        await _dbService.insertItemImage(
          ItemImage(
            itemId: itemId,
            filePath: imagePath,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item posted successfully!')),
        );

        _titleController.clear();
        _descriptionController.clear();
        _referencePointController.clear();
        setState(() {
          _imageBytes = null;
          _imagePath = null;
          _pickedLocation = null;
          _selectedLocation = null;
          _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
        });
      }
    } catch (e) {
      print('Error posting item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting item: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePath = picked.path;
      });
    }
  }

  Future<void> _selectLocation() async {
    // open full-screen map picker
    final LatLng? pickedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );

    if (pickedLocation != null) {
      final locationText =
          '${pickedLocation.latitude.toStringAsFixed(6)}, ${pickedLocation.longitude.toStringAsFixed(6)}';

      setState(() {
        _pickedLocation = pickedLocation;
        _selectedLocation = locationText;
        _referencePointController.text = locationText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.circle, size: 16),
                  Text(
                    'Add item',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // title + switch
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              filled: true,
                              fillColor: AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              _isLost ? 'Lost' : 'Found',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textDark,
                              ),
                            ),
                            Switch(
                              value: _isLost,
                              activeColor: AppColors.primary,
                              onChanged: (v) => setState(() => _isLost = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // image placeholder (tap to pick)
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _imageBytes == null
                          ? Center(
                              child: TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  'Add image',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // description
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Add description',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // category selection
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _loadingCategories
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : DropdownButton<Category>(
                              value: _selectedCategory,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text('Select a category'),
                              items: _categories.map((Category category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (Category? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                            ),
                    ),
                    const SizedBox(height: 16),

                    // map placeholder – tap to open Google Map picker
                    GestureDetector(
                      onTap: _selectLocation,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: _selectedLocation == null
                              ? const Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: AppColors.primary,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_pin,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedLocation!,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _referencePointController,
                      decoration: InputDecoration(
                        labelText: 'Reference point',
                        hintText: 'e.g. 41.299500, 69.240100',
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _post,
                        child: const Text(
                          'Post',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: _onBottomTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
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