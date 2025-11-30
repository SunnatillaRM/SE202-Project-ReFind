import 'dart:convert';

class Item {
  final int? itemId;
  final int userId;
  final int? categoryId;
  final String title;
  final String? description;
  final String type; // 'lost' or 'found'
  final String status; // 'active', 'claimed', 'resolved', 'deleted'
  final double latitude;
  final double longitude;
  final String? addressText;
  final int? createdAt;
  final int? updatedAt;

  final List<String> tags;

  Item({
    this.itemId,
    required this.userId,
    this.categoryId,
    required this.title,
    this.description,
    required this.type,
    this.status = 'active',
    required this.latitude,
    required this.longitude,
    this.addressText,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      'item_id': itemId,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address_text': addressText,
      'created_at': createdAt ?? now,
      'updated_at': updatedAt ?? now,

      'tags': jsonEncode(tags),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      itemId: map['item_id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      status: map['status'] as String? ?? 'active',
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      addressText: map['address_text'] as String?,
      createdAt: map['created_at'] as int?,
      updatedAt: map['updated_at'] as int?,

      tags: map['tags'] == null
          ? []
          : List<String>.from(jsonDecode(map['tags'])),
    );
  }
}
