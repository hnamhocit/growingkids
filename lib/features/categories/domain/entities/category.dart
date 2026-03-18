class Category {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
