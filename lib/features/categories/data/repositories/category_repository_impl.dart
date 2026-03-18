import 'dart:typed_data';

import 'package:growingkids/features/categories/domain/entities/category.dart';
import 'package:growingkids/features/categories/domain/repositories/category_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _sharedAssetsBucket = 'assets';
const _categoryImagesFolder = 'categories/thumbnails';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseClient client;

  const CategoryRepositoryImpl(this.client);

  @override
  Future<List<Category>> getCategories({int? limit}) async {
    var query = client
        .from('categories')
        .select('id, name, description, thumbnail_url, created_at, updated_at')
        .order('created_at', ascending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return response.map((item) => Category.fromMap(item)).toList();
  }

  @override
  Future<void> createCategory({
    required String name,
    String? description,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final thumbnailUrl = await _uploadCategoryImageIfNeeded(
      imageBytes: imageBytes,
      imageFileName: imageFileName,
    );

    await client.from('categories').insert({
      'name': name.trim(),
      'description': _nullableText(description),
      'thumbnail_url': thumbnailUrl,
    });
  }

  @override
  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
    String? currentThumbnailUrl,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final previousThumbnailUrl = currentThumbnailUrl;
    final thumbnailUrl = imageBytes == null
        ? currentThumbnailUrl
        : await _uploadCategoryImageIfNeeded(
            imageBytes: imageBytes,
            imageFileName: imageFileName,
          );

    await client
        .from('categories')
        .update({
          'name': name.trim(),
          'description': _nullableText(description),
          'thumbnail_url': _nullableText(thumbnailUrl),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);

    if (imageBytes != null &&
        previousThumbnailUrl != null &&
        previousThumbnailUrl != thumbnailUrl) {
      await _deleteImageByUrl(previousThumbnailUrl);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    final categoryData = await client
        .from('categories')
        .select('thumbnail_url')
        .eq('id', id)
        .maybeSingle();
    final thumbnailUrl = categoryData?['thumbnail_url'] as String?;

    await client.from('categories').delete().eq('id', id);

    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      await _deleteImageByUrl(thumbnailUrl);
    }
  }

  Future<String?> _uploadCategoryImageIfNeeded({
    required Uint8List? imageBytes,
    required String? imageFileName,
  }) async {
    if (imageBytes == null || imageFileName == null || imageFileName.isEmpty) {
      return null;
    }

    final sanitizedFileName = imageFileName
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
        .toLowerCase();
    final filePath =
        '$_categoryImagesFolder/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';

    await client.storage
        .from(_sharedAssetsBucket)
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: _contentTypeFromFileName(imageFileName),
          ),
        );

    return client.storage.from(_sharedAssetsBucket).getPublicUrl(filePath);
  }

  Future<void> _deleteImageByUrl(String imageUrl) async {
    final filePath = _storagePathFromPublicUrl(imageUrl);
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    await client.storage.from(_sharedAssetsBucket).remove([filePath]);
  }
}

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}

String _contentTypeFromFileName(String fileName) {
  final lowerName = fileName.toLowerCase();
  if (lowerName.endsWith('.png')) {
    return 'image/png';
  }
  if (lowerName.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lowerName.endsWith('.gif')) {
    return 'image/gif';
  }

  return 'image/jpeg';
}

String? _storagePathFromPublicUrl(String imageUrl) {
  final marker = '/object/public/$_sharedAssetsBucket/';
  final markerIndex = imageUrl.indexOf(marker);
  if (markerIndex == -1) {
    return null;
  }

  final rawPath = imageUrl.substring(markerIndex + marker.length);
  return Uri.decodeComponent(rawPath);
}
