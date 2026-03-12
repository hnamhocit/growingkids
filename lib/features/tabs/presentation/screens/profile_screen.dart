import 'package:flutter/material.dart';
import 'package:plant_store/features/products/presentation/widgets/app_bottom_nagivation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Thêm SingleTickerProviderStateMixin để chạy Animation
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fireAnimationController;
  late Animation<double> _fireScaleAnimation;

  // Dữ liệu Mock (Bạn có thể thay bằng dữ liệu thật từ API)
  final String userName = 'Alex Green';
  final String bio = 'Urban jungle creator 🌿 | Plant parent of 30+';
  final int sharedPosts = 4250;
  final int purchasedItems = 128;
  final int greenPoints = 15400;
  final int rank = 2; // Thử đổi thành 1, 2, 3 hoặc 10 để xem màu sắc thay đổi
  final int streakDays = 14;

  @override
  void initState() {
    super.initState();
    // Cài đặt hiệu ứng đập (pulse) cho ngọn lửa
    _fireAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Lặp lại liên tục và đảo ngược

    _fireScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _fireAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fireAnimationController.dispose();
    super.dispose();
  }

  // Hàm chuyển đổi số lớn (VD: 4250 -> 4.2k)
  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toString();
  }

  // Hàm lấy màu Huy hiệu theo Top
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Vàng (Gold)
      case 2:
        return const Color(0xFFC0C0C0); // Bạc (Silver)
      case 3:
        return const Color(0xFFCD7F32); // Đồng (Bronze)
      default:
        return Colors.grey.shade400; // Xám cho các top khác
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final backgroundColor = const Color(0xFFF7F9F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 1. AVATAR & BIO
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. STATS (POSTS & PURCHASES)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      'Shared Posts',
                      _formatNumber(sharedPosts),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                    _buildStatColumn(
                      'Purchased',
                      _formatNumber(purchasedItems),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. GAMIFICATION (POINTS, RANK, STREAK)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Green Points
                  Expanded(
                    child: _buildGamificationCard(
                      title: 'Points',
                      value: _formatNumber(greenPoints),
                      icon: Icons.eco,
                      iconColor: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Leaderboard Rank
                  Expanded(
                    child: _buildGamificationCard(
                      title: 'Top',
                      value: '#$rank',
                      icon: Icons.emoji_events,
                      iconColor: _getRankColor(rank),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Login Streak (Có Animation ngọn lửa)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Animated Fire Icon
                          ScaleTransition(
                            scale: _fireScaleAnimation,
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.deepOrange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$streakDays Days',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Streak',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. MENU DƯỚI CÙNG
            _buildMenuOption(Icons.edit_outlined, 'Edit Profile'),
            _buildMenuOption(Icons.favorite_border, 'My Favorites'),
            _buildMenuOption(Icons.history, 'Order History'),
            _buildMenuOption(Icons.help_outline, 'Help & Support'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

      // 5. BOTTOM NAVIGATION BAR (Giữ đồng bộ với màn Home/Cart)
      bottomNavigationBar: AppBottomNagivationBar(),
    );
  }

  // Helper Widet cho Stats (Bài viết, Sản phẩm)
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  // Helper Widget cho Gamification Card (Điểm, Rank)
  Widget _buildGamificationCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // Helper Widget cho Menu List
  Widget _buildMenuOption(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }

  // Helper Widget cho Bottom Nav
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color primaryColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? primaryColor : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? primaryColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
