class ItemImage {
  final int? imageId;
  final int itemId;
  final String filePath;
  final int? createdAt;

  ItemImage({
    this.imageId,
    required this.itemId,
    required this.filePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'image_id': imageId,
      'item_id': itemId,
      'file_path': filePath,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory ItemImage.fromMap(Map<String, dynamic> map) {
    return ItemImage(
      imageId: map['image_id'] as int?,
      itemId: map['item_id'] as int,
      filePath: map['file_path'] as String,
      createdAt: map['created_at'] as int?,
    );
  }
}
