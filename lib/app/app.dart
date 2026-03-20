import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/core/storage/streak_dialog_store.dart';
import 'package:growingkids/core/widgets/login_streak_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/router/app_router.dart';
import 'package:growingkids/app/theme/app_theme.dart';
import 'package:growingkids/features/user/domain/entities/login_streak_sync_result.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  late final GoRouter _router;
  String? _lastStreakDialogUserId;

  @override
  void initState() {
    super.initState();
    _router = makeRouter(navigatorKey: _rootNavigatorKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<UserBloc>().add(
          UserProfileRequested(
            authState.user.id,
            syncLoginStreak: true,
            forceRefresh: true,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'GrowingKids',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.read<UserBloc>().add(
                    UserProfileRequested(
                      state.user.id,
                      syncLoginStreak: true,
                      forceRefresh: true,
                    ),
                  );
                } else if (state is AuthUnauthenticated) {
                  _lastStreakDialogUserId = null;
                  context.read<UserBloc>().add(const UserProfileCleared());
                }
              },
            ),
            BlocListener<UserBloc, UserState>(
              listener: (context, state) {
                if (state is! UserLoaded) {
                  return;
                }

                final streakResult = state.loginStreakSyncResult;
                if (streakResult == null) {
                  return;
                }

                if (_lastStreakDialogUserId == state.profile.id) {
                  return;
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) {
                    return;
                  }

                  final dialogStore = context.read<StreakDialogStore>();
                  _showLoginStreakDialogIfNeeded(
                    dialogStore: dialogStore,
                    userId: state.profile.id,
                    streakResult: streakResult,
                  );
                });
              },
            ),
          ],
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is! UserLoading) {
                    return const SizedBox.shrink();
                  }

                  return ColoredBox(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLoginStreakDialogIfNeeded({
    required StreakDialogStore dialogStore,
    required String userId,
    required LoginStreakSyncResult streakResult,
  }) async {
    final dialogToken = streakResult.dialogTokenForUser(userId);

    if (dialogStore.hasSeen(userId: userId, dialogToken: dialogToken)) {
      _lastStreakDialogUserId = userId;
      return;
    }

    await dialogStore.markSeen(userId: userId, dialogToken: dialogToken);
    _lastStreakDialogUserId = userId;

    if (!mounted) {
      return;
    }

    final dialogContext = _rootNavigatorKey.currentContext;
    if (dialogContext == null || !dialogContext.mounted) {
      return;
    }

    showLoginStreakDialog(dialogContext, result: streakResult);
  }
}
