import 'package:flutter/material.dart';

class AppBottomNagivationBar extends StatelessWidget {
  const AppBottomNagivationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 20,
      ), // Padding trên/dưới cho thanh điều hướng
      decoration: BoxDecoration(
        color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment
              .center, // Căn giữa tất cả các icon theo chiều dọc
          children: [
            _buildNavItem(Icons.home_filled, 'Home', true, context),
            _buildNavItem(Icons.grid_view_rounded, 'Catalog', false, context),

            // NÚT TRUNG TÂM NỔI BẬT NẰM CÙNG HÀNG
            _buildCenterButton(context),

            _buildNavItem(Icons.eco_outlined, 'My Plants', false, context),
            _buildNavItem(Icons.person_outline, 'Profile', false, context),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // TODO: Xử lý khi bấm nút Scan/Camera
      },
      child: Container(
        width: 56, // Kích thước nút
        height: 56,
        decoration: BoxDecoration(
          color: cs.primary, // Màu xanh sáng
          shape: BoxShape.circle,
          boxShadow: [
            // Thêm một lớp bóng đổ màu xanh mờ để tạo cảm giác "Glow" (phát sáng)
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons
              .document_scanner_outlined, // Thay bằng icon bạn muốn (ví dụ: Icons.camera_alt)
          color: cs.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  // Giữ nguyên hàm _buildNavItem cũ của bạn
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    BuildContext context,
  ) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? cs.primary : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? cs.primary : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
