part of 'category_bloc.dart';

sealed class CategoryEvent {
  const CategoryEvent();
}

class CategoriesRequested extends CategoryEvent {
  final int? limit;

  const CategoriesRequested({this.limit});
}

class CategoryCreatedRequested extends CategoryEvent {
  final String name;
  final String? description;
  final Uint8List? imageBytes;
  final String? imageFileName;

  const CategoryCreatedRequested({
    required this.name,
    this.description,
    this.imageBytes,
    this.imageFileName,
  });
}

class CategoryUpdatedRequested extends CategoryEvent {
  final String id;
  final String name;
  final String? description;
  final String? currentThumbnailUrl;
  final Uint8List? imageBytes;
  final String? imageFileName;

  const CategoryUpdatedRequested({
    required this.id,
    required this.name,
    this.description,
    this.currentThumbnailUrl,
    this.imageBytes,
    this.imageFileName,
  });
}

class CategoryDeletedRequested extends CategoryEvent {
  final String id;

  const CategoryDeletedRequested(this.id);
}
