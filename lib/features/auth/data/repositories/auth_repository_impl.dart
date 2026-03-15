import 'package:growingkids/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _defaultMobileAuthRedirectUrl =
    'vn.hnamhocit.growingkids://login-callback/';
const _mobileAuthRedirectUrl = String.fromEnvironment(
  'SUPABASE_AUTH_REDIRECT_URL',
  defaultValue: _defaultMobileAuthRedirectUrl,
);

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient client;
  const AuthRepositoryImpl(this.client);

  @override
  User? get currentUser => client.auth.currentUser;

  @override
  Stream<User?> get authStateChanges =>
      client.auth.onAuthStateChange.map((authState) => authState.session?.user);

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
    return response.user;
  }

  @override
  Future<void> signInWithSocial(SocialAuthProvider provider) async {
    try {
      final oauthProvider = switch (provider) {
        SocialAuthProvider.google => OAuthProvider.google,
        SocialAuthProvider.facebook => OAuthProvider.facebook,
      };

      final didLaunch = await client.auth.signInWithOAuth(
        oauthProvider,
        redirectTo: _mobileAuthRedirectUrl,
      );

      if (!didLaunch) {
        throw AuthException(
          'Không thể mở màn hình đăng nhập bằng ${_socialProviderLabel(provider)}.',
        );
      }
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException(
        'Không thể bắt đầu đăng nhập bằng ${_socialProviderLabel(provider)}. Chi tiết: $error',
      );
    }
  }

  @override
  Future<void> signOut() {
    return client.auth.signOut();
  }
}

String _socialProviderLabel(SocialAuthProvider provider) {
  return switch (provider) {
    SocialAuthProvider.google => 'Google',
    SocialAuthProvider.facebook => 'Facebook',
  };
}
