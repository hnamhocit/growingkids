import 'package:growingkids/features/user/domain/entities/login_streak_sync_result.dart';
import 'package:growingkids/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getUserProfile(String userId);
  Future<LoginStreakSyncResult> syncLoginStreak(String userId);
}
