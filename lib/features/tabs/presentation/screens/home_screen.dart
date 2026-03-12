import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';
import 'package:growingkids/features/tabs/presentation/widgets/home/index.dart';

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
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated) {
                return IconButton(
                  onPressed: () {
                    context.pushNamed(RoutesName.authEnter);
                  },
                  icon: const Icon(Icons.person_outline, color: Colors.black),
                );
              }

              final userState = context.watch<UserBloc>().state;
              final photoUrl = userState is UserLoaded
                  ? userState.profile.photoUrl
                  : null;

              return IconButton(
                onPressed: () {
                  context.goNamed(RoutesName.tabProfile);
                },
                icon: _UserAvatar(photoUrl: photoUrl),
              );
            },
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

      bottomNavigationBar: const AppBottomNagivationBar(activeTab: AppTab.home),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? photoUrl;

  const _UserAvatar({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return const CircleAvatar(
        radius: 13,
        backgroundColor: Color(0xFFE5E7EB),
        child: Icon(Icons.person, color: Colors.black, size: 16),
      );
    }

    return CircleAvatar(
      radius: 13,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: NetworkImage(photoUrl!),
      onBackgroundImageError: (_, _) {},
      child: null,
    );
  }
}
