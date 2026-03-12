import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:plant_store/features/products/presentation/widgets/index.dart';

// Dữ liệu mẫu (Fixed data)
final cartItems = [
  {
    'name': 'Monstera Deliciosa',
    'sub': 'Large, Indoor',
    'price': '\$25.00',
    'qty': 1,
    'img': 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=200',
  },
  {
    'name': 'Snake Plant',
    'sub': 'Medium, Low light',
    'price': '\$36.00',
    'qty': 2,
    'img':
        'https://images.squarespace-cdn.com/content/v1/54fbb611e4b0d7c1e151d22a/1610074066643-OP8HDJUWUH8T5MHN879K/Snake+Plant.jpg?format=1000w',
  },
  {
    'name': 'Fiddle Leaf Fig',
    'sub': 'Extra Large',
    'price': '\$45.00',
    'qty': 1,
    'img':
        'https://www.palasa.co.in/cdn/shop/articles/IMG_20220226_173034_1.jpg?crop=center&height=2048&v=1694161186&width=2048',
  },
];

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final backgroundColor = const Color(0xFFF7F9F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'My Cart',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Edit',
              style: TextStyle(
                color: cs.primary, // Màu xanh từ Theme
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. DANH SÁCH SẢN PHẨM & PROMO CODE (Có thể cuộn)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Render danh sách Cart Items
                ...cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _CartItemCard(item: item, primaryColor: cs.primary),
                  ),
                ),

                const SizedBox(height: 8),

                // Apply Promo Code Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.15), // Nền xanh nhạt
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, color: cs.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Apply Promo Code',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. PHẦN TÍNH TIỀN (Ghim ở đáy)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPriceRow('Subtotal', '\$106.00', isBold: false),
                const SizedBox(height: 12),
                _buildPriceRow('Shipping', '\$12.00', isBold: false),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$118.00',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: cs.primary, // Giá tổng màu xanh
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nút Checkout
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary, // Nền xanh từ Theme
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            color: cs.onPrimary, // Chữ đen theo design
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: cs.onPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: AppBottomNagivationBar(),
    );
  }

  // Row hiển thị giá Subtotal / Shipping
  Widget _buildPriceRow(String label, String value, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Icon dưới Bottom Nav
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color primaryColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.grey),
            if (isActive)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// Widget thẻ sản phẩm trong giỏ hàng
class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color primaryColor;

  const _CartItemCard({required this.item, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh sản phẩm
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0), // Nền xám nhạt cho ảnh
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(item['img']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Chi tiết sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Nút xóa (Icon thùng rác màu xanh)
                    Icon(Icons.delete_outline, color: primaryColor, size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['sub'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Hàng giá tiền & Điều chỉnh số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['price'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor, // Giá tiền màu xanh
                      ),
                    ),
                    // Bộ tăng giảm số lượng
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove, size: 16),
                          const SizedBox(width: 12),
                          Text(
                            item['qty'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.add, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
