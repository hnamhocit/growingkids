import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_store/app/router/routes_name.dart';
import 'package:plant_store/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';
import 'package:plant_store/features/tabs/presentation/widgets/home/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF7F9F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      // 1. APP BAR TÙY CHỈNH
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  context.pushNamed(RoutesName.tabCart);
                },
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E), // Màu xanh chủ đạo
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              context.pushNamed(RoutesName.authEnter);
            },
            icon: const Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),

      // 2. NỘI DUNG CHÍNH (Có thể cuộn)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSearchBar(),
            const SizedBox(height: 24),
            PromoBanner(),
            const SizedBox(height: 24),
            CategorySection(),
            const SizedBox(height: 24),
            BestSellingCare(),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNagivationBar(),
    );
  }
}
