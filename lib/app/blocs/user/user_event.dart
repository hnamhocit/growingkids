part of 'user_bloc.dart';

sealed class UserEvent {
  const UserEvent();
}

class UserProfileRequested extends UserEvent {
  final String userId;
  final bool syncLoginStreak;
  final bool forceRefresh;

  const UserProfileRequested(
    this.userId, {
    this.syncLoginStreak = false,
    this.forceRefresh = false,
  });
}

class UserProfileCleared extends UserEvent {
  const UserProfileCleared();
}
