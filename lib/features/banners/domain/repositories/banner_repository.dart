import 'dart:typed_data';

import 'package:growingkids/features/banners/domain/entities/app_banner.dart';

abstract class BannerRepository {
  Future<List<AppBanner>> getBanners({bool activeOnly = false, int? limit});
  Future<void> createBanner({
    required String title,
    String? subtitle,
    String? linkUrl,
    required bool isActive,
    required int priority,
    required Uint8List imageBytes,
    required String imageFileName,
  });
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
  });
  Future<void> deleteBanner(String id);
}
