import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:growingkids/app/app.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/app/theme/theme_cubit.dart';
import 'package:growingkids/core/storage/streak_dialog_store.dart';
import 'package:growingkids/core/storage/theme_preference_store.dart';
import 'package:growingkids/features/banners/data/repositories/banner_repository_impl.dart';
import 'package:growingkids/features/banners/domain/repositories/banner_repository.dart';
import 'package:growingkids/features/banners/presentation/bloc/banner_bloc.dart';
import 'package:growingkids/features/categories/data/repositories/category_repository_impl.dart';
import 'package:growingkids/features/categories/domain/repositories/category_repository.dart';
import 'package:growingkids/features/categories/presentation/bloc/category_bloc.dart';
import 'package:growingkids/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:growingkids/features/auth/domain/repositories/auth_repository.dart';
import 'package:growingkids/features/user/data/repositories/user_repository_impl.dart';
import 'package:growingkids/features/user/domain/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await _loadSupabaseConfig();

  await Supabase.initialize(url: config.url, anonKey: config.anonKey);

  final supabaseClient = Supabase.instance.client;
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(supabaseClient),
        ),
        RepositoryProvider<BannerRepository>(
          create: (_) => BannerRepositoryImpl(supabaseClient),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) => CategoryRepositoryImpl(supabaseClient),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepositoryImpl(supabaseClient),
        ),
        RepositoryProvider<StreakDialogStore>(
          create: (_) => StreakDialogStore(sharedPreferences),
        ),
        RepositoryProvider<ThemePreferenceStore>(
          create: (_) => ThemePreferenceStore(sharedPreferences),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<BannerBloc>(
            create: (context) =>
                BannerBloc(bannerRepository: context.read<BannerRepository>())
                  ..add(const BannersRequested()),
          ),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(
              themePreferenceStore: context.read<ThemePreferenceStore>(),
            ),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              categoryRepository: context.read<CategoryRepository>(),
            )..add(const CategoriesRequested()),
          ),
          BlocProvider<UserBloc>(
            create: (context) =>
                UserBloc(userRepository: context.read<UserRepository>()),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}

Future<_SupabaseConfig> _loadSupabaseConfig() async {
  const envUrl = String.fromEnvironment('SUPABASE_URL');
  const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (envUrl.isNotEmpty && envAnonKey.isNotEmpty) {
    return const _SupabaseConfig(url: envUrl, anonKey: envAnonKey);
  }

  final rawConfig = await rootBundle.loadString('config.json');
  final json = jsonDecode(rawConfig) as Map<String, dynamic>;
  final fileUrl = (json['SUPABASE_URL'] as String? ?? '').trim();
  final fileAnonKey = (json['SUPABASE_ANON_KEY'] as String? ?? '').trim();

  final resolvedUrl = envUrl.isNotEmpty ? envUrl : fileUrl;
  final resolvedAnonKey = envAnonKey.isNotEmpty ? envAnonKey : fileAnonKey;

  if (resolvedUrl.isEmpty || resolvedAnonKey.isEmpty) {
    throw StateError(
      'Thiếu cấu hình Supabase. Hãy truyền --dart-define hoặc điền SUPABASE_URL và SUPABASE_ANON_KEY trong config.json.',
    );
  }

  return _SupabaseConfig(url: resolvedUrl, anonKey: resolvedAnonKey);
}

class _SupabaseConfig {
  final String url;
  final String anonKey;

  const _SupabaseConfig({required this.url, required this.anonKey});
}
