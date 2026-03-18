import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/banners/domain/entities/app_banner.dart';
import 'package:growingkids/features/banners/presentation/bloc/banner_bloc.dart';
import 'package:growingkids/core/extensions/user_role_access.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final canManageBanners = context.isAdmin;

    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, state) {
        final featuredBanner = switch (state) {
          BannerLoaded(:final banners) => () {
            final activeBanners = banners
                .where((banner) => banner.isActive)
                .toList();
            return activeBanners.isEmpty ? null : activeBanners.first;
          }(),
          _ => null,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nổi bật hôm nay',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                if (canManageBanners)
                  TextButton(
                    onPressed: () {
                      context.pushNamed(RoutesName.tabBanners);
                    },
                    child: const Text(
                      'Tất cả banner',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (state is BannerLoading || state is BannerInitial)
              const _PromoBannerSkeleton()
            else if (featuredBanner == null)
              const _PromoBannerFallback()
            else
              _PromoBannerCard(banner: featuredBanner),
          ],
        );
      },
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final AppBanner banner;

  const _PromoBannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBannerTap(context, banner),
      child: SizedBox(
        height: 188,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF2B3A32),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1F2937),
                          Color(0xFF334155),
                          Color(0xFF14532D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      if (banner.subtitle != null &&
                          banner.subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            banner.subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (banner.linkUrl != null && banner.linkUrl!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.38),
                            ),
                          ),
                          child: const Text(
                            'Xem thêm',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoBannerFallback extends StatelessWidget {
  const _PromoBannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF166534), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GÓC CHĂM CÂY',
              style: TextStyle(
                color: Color(0xFFBBF7D0),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sẵn sàng cho\nnhững banner mới',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerSkeleton extends StatelessWidget {
  const _PromoBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFE5E7EB),
      ),
    );
  }
}

void _handleBannerTap(BuildContext context, AppBanner banner) {
  final linkUrl = banner.linkUrl?.trim();
  if (linkUrl == null || linkUrl.isEmpty) {
    return;
  }

  if (linkUrl.startsWith('/')) {
    context.push(linkUrl);
  }
}
