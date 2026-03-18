import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/core/extensions/user_role_access.dart';
import 'package:growingkids/features/banners/domain/entities/app_banner.dart';
import 'package:growingkids/features/banners/presentation/bloc/banner_bloc.dart';
import 'package:growingkids/features/banners/presentation/screens/banner_form_screen.dart';

class BannersScreen extends StatelessWidget {
  const BannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.isAdmin) {
      return const _BannerAccessDeniedView();
    }

    return const _BannersView();
  }
}

class _BannerAccessDeniedView extends StatelessWidget {
  const _BannerAccessDeniedView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
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
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Bạn không có quyền quản lý banner.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _BannersView extends StatelessWidget {
  const _BannersView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.goNamed(RoutesName.tabHome);
          },
        ),
        title: Text(
          'Tất cả banner',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: BlocConsumer<BannerBloc, BannerState>(
        listener: (context, state) {
          if (state is BannerLoaded && state.feedbackMessage != null) {
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
          if (state is BannerLoading || state is BannerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BannerFailure) {
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

          if (state is! BannerLoaded) {
            return const SizedBox.shrink();
          }

          if (state.banners.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Chưa có banner nào để hiển thị.',
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
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: state.banners.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final banner = state.banners[index];
                  return _BannerListCard(
                    banner: banner,
                    onEdit: () => _openBannerFormPage(context, banner: banner),
                    onDelete: () => _confirmDeleteBanner(context, banner),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBannerFormPage(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text(
          'Thêm banner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BannerListCard extends StatelessWidget {
  final AppBanner banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerListCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 16 / 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Theme.of(
                        context,
                      ).cardColor.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(999),
                      child: PopupMenuButton<_BannerCardAction>(
                        icon: const Icon(Icons.more_horiz_rounded),
                        onSelected: (action) {
                          switch (action) {
                            case _BannerCardAction.edit:
                              onEdit();
                              return;
                            case _BannerCardAction.delete:
                              onDelete();
                              return;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _BannerCardAction.edit,
                            child: Text('Sửa'),
                          ),
                          PopupMenuItem(
                            value: _BannerCardAction.delete,
                            child: Text('Xoá'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BannerMetaChip(
                      label: banner.isActive ? 'Đang bật' : 'Đang tắt',
                      backgroundColor: banner.isActive
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF3F4F6),
                      textColor: banner.isActive
                          ? const Color(0xFF166534)
                          : const Color(0xFF4B5563),
                    ),
                    _BannerMetaChip(
                      label: 'Ưu tiên ${banner.priority}',
                      backgroundColor: const Color(0xFFEEF2FF),
                      textColor: const Color(0xFF3730A3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    banner.subtitle!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    banner.linkUrl!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

class _BannerMetaChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _BannerMetaChip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

Future<void> _openBannerFormPage(BuildContext context, {AppBanner? banner}) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => BannerFormScreen(banner: banner)));
}

Future<void> _confirmDeleteBanner(
  BuildContext context,
  AppBanner banner,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final cs = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        title: const Text('Xoá banner'),
        content: Text('Bạn có chắc muốn xoá banner "${banner.title}" không?'),
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

  if (confirmed != true || !context.mounted) {
    return;
  }

  context.read<BannerBloc>().add(BannerDeletedRequested(banner.id));
}

enum _BannerCardAction { edit, delete }
