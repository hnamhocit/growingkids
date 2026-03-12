part of 'user_bloc.dart';

sealed class UserState {
  const UserState();
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final UserProfile profile;

  const UserLoaded(this.profile);
}

class UserFailure extends UserState {
  final String message;

  const UserFailure(this.message);
}
