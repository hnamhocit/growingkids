class LoginStreakSyncResult {
  final int previousCurrentStreak;
  final int currentStreak;
  final int longestStreak;
  final bool didIncrease;
  final bool alreadyCheckedInToday;
  final String checkinDateKey;

  const LoginStreakSyncResult({
    required this.previousCurrentStreak,
    required this.currentStreak,
    required this.longestStreak,
    required this.didIncrease,
    required this.alreadyCheckedInToday,
    required this.checkinDateKey,
  });

  int get animationStartStreak {
    if (currentStreak <= 0) {
      return 0;
    }

    if (didIncrease) {
      return previousCurrentStreak;
    }

    return currentStreak - 1;
  }

  String dialogTokenForUser(String userId) {
    return '$userId:$checkinDateKey:$currentStreak';
  }
}
