import 'package:supabase_flutter/supabase_flutter.dart';

enum SocialAuthProvider { google, facebook }

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User?> signUpWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  });

  Future<void> signInWithSocial(SocialAuthProvider provider);

  Future<void> signOut();
}
