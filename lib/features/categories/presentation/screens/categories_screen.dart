import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/core/extensions/user_role_access.dart';
import 'package:growingkids/features/categories/domain/entities/category.dart';
import 'package:growingkids/features/categories/presentation/bloc/category_bloc.dart';
import 'package:growingkids/features/categories/presentation/screens/category_form_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CategoriesView();
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final canManageCategories = context.isAdmin;
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.goNamed(RoutesName.tabHome);
          },
        ),
        title: Text(
          'Tất cả danh mục',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoaded && state.feedbackMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.feedbackMessage!),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          if (state is! CategoryLoaded) {
            return const SizedBox.shrink();
          }

          if (state.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Chưa có danh mục nào để hiển thị.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: state.categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return _CategoryGridCard(
                    category: category,
                    canManage: canManageCategories,
                    onEdit: () =>
                        _openCategoryFormPage(context, category: category),
                    onDelete: () =>
                        _confirmDeleteCategory(context, category: category),
                  );
                },
              ),
              if (state.isSubmitting)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: canManageCategories
          ? FloatingActionButton.extended(
              onPressed: () => _openCategoryFormPage(context),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text(
                'Thêm danh mục',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }
}

class _CategoryGridCard extends StatelessWidget {
  final Category category;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryGridCard({
    required this.category,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: _CategoryImage(
                      imageUrl: category.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (canManage)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Theme.of(
                        context,
                      ).cardColor.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999),
                      child: PopupMenuButton<_CategoryCardAction>(
                        icon: const Icon(Icons.more_horiz_rounded),
                        onSelected: (action) {
                          switch (action) {
                            case _CategoryCardAction.edit:
                              onEdit?.call();
                              return;
                            case _CategoryCardAction.delete:
                              onDelete?.call();
                              return;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _CategoryCardAction.edit,
                            child: Text('Sửa'),
                          ),
                          PopupMenuItem(
                            value: _CategoryCardAction.delete,
                            child: Text('Xoá'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (category.description != null &&
                    category.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    category.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;

  const _CategoryImage({required this.imageUrl, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return const _CategoryImagePlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const _CategoryImagePlaceholder();
      },
    );
  }
}

class _CategoryImagePlaceholder extends StatelessWidget {
  const _CategoryImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_florist_rounded,
        color: Color(0xFF2F7D4E),
        size: 44,
      ),
    );
  }
}

Future<void> _openCategoryFormPage(
  BuildContext context, {
  Category? category,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (pageContext) {
        return BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: CategoryFormScreen(category: category),
        );
      },
    ),
  );
}

Future<void> _confirmDeleteCategory(
  BuildContext context, {
  required Category category,
}) async {
  final cs = Theme.of(context).colorScheme;
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Xoá danh mục'),
        content: Text(
          'Bạn có chắc muốn xoá danh mục "${category.name}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
            child: const Text('Xoá'),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true || !context.mounted) {
    return;
  }

  context.read<CategoryBloc>().add(CategoryDeletedRequested(category.id));
}

enum _CategoryCardAction { edit, delete }
