class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String motto;
  final List<String> socialLinks;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.motto = '',
    this.socialLinks = const [],
    required this.createdAt,
    required this.lastLoginAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      motto: json['motto'] ?? '',
      socialLinks: List<String>.from(json['socialLinks'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'motto': motto,
      'socialLinks': socialLinks,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }
  
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? motto,
    List<String>? socialLinks,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      motto: motto ?? this.motto,
      socialLinks: socialLinks ?? this.socialLinks,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}