import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';
import 'package:growingkids/features/tabs/presentation/widgets/home/index.dart';

const _notificationBadgeCount = 4;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leadingWidth: 150,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: _HomeBrand(),
        ),
        actions: [
          _NotificationsButton(
            count: _notificationBadgeCount,
            onPressed: () {
              context.pushNamed(RoutesName.tabNotifications);
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: cs.onSurface),
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
                  icon: Icon(Icons.person_outline, color: cs.onSurface),
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

class _HomeBrand extends StatelessWidget {
  const _HomeBrand();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'GrowingKids',
        style: TextStyle(
          color: cs.primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _NotificationsButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: cs.onSurface),
            onPressed: onPressed,
          ),
          if (count > 0)
            Positioned(
              top: 6,
              right: 5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9485F),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
