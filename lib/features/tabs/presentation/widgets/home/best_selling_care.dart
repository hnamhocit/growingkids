import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/products/data/product_catalog.dart';
import 'package:growingkids/features/products/presentation/widgets/product_qr_sheet.dart';
import 'package:growingkids/features/tabs/presentation/widgets/home/product_card.dart';

class BestSellingCare extends StatelessWidget {
  const BestSellingCare({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sản phẩm chăm cây bán chạy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Tắt cuộn của Grid để cuộn theo SingleChildScrollView
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65, // Tỉ lệ khung hình (chiều rộng / chiều cao)
          ),
          itemCount: ProductCatalog.items.length,
          itemBuilder: (context, index) {
            final product = ProductCatalog.items[index];

            return ProductCard(
              product: product,
              onTap: () {
                context.pushNamed(
                  RoutesName.productDetail,
                  pathParameters: {'productId': product.id},
                );
              },
              onShowQr: () => showProductQrSheet(context, product: product),
            );
          },
        ),
      ],
    );
  }
}
