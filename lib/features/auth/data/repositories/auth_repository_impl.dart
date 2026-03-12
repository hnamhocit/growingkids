import 'package:plant_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;
  const AuthRepositoryImpl(this.client);

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      return null;
    }

    return response.user;
  }

  @override
  Future<User?> signUpWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.session == null) {
      return null;
    }

    return response.user;
  }

  @override
  Future<void> signOut() {
    return client.auth.signOut();
  }
}
