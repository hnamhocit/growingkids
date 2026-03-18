import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';

class MyPlantsScreen extends StatelessWidget {
  const MyPlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cây của tôi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: authState is AuthAuthenticated
          ? const _AuthenticatedMyPlants()
          : const _GuestMyPlants(),
      bottomNavigationBar: const AppBottomNagivationBar(
        activeTab: AppTab.myPlants,
      ),
    );
  }
}

class _GuestMyPlants extends StatelessWidget {
  const _GuestMyPlants();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroCard(
              title: 'Chăm sóc cây mỗi ngày',
              description:
                  'Đăng nhập để xem khu vườn của bạn theo dạng lưới và biết cây nào đang cần tưới nước hôm nay.',
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Xem trước khu vườn'),
            const SizedBox(height: 12),
            _PlantsSummaryBanner(items: _samplePlants),
            const SizedBox(height: 16),
            _PlantsGrid(items: _samplePlants, isPreview: true),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pushNamed(RoutesName.authEnter),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF2F7D4E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Đăng nhập để bắt đầu',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedMyPlants extends StatelessWidget {
  const _AuthenticatedMyPlants();

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;

    if (userState is UserLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userState is UserFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            userState.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final profile = userState is UserLoaded ? userState.profile : null;
    final displayName = profile?.displayName ?? 'Người yêu cây';
    final needsWateringCount = _samplePlants
        .where((item) => item.needsWatering)
        .length;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(
              title: 'Xin chào $displayName',
              description:
                  'Khu vườn của bạn hôm nay có $needsWateringCount cây cần ưu tiên tưới. Xem nhanh từng chậu bên dưới để chăm cây kịp lúc.',
            ),
            const SizedBox(height: 22),
            _PlantsSummaryBanner(items: _samplePlants),
            const SizedBox(height: 12),
            const _SectionTitle('Khu vườn của tôi'),
            const SizedBox(height: 12),
            _PlantsGrid(items: _samplePlants),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String description;

  const _HeroCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F7D4E), Color(0xFF5D9B6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    );
  }
}

class _PlantsSummaryBanner extends StatelessWidget {
  final List<_PlantCareItem> items;

  const _PlantsSummaryBanner({required this.items});

  @override
  Widget build(BuildContext context) {
    final needsWatering = items.where((item) => item.needsWatering).toList();
    final safePlants = items.length - needsWatering.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _BannerMetric(
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF2D8CFF),
              value: '${needsWatering.length}',
              label: 'Cần tưới ngay',
            ),
          ),
          Container(width: 1, height: 56, color: const Color(0xFFE9ECE6)),
          Expanded(
            child: _BannerMetric(
              icon: Icons.eco_rounded,
              color: const Color(0xFF2F7D4E),
              value: '$safePlants',
              label: 'Đang ổn định',
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerMetric extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _BannerMetric({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlantsGrid extends StatelessWidget {
  final List<_PlantCareItem> items;
  final bool isPreview;

  const _PlantsGrid({required this.items, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 760 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            return _PlantGridCard(item: items[index], isPreview: isPreview);
          },
        );
      },
    );
  }
}

class _PlantGridCard extends StatelessWidget {
  final _PlantCareItem item;
  final bool isPreview;

  const _PlantGridCard({required this.item, required this.isPreview});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.needsWatering
        ? const Color(0xFFE76F51)
        : const Color(0xFF2F7D4E);
    final statusBackground = item.needsWatering
        ? const Color(0xFFFFE4DC)
        : const Color(0xFFE4F3E7);

    return Opacity(
      opacity: isPreview ? 0.88 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.needsWatering ? 'Cần tưới' : 'Ổn định',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
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
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.roomLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        size: 16,
                        color: Color(0xFF2D8CFF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${item.daysSinceWatered} ngày chưa tưới',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: item.moistureLevel,
                      backgroundColor: const Color(0xFFF0F2ED),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item.needsWatering
                            ? const Color(0xFFE76F51)
                            : const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.statusText,
                    style: TextStyle(
                      color: item.needsWatering
                          ? const Color(0xFFD9485F)
                          : Colors.grey.shade700,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantCareItem {
  final String name;
  final String roomLabel;
  final String imageUrl;
  final int daysSinceWatered;
  final int wateringIntervalDays;

  const _PlantCareItem({
    required this.name,
    required this.roomLabel,
    required this.imageUrl,
    required this.daysSinceWatered,
    required this.wateringIntervalDays,
  });

  bool get needsWatering => daysSinceWatered >= wateringIntervalDays;

  double get moistureLevel {
    final ratio = 1 - (daysSinceWatered / (wateringIntervalDays + 2));
    return ratio.clamp(0.12, 0.96);
  }

  String get statusText {
    if (needsWatering) {
      final overdue = daysSinceWatered - wateringIntervalDays;
      if (overdue <= 0) {
        return 'Đến lịch tưới hôm nay';
      }
      return 'Trễ $overdue ngày, nên tưới sớm';
    }

    return 'Còn ${wateringIntervalDays - daysSinceWatered} ngày nữa mới cần tưới';
  }
}

const _samplePlants = [
  _PlantCareItem(
    name: 'Monstera Deliciosa',
    roomLabel: 'Phong khach',
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=900',
    daysSinceWatered: 3,
    wateringIntervalDays: 2,
  ),
  _PlantCareItem(
    name: 'Snake Plant',
    roomLabel: 'Goc lam viec',
    imageUrl:
        'https://commons.wikimedia.org/wiki/Special:FilePath/Bed%20%2B%20Snake%20Plant%20%28Unsplash%29.jpg',
    daysSinceWatered: 1,
    wateringIntervalDays: 4,
  ),
  _PlantCareItem(
    name: 'Peace Lily',
    roomLabel: 'Cua so bep',
    imageUrl:
        'https://images.unsplash.com/photo-1463154545680-d59320fd685d?w=900',
    daysSinceWatered: 5,
    wateringIntervalDays: 3,
  ),
  _PlantCareItem(
    name: 'Fiddle Leaf Fig',
    roomLabel: 'Ban cong',
    imageUrl:
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=900',
    daysSinceWatered: 2,
    wateringIntervalDays: 3,
  ),
];
