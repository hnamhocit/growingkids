import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:growingkids/app/app.dart';
import 'package:growingkids/app/blocs/auth/auth_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:growingkids/features/auth/domain/repositories/auth_repository.dart';
import 'package:growingkids/features/user/data/repositories/user_repository_impl.dart';
import 'package:growingkids/features/user/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await _loadSupabaseConfig();

  await Supabase.initialize(url: config.url, anonKey: config.anonKey);

  final supabaseClient = Supabase.instance.client;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(supabaseClient),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepositoryImpl(supabaseClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
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
