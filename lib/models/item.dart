import 'package:flutter/foundation.dart';

class Item {
  final int? itemId;
  final int? categoryId;
  final String title;
  final String description;
  final String type;
  final double latitude;
  final double longitude;
  final String? addressText;
  final int createdAt;
  final int updatedAt;

  final List<String> tags;

  final List<String> imagePaths;

  Item({
    this.itemId,
    this.categoryId,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.addressText,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.imagePaths = const [],
  });

  // SQL

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemId: map['item_id'] as int?,
      categoryId: map['category_id'] as int?,
      title: map['title'] as String,
      description: map['description'] ?? "",
      type: map['type'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      addressText: map['address_text'],
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      tags: map['tags'] == null
          ? []
          : List<String>.from(map['tags'].split(',')),
      imagePaths: map['image_paths'] == null
          ? []
          : List<String>.from(map['image_paths'].split(',')),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'item_id': itemId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address_text': addressText,
      'created_at': createdAt,
      'updated_at': updatedAt,

      'tags': tags.join(','),
      'image_paths': imagePaths.join(','),
    };
  }

  Item copyWith({
    int? itemId,
    int? categoryId,
    String? title,
    String? description,
    String? type,
    double? latitude,
    double? longitude,
    String? addressText,
    int? createdAt,
    int? updatedAt,
    List<String>? tags,
    List<String>? imagePaths,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
