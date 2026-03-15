import 'package:growingkids/features/user/domain/entities/user_profile.dart';
import 'package:growingkids/features/user/domain/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient client;

  const UserRepositoryImpl(this.client);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    final userData = await client
        .from('users')
        .select()
        .eq('id', userId)
        .single();
    final streakData = await client
        .from('user_streaks')
        .select('current_streak, longest_streak, last_checkin_date')
        .eq('user_id', userId)
        .maybeSingle();

    return UserProfile.fromMap({...userData, ...?streakData});
  }
}
