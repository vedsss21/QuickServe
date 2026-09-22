enum UserRole {
  customer,
  agent,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'agent':
        return UserRole.agent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  String toDbString() => name;
}

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.toDbString(),
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }
}
