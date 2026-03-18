import 'package:flutter/material.dart';
import 'package:growingkids/features/user/domain/entities/login_streak_sync_result.dart';

Future<void> showLoginStreakDialog(
  BuildContext context, {
  required LoginStreakSyncResult result,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Login streak',
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _LoginStreakDialog(result: result);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _LoginStreakDialog extends StatelessWidget {
  final LoginStreakSyncResult result;

  const _LoginStreakDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final start = result.animationStartStreak.toDouble();
    final end = result.currentStreak.toDouble();
    final accent = _accentColorForStreak(result.currentStreak);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: start, end: end),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final streakValue = value.round();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: accent,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chuỗi đăng nhập',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 98,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: result.didIncrease ? 0.7 : 1.0,
                                end: 1.0,
                              ),
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.easeOutBack,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Text(
                                '$streakValue',
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  color: accent,
                                ),
                              ),
                            ),
                            if (result.didIncrease)
                              Positioned(
                                top: 8,
                                right: 56,
                                child: TweenAnimationBuilder<Offset>(
                                  tween: Tween(
                                    begin: const Offset(0, 14),
                                    end: Offset.zero,
                                  ),
                                  duration: const Duration(milliseconds: 650),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, offset, child) {
                                    return Transform.translate(
                                      offset: offset,
                                      child: child,
                                    );
                                  },
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 650),
                                    curve: Curves.easeOut,
                                    builder: (context, opacity, child) {
                                      return Opacity(
                                        opacity: opacity,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '+1',
                                        style: TextStyle(
                                          color: accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.currentStreak == 1 ? 'ngày' : 'ngày liên tiếp',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        result.didIncrease
                            ? 'Bạn vừa tăng thêm 1 ngày'
                            : 'Bạn đang giữ chuỗi hôm nay',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _accentColorForStreak(int streak) {
  if (streak >= 14) {
    return const Color(0xFFF97316);
  }

  if (streak >= 7) {
    return const Color(0xFFEAB308);
  }

  if (streak >= 3) {
    return const Color(0xFF0EA5A4);
  }

  return const Color(0xFF2F7D4E);
}
