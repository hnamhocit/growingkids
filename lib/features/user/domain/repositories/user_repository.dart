import 'package:growingkids/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getUserProfile(String userId);
}
