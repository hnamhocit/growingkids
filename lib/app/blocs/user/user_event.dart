part of 'user_bloc.dart';

sealed class UserEvent {
  const UserEvent();
}

class UserProfileRequested extends UserEvent {
  final String userId;

  const UserProfileRequested(this.userId);
}

class UserProfileCleared extends UserEvent {
  const UserProfileCleared();
}
