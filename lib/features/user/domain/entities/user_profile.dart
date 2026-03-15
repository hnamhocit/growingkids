enum UserRole {
  admin,
  staff,
  customer;

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.customer,
    );
  }
}

class UserProfile {
  final String id;
  final String displayName;
  final String? photoUrl;
  final int greenPoint;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckinDate;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.greenPoint,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCheckinDate,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      displayName: map['display_name'] as String,
      photoUrl: map['photo_url'] as String?,
      greenPoint: (map['greenPoint'] as num?)?.toInt() ?? 0,
      currentStreak: (map['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longest_streak'] as num?)?.toInt() ?? 0,
      lastCheckinDate: map['last_checkin_date'] == null
          ? null
          : DateTime.parse(map['last_checkin_date'] as String),
      role: UserRole.fromValue(map['role'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
