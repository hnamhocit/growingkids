import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/products/data/product_catalog.dart';
import 'package:growingkids/features/products/domain/entities/product.dart';
import 'package:growingkids/features/products/domain/services/app_qr_link_codec.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  void _addToCart(BuildContext context, Product product) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${product.name} vào giỏ hàng.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Xem giỏ',
            onPressed: () {
              context.pushNamed(RoutesName.tabCart);
            },
          ),
        ),
      );
  }

  void _buyNow(BuildContext context) {
    context.pushNamed(RoutesName.tabCart);
  }

  Future<void> _shareProduct(BuildContext context, Product product) async {
    final deepLink = AppQrLinkCodec.encodeProductDetail(product.id);
    await Share.share(
      'Xem ${product.name} trên GrowingKids\n$deepLink',
      subject: product.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ProductCatalog.findById(productId);
    final theme = Theme.of(context);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Không tìm thấy sản phẩm cho mã này.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.goNamed(RoutesName.tabHome),
                  child: const Text('Về trang chủ'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            onPressed: () => _shareProduct(context, product),
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Chia sẻ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductHero(product: product),
            const SizedBox(height: 24),
            Text(
              product.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.subtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              product.priceLabel,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mô tả',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Điểm nổi bật',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final highlight in product.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        highlight,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _addToCart(context, product),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Thêm vào giỏ'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () => _buyNow(context),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.credit_card_rounded),
                    label: const Text('Mua ngay'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  final Product product;

  const _ProductHero({required this.product});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.08,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    product.backgroundColor.withValues(alpha: 0.95),
                    product.backgroundColor.withValues(alpha: 0.48),
                  ],
                ),
              ),
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
            if (product.tag != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    product.tag!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
