class User {
  final int? userId;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? username;
  final String? photoPath;
  final int? createdAt;

  User({
    this.userId,
    required this.name,
    this.email,
    this.phoneNumber,
    this.username,
    this.photoPath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'username': username,
      'photo_path': photoPath,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      phoneNumber: map['phone_number'] as String?,
      username: map['username'] as String?,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as int?,
    );
  }
}
