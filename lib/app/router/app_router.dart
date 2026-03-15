import 'package:go_router/go_router.dart';
import 'package:growingkids/app/router/routes_name.dart';
import 'package:growingkids/features/auth/presentation/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:growingkids/features/tabs/presentation/screens/cart_screen.dart';
import 'package:growingkids/features/tabs/presentation/screens/home_screen.dart';
import 'package:growingkids/features/tabs/presentation/screens/notifications_screen.dart';
import 'package:growingkids/features/tabs/presentation/screens/profile_screen.dart';
import 'package:growingkids/features/tabs/presentation/screens/scan_screen.dart';

GoRouter makeRouter() {
  return GoRouter(
    redirect: (context, state) {
      // final loggedIn = authBloc.state.status == AuthStatus.authenticated;
      // final path = state.uri.path;

      // final isPublicRoute = path == '/' || path.startsWith('/auth/');

      // if (!loggedIn) {
      //   return '/auth/enter';
      // }

      // // sau login, vào tab home
      // return isPublicRoute ? '/home' : null;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RoutesName.tabHome,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: RoutesName.tabCart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: RoutesName.tabProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: RoutesName.tabNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: RoutesName.tabScan,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const SizedBox.shrink(),
        routes: [
          GoRoute(
            path: 'enter',
            name: RoutesName.authEnter,
            builder: (context, state) => const EnterScreen(),
          ),
          GoRoute(
            path: 'forgot-password',
            name: RoutesName.authForgotPassword,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),
    ],
  );
}
