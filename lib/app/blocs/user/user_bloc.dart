import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/features/user/domain/entities/user_profile.dart';
import 'package:growingkids/features/user/domain/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserInitial()) {
    on<UserProfileRequested>(_onUserProfileRequested);
    on<UserProfileCleared>(_onUserProfileCleared);
  }

  Future<void> _onUserProfileRequested(
    UserProfileRequested event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserLoaded && currentState.profile.id == event.userId) {
      return;
    }

    emit(const UserLoading());
    try {
      final profile = await _userRepository.getUserProfile(event.userId);
      emit(UserLoaded(profile));
    } catch (_) {
      emit(const UserFailure('Không thể tải thông tin người dùng.'));
    }
  }

  void _onUserProfileCleared(
    UserProfileCleared event,
    Emitter<UserState> emit,
  ) {
    emit(const UserInitial());
  }
}
