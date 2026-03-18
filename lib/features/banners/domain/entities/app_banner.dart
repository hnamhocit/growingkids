class AppBanner {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final int priority;
  final DateTime createdAt;

  const AppBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.linkUrl,
    required this.isActive,
    required this.priority,
    required this.createdAt,
  });

  factory AppBanner.fromMap(Map<String, dynamic> map) {
    return AppBanner(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      imageUrl: map['image_url'] as String? ?? '',
      linkUrl: map['link_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      priority: map['priority'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
