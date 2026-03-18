import 'package:growingkids/features/user/domain/entities/login_streak_sync_result.dart';
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

  @override
  Future<LoginStreakSyncResult> syncLoginStreak(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final streakData = await client
        .from('user_streaks')
        .select('current_streak, longest_streak, last_checkin_date')
        .eq('user_id', userId)
        .maybeSingle();

    final lastCheckinDateRaw = streakData?['last_checkin_date'];
    final lastCheckinDate = switch (lastCheckinDateRaw) {
      String value => DateTime.parse(value),
      DateTime value => value,
      _ => null,
    };
    final lastCheckinDay = lastCheckinDate == null
        ? null
        : DateTime(
            lastCheckinDate.year,
            lastCheckinDate.month,
            lastCheckinDate.day,
          );

    final previousCurrentStreak =
        (streakData?['current_streak'] as num?)?.toInt() ?? 0;
    final previousLongestStreak =
        (streakData?['longest_streak'] as num?)?.toInt() ?? 0;

    if (lastCheckinDay != null && lastCheckinDay == today) {
      return LoginStreakSyncResult(
        previousCurrentStreak: previousCurrentStreak,
        currentStreak: previousCurrentStreak,
        longestStreak: previousLongestStreak,
        didIncrease: false,
        alreadyCheckedInToday: true,
        checkinDateKey: _formatDate(today),
      );
    }

    final isConsecutiveDay =
        lastCheckinDay != null && today.difference(lastCheckinDay).inDays == 1;
    final nextCurrentStreak = lastCheckinDay == null
        ? 1
        : isConsecutiveDay
        ? previousCurrentStreak + 1
        : 1;
    final nextLongestStreak = nextCurrentStreak > previousLongestStreak
        ? nextCurrentStreak
        : previousLongestStreak;

    await client.from('user_streaks').upsert({
      'user_id': userId,
      'current_streak': nextCurrentStreak,
      'longest_streak': nextLongestStreak,
      'last_checkin_date': _formatDate(today),
    }, onConflict: 'user_id');

    return LoginStreakSyncResult(
      previousCurrentStreak: previousCurrentStreak,
      currentStreak: nextCurrentStreak,
      longestStreak: nextLongestStreak,
      didIncrease: true,
      alreadyCheckedInToday: false,
      checkinDateKey: _formatDate(today),
    );
  }
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
