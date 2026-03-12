import 'package:flutter/material.dart';
import 'package:growingkids/features/tabs/presentation/widgets/home/product_card.dart';

final products = [
  {
    'name': 'GreenGold Liquid',
    'sub': 'All-purpose 500ml',
    'price': '\$14.50',
    'img':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREhM_TgK4EbEb7OksCE0QZXlUOlFSziYhKoQ&s',
    'tag': 'TOP PICK',
    'bgColor': 0xFFF1C40F, // Nền vàng cam
  },
  {
    'name': 'Premium Aroid Mix',
    'sub': 'Chunky Blend 5L',
    'price': '\$22.00',
    'img':
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=400', // Đất trồng
    'bgColor': 0xFF2C3E50,
  },
  {
    'name': 'Slow Release Sticks',
    'sub': 'Pack of 20',
    'price': '\$9.00',
    'img':
        'https://5.imimg.com/data5/SELLER/Default/2021/8/VU/HT/NV/116172416/stick-image1-blur-jpg.jpg',
    'bgColor': 0xFF95A5A6,
  },
  {
    'name': 'Pure Neem Oil',
    'sub': 'Pest Control 250ml',
    'price': '\$16.50',
    'img':
        'https://i5.walmartimages.com/seo/Majestic-Pure-Neem-Oil-100-Pure-Cold-Pressed-Great-For-Skin-Care-Hair-Care-Massage-Oil-Nails-Acne-Moisturizer-for-Dry-Skin-4-fl-oz_dc0577f3-a8f8-4ce3-8b4e-eed5d7310a54.4828ab425ff3c44d04eb55a28577e088.jpeg',
    'bgColor': 0xFF27AE60,
  },
];

class BestSellingCare extends StatelessWidget {
  const BestSellingCare({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best-selling Care',
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
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return ProductCard(product: p);
          },
        ),
      ],
    );
  }
}
