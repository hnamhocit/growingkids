import 'dart:typed_data';

import 'package:growingkids/features/banners/domain/entities/app_banner.dart';
import 'package:growingkids/features/banners/domain/repositories/banner_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _sharedAssetsBucket = 'assets';
const _bannerImagesFolder = 'banners';

class BannerRepositoryImpl implements BannerRepository {
  final SupabaseClient client;

  const BannerRepositoryImpl(this.client);

  @override
  Future<List<AppBanner>> getBanners({
    bool activeOnly = false,
    int? limit,
  }) async {
    final baseQuery = client
        .from('banners')
        .select(
          'id, title, subtitle, image_url, link_url, is_active, priority, created_at',
        );

    final filteredQuery = activeOnly
        ? baseQuery.eq('is_active', true)
        : baseQuery;

    var query = filteredQuery
        .order('priority', ascending: false)
        .order('created_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return response.map((item) => AppBanner.fromMap(item)).toList();
  }

  @override
  Future<void> createBanner({
    required String title,
    String? subtitle,
    String? linkUrl,
    required bool isActive,
    required int priority,
    required Uint8List imageBytes,
    required String imageFileName,
  }) async {
    final imageUrl = await _uploadBannerImage(
      imageBytes: imageBytes,
      imageFileName: imageFileName,
    );

    await client.from('banners').insert({
      'title': title.trim(),
      'subtitle': _nullableText(subtitle),
      'image_url': imageUrl,
      'link_url': _nullableText(linkUrl),
      'is_active': isActive,
      'priority': priority,
    });
  }

  @override
  Future<void> updateBanner({
    required String id,
    required String title,
    String? subtitle,
    String? linkUrl,
    required bool isActive,
    required int priority,
    required String currentImageUrl,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final imageUrl = imageBytes == null
        ? currentImageUrl
        : await _uploadBannerImage(
            imageBytes: imageBytes,
            imageFileName: imageFileName!,
          );

    await client
        .from('banners')
        .update({
          'title': title.trim(),
          'subtitle': _nullableText(subtitle),
          'image_url': imageUrl,
          'link_url': _nullableText(linkUrl),
          'is_active': isActive,
          'priority': priority,
        })
        .eq('id', id);

    if (imageBytes != null && currentImageUrl != imageUrl) {
      await _deleteImageByUrl(currentImageUrl);
    }
  }

  @override
  Future<void> deleteBanner(String id) async {
    final bannerData = await client
        .from('banners')
        .select('image_url')
        .eq('id', id)
        .maybeSingle();
    final imageUrl = bannerData?['image_url'] as String?;

    await client.from('banners').delete().eq('id', id);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _deleteImageByUrl(imageUrl);
    }
  }

  Future<String> _uploadBannerImage({
    required Uint8List imageBytes,
    required String imageFileName,
  }) async {
    final sanitizedFileName = imageFileName
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
        .toLowerCase();
    final filePath =
        '$_bannerImagesFolder/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';

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
