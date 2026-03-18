import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';

enum AppTab { home, scan, myPlants, profile }

class AppBottomNagivationBar extends StatelessWidget {
  final AppTab activeTab;

  const AppBottomNagivationBar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 20,
      ), // Padding trên/dưới cho thanh điều hướng
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(
              icon: Icons.home_filled,
              label: 'Trang chủ',
              isActive: activeTab == AppTab.home,
              onTap: () => _goToTab(context, AppTab.home),
              context: context,
            ),
            _buildNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Danh mục',
              isActive: false,
              onTap: () {},
              context: context,
            ),
            _buildCenterButton(context, isActive: activeTab == AppTab.scan),
            _buildNavItem(
              icon: Icons.eco_outlined,
              label: 'Cây của tôi',
              isActive: activeTab == AppTab.myPlants,
              onTap: () => _goToTab(context, AppTab.myPlants),
              context: context,
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Hồ sơ',
              isActive: activeTab == AppTab.profile,
              onTap: () => _goToTab(context, AppTab.profile),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, {required bool isActive}) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _goToTab(context, AppTab.scan),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: cs.onPrimary, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.document_scanner_outlined,
          color: cs.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  void _goToTab(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.home:
        context.goNamed(RoutesName.tabHome);
        return;
      case AppTab.scan:
        context.goNamed(RoutesName.tabScan);
        return;
      case AppTab.myPlants:
        context.goNamed(RoutesName.tabMyPlants);
        return;
      case AppTab.profile:
        context.goNamed(RoutesName.tabProfile);
        return;
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? cs.primary : cs.onSurfaceVariant),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? cs.primary : cs.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
