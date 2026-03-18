import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/categories/domain/entities/category.dart';
import 'package:growingkids/features/categories/presentation/bloc/category_bloc.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CategorySectionView();
  }
}

class _CategorySectionView extends StatelessWidget {
  const _CategorySectionView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Danh mục',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.pushNamed(RoutesName.tabCatalog),
              style: TextButton.styleFrom(
                foregroundColor: cs.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading || state is CategoryInitial) {
              return const SizedBox(
                height: 110,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is CategoryFailure) {
              return SizedBox(
                height: 110,
                child: Center(
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            if (state is! CategoryLoaded || state.categories.isEmpty) {
              return SizedBox(
                height: 110,
                child: Center(
                  child: Text(
                    'Chưa có danh mục nào.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            final visibleCategories = state.categories.take(4).toList();

            return SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visibleCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return _CategoryCircleItem(
                    category: visibleCategories[index],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCircleItem extends StatelessWidget {
  final Category category;

  const _CategoryCircleItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: _CategoryCircleImage(imageUrl: category.thumbnailUrl),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

class _CategoryCircleImage extends StatelessWidget {
  final String? imageUrl;

  const _CategoryCircleImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return const _CategoryCirclePlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _CategoryCirclePlaceholder();
      },
    );
  }
}

class _CategoryCirclePlaceholder extends StatelessWidget {
  const _CategoryCirclePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EFEA),
      alignment: Alignment.center,
      child: const Icon(Icons.spa_rounded, color: Color(0xFF2F7D4E), size: 28),
    );
  }
}
