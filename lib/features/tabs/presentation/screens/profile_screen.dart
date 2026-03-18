import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/app/theme/theme_cubit.dart';
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Hồ sơ',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings_outlined,
                color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          children: [
            const _ProfileAvatar(photoUrl: null, radius: 54),
            const SizedBox(height: 14),
            Text(
              'Bạn chưa đăng nhập',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để lưu cây yêu thích, theo dõi đơn hàng và cá nhân hóa trải nghiệm chăm cây của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
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
    final cs = Theme.of(context).colorScheme;
    final themeMode = context.watch<ThemeCubit>().state;
    final isDarkModeEnabled = themeMode == ThemeMode.dark;

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
      role = _roleLabel(userState.profile.role.name);
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
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
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
                color: cs.onSurfaceVariant,
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
            _ThemeModeTile(
              value: isDarkModeEnabled,
              onChanged: (value) {
                context.read<ThemeCubit>().setDarkMode(value);
              },
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: diameter + 8,
      height: diameter + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 2.5),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: cs.surfaceContainerHighest,
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? Icon(Icons.person, size: 44, color: cs.onSurfaceVariant)
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
      decoration: _surfaceDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: _StatTextBlock(value: leftValue, label: leftLabel),
          ),
          Container(
            width: 1,
            height: 50,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: _surfaceDecoration(context),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
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
  final Color? iconColor;
  final Color? titleColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: _surfaceDecoration(context, shadow: false),
          child: Row(
            children: [
              Icon(icon, size: 24, color: iconColor ?? cs.onSurface),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ThemeModeTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _surfaceDecoration(context, shadow: false),
      child: Row(
        children: [
          Icon(Icons.dark_mode_outlined, color: cs.onSurface, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chế độ tối',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lưu lại lựa chọn giao diện cho lần mở sau.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
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

String _roleLabel(String role) {
  return switch (role) {
    'admin' => 'Admin',
    'staff' => 'Nhân viên',
    'customer' => 'Khách hàng',
    _ => 'Người yêu cây',
  };
}

BoxDecoration _surfaceDecoration(BuildContext context, {bool shadow = true}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  return BoxDecoration(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
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
