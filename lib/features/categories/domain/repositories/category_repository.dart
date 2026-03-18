import 'dart:typed_data';

import 'package:growingkids/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({int? limit});
  Future<void> createCategory({
    required String name,
    String? description,
    Uint8List? imageBytes,
    String? imageFileName,
  });
  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
    String? currentThumbnailUrl,
    Uint8List? imageBytes,
    String? imageFileName,
  });
  Future<void> deleteCategory(String id);
}
