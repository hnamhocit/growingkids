import 'package:growingkids/features/user/domain/entities/user_profile.dart';
import 'package:growingkids/features/user/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient client;

  const UserRepositoryImpl(this.client);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    final data = await client.from('users').select().eq('id', userId).single();

    return UserProfile.fromMap(data);
  }
}
