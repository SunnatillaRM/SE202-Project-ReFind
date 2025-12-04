class Category {
  final int? categoryId;
  final String name;
  final String? iconPath;

  Category({
    this.categoryId,
    required this.name,
    this.iconPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
      'icon_path': iconPath,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['category_id'] as int?,
      name: map['name'] as String,
      iconPath: map['icon_path'] as String?,
    );
  }
}

