part of 'banner_bloc.dart';

sealed class BannerEvent {
  const BannerEvent();
}

class BannersRequested extends BannerEvent {
  const BannersRequested();
}

class BannerCreatedRequested extends BannerEvent {
  final String title;
  final String? subtitle;
  final String? linkUrl;
  final bool isActive;
  final int priority;
  final Uint8List imageBytes;
  final String imageFileName;

  const BannerCreatedRequested({
    required this.title,
    this.subtitle,
    this.linkUrl,
    required this.isActive,
    required this.priority,
    required this.imageBytes,
    required this.imageFileName,
  });
}

class BannerUpdatedRequested extends BannerEvent {
  final String id;
  final String title;
  final String? subtitle;
  final String? linkUrl;
  final bool isActive;
  final int priority;
  final String currentImageUrl;
  final Uint8List? imageBytes;
  final String? imageFileName;

  const BannerUpdatedRequested({
    required this.id,
    required this.title,
    this.subtitle,
    this.linkUrl,
    required this.isActive,
    required this.priority,
    required this.currentImageUrl,
    this.imageBytes,
    this.imageFileName,
  });
}

class BannerDeletedRequested extends BannerEvent {
  final String id;

  const BannerDeletedRequested(this.id);
}
