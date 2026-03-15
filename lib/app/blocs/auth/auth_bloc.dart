import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthStatusChanged>(_onStatusChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSocialSignInRequested>(_onSocialSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);

    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthStatusChanged(user));
    });

    add(const AuthStarted());
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
      return;
    }

    emit(const AuthUnauthenticated());
  }

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(AuthAuthenticated(user));
      return;
    }

    emit(const AuthUnauthenticated());
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthFailure('Đăng nhập thất bại. Vui lòng thử lại.'));
        emit(const AuthUnauthenticated());
        return;
      }

      emit(AuthAuthenticated(user));
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthFailure('Có lỗi xảy ra khi đăng nhập.'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        displayName: event.displayName,
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthFailure('Đăng ký thất bại. Vui lòng thử lại.'));
        emit(const AuthUnauthenticated());
        return;
      }

      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        emit(AuthAuthenticated(currentUser));
        return;
      }

      emit(const AuthFailure('Đăng ký thành công, vui lòng xác thực email.'));
      emit(const AuthUnauthenticated());
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthFailure('Có lỗi xảy ra khi đăng ký.'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSocialSignInRequested(
    AuthSocialSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithSocial(event.provider);
      emit(const AuthUnauthenticated());
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(
        AuthFailure(
          'Không thể bắt đầu đăng nhập mạng xã hội. Chi tiết: $error',
        ),
      );
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthFailure('Không thể đăng xuất lúc này.'));
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _authStateSubscription.cancel();
    return super.close();
  }
}
