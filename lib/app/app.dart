import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/router/app_router.dart';
import 'package:growingkids/app/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = makeRouter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<UserBloc>().add(UserProfileRequested(authState.user.id));
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
                    UserProfileRequested(state.user.id),
                  );
                } else if (state is AuthUnauthenticated) {
                  context.read<UserBloc>().add(const UserProfileCleared());
                }
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
}
