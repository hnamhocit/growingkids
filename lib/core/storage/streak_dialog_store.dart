import 'package:shared_preferences/shared_preferences.dart';

class StreakDialogStore {
  final SharedPreferences _preferences;

  const StreakDialogStore(this._preferences);

  String _storageKey(String userId) => 'streak_dialog_seen_$userId';

  bool hasSeen({required String userId, required String dialogToken}) {
    return _preferences.getString(_storageKey(userId)) == dialogToken;
  }

  Future<bool> markSeen({required String userId, required String dialogToken}) {
    return _preferences.setString(_storageKey(userId), dialogToken);
  }
}
