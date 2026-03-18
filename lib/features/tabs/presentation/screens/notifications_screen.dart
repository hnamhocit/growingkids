import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Đánh dấu đã đọc',
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        itemCount: _notifications.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Bạn có 4 thông báo mới hôm nay. Đừng bỏ lỡ ưu đãi và cập nhật đơn hàng.',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final item = _notifications[index - 1];
          return _NotificationCard(item: item);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.tint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.tint, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (item.isNew)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F7D4E),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.time,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color tint;
  final String title;
  final String message;
  final String time;
  final bool isNew;

  const _NotificationItem({
    required this.icon,
    required this.tint,
    required this.title,
    required this.message,
    required this.time,
    required this.isNew,
  });
}

const _notifications = [
  _NotificationItem(
    icon: Icons.local_shipping_outlined,
    tint: Color(0xFF2F7D4E),
    title: 'Đơn hàng đang giao',
    message:
        'Gói hàng phân bón hữu cơ của bạn đang trên đường và dự kiến tới trong hôm nay.',
    time: '10 phút trước',
    isNew: true,
  ),
  _NotificationItem(
    icon: Icons.local_offer_outlined,
    tint: Color(0xFFFF8A34),
    title: 'Ưu đãi cuối tuần',
    message: 'Giảm 20% cho nhóm đất trồng và chậu sinh học đến hết Chủ nhật.',
    time: '1 giờ trước',
    isNew: true,
  ),
  _NotificationItem(
    icon: Icons.favorite_outline,
    tint: Color(0xFFD9485F),
    title: 'Sản phẩm yêu thích đã có hàng',
    message:
        'Chậu gốm men xanh bạn lưu trước đó đã được nhập lại với số lượng giới hạn.',
    time: 'Hôm nay, 08:15',
    isNew: true,
  ),
  _NotificationItem(
    icon: Icons.eco_outlined,
    tint: Color(0xFF2F7D4E),
    title: 'Mẹo chăm cây mới',
    message:
        'GrowingKids vừa gửi một hướng dẫn mới để giúp cây trong nhà phát triển ổn định hơn.',
    time: 'Hôm qua',
    isNew: false,
  ),
];
