import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hồ sơ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: authState is AuthAuthenticated
          ? _AuthenticatedProfile(userId: authState.user.id)
          : const _GuestProfile(),
      bottomNavigationBar: const AppBottomNagivationBar(
        activeTab: AppTab.profile,
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            const _ProfileAvatar(photoUrl: null, radius: 54),
            const SizedBox(height: 14),
            const Text(
              'Bạn chưa đăng nhập',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để lưu cây yêu thích, theo dõi đơn hàng và cá nhân hóa trải nghiệm chăm cây của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const _WideStatCard(
                    leftValue: '--',
                    leftLabel: 'Bài chia sẻ',
                    rightValue: '--',
                    rightLabel: 'Đã mua',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.eco_outlined,
                          iconColor: Color(0xFF2F7D4E),
                          value: '--',
                          label: 'Điểm xanh',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.workspace_premium_outlined,
                          iconColor: Color(0xFF9CA3AF),
                          value: '--',
                          label: 'Kỷ lục',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.local_fire_department_outlined,
                          iconColor: Color(0xFFFF6B3D),
                          value: '--',
                          label: 'Chuỗi ngày',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                context.pushNamed(RoutesName.authEnter);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF2F7D4E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Đăng nhập / Đăng ký',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedProfile extends StatelessWidget {
  final String userId;

  const _AuthenticatedProfile({required this.userId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userState = context.watch<UserBloc>().state;

    String displayName = 'Người dùng';
    String email = '';
    String? photoUrl;
    String role = 'Người yêu cây';
    DateTime? joinedAt;
    int greenPoint = 0;
    int currentStreak = 0;
    int longestStreak = 0;

    if (authState is AuthAuthenticated) {
      displayName =
          authState.user.userMetadata?['display_name'] as String? ??
          displayName;
      email = authState.user.email ?? '';
    }

    if (userState is UserLoaded && userState.profile.id == userId) {
      displayName = userState.profile.displayName;
      photoUrl = userState.profile.photoUrl;
      role = _roleHeadline(userState.profile.role.name);
      joinedAt = userState.profile.createdAt;
      greenPoint = userState.profile.greenPoint;
      currentStreak = userState.profile.currentStreak;
      longestStreak = userState.profile.longestStreak;
    }

    final stats = _ProfileStats.fromUser(
      userId: userId,
      greenPoint: greenPoint,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 2),
            Center(child: _ProfileAvatar(photoUrl: photoUrl, radius: 54)),
            const SizedBox(height: 14),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _buildProfileSubtitle(
                role: role,
                joinedAt: joinedAt,
                email: email,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (userState is UserFailure) ...[
              const SizedBox(height: 10),
              Text(
                userState.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _WideStatCard(
              leftValue: stats.sharedPosts,
              leftLabel: 'Bài chia sẻ',
              rightValue: stats.purchased,
              rightLabel: 'Đã mua',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.eco_rounded,
                    iconColor: const Color(0xFF2F7D4E),
                    value: stats.greenPoint,
                    label: 'Điểm xanh',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: const Color(0xFFB8BDC7),
                    value: stats.longestStreak,
                    label: 'Kỷ lục',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF6B3D),
                    value: stats.currentStreak,
                    label: 'Chuỗi ngày',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ProfileMenuTile(
              icon: Icons.edit_outlined,
              title: 'Chỉnh sửa hồ sơ',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.favorite_border_rounded,
              title: 'Sản phẩm yêu thích',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.history_rounded,
              title: 'Lịch sử đơn hàng',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Trợ giúp và hỗ trợ',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Đăng xuất',
              onTap: () {
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              iconColor: const Color(0xFFD9485F),
              titleColor: const Color(0xFFD9485F),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;

  const _ProfileAvatar({required this.photoUrl, required this.radius});

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    return Container(
      width: diameter + 8,
      height: diameter + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2F7D4E), width: 2.5),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE9ECE6),
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? const Icon(Icons.person, size: 44, color: Colors.black45)
            : null,
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;

  const _WideStatCard({
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _surfaceDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _StatTextBlock(value: leftValue, label: leftLabel),
          ),
          Container(width: 1, height: 50, color: const Color(0xFFF0F1EC)),
          Expanded(
            child: _StatTextBlock(value: rightValue, label: rightLabel),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: _surfaceDecoration(),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatTextBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatTextBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.black,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: _surfaceDecoration(shadow: false),
          child: Row(
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStats {
  final String sharedPosts;
  final String purchased;
  final String greenPoint;
  final String longestStreak;
  final String currentStreak;

  const _ProfileStats({
    required this.sharedPosts,
    required this.purchased,
    required this.greenPoint,
    required this.longestStreak,
    required this.currentStreak,
  });

  factory _ProfileStats.fromUser({
    required String userId,
    required int greenPoint,
    required int currentStreak,
    required int longestStreak,
  }) {
    final seed = userId.codeUnits.fold<int>(0, (sum, char) => sum + char);

    return _ProfileStats(
      sharedPosts: '${((seed % 36) + 12) / 10}k',
      purchased: '${(seed % 140) + 18}',
      greenPoint: _formatGreenPoint(greenPoint),
      longestStreak: _formatDayCount(longestStreak),
      currentStreak: _formatDayCount(currentStreak),
    );
  }
}

String _formatGreenPoint(int value) {
  if (value >= 1000) {
    final formatted = (value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1);
    return '${formatted}k';
  }

  return '$value';
}

String _formatDayCount(int value) {
  return '$value ngày';
}

String _buildProfileSubtitle({
  required String role,
  required DateTime? joinedAt,
  required String email,
}) {
  final joinedText = joinedAt == null
      ? 'Người đồng hành cùng GrowingKids'
      : 'Tham gia từ ${joinedAt.year}';

  if (email.isEmpty) {
    return '$role | $joinedText';
  }

  return '$role | $joinedText';
}

String _roleHeadline(String role) {
  return switch (role) {
    'admin' => 'Người gieo mầm cộng đồng',
    'staff' => 'Chuyên gia chăm cây',
    'customer' => 'Người yêu cây đô thị',
    _ => 'Người yêu cây',
  };
}

BoxDecoration _surfaceDecoration({bool shadow = true}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: shadow
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ]
        : null,
  );
}
