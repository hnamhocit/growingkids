import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/app/blocs/user/user_bloc.dart';
import 'package:growingkids/features/user/domain/entities/user_profile.dart';

extension UserProfileRoleX on UserProfile {
  bool hasRole(UserRole role) => this.role == role;

  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => role == UserRole.staff;
  bool get isCustomer => role == UserRole.customer;
}

extension UserStateRoleX on UserState {
  UserProfile? get profileOrNull {
    final currentState = this;
    if (currentState is UserLoaded) {
      return currentState.profile;
    }

    return null;
  }

  bool hasRole(UserRole role) => profileOrNull?.hasRole(role) ?? false;

  bool get isAdmin => hasRole(UserRole.admin);
  bool get isStaff => hasRole(UserRole.staff);
  bool get isCustomer => hasRole(UserRole.customer);
}

extension BuildContextUserRoleX on BuildContext {
  UserProfile? get currentUserProfile => read<UserBloc>().state.profileOrNull;

  bool watchHasUserRole(UserRole role) {
    return select<UserBloc, bool>((bloc) => bloc.state.hasRole(role));
  }

  bool get isAdmin => watchHasUserRole(UserRole.admin);
  bool get isStaff => watchHasUserRole(UserRole.staff);
  bool get isCustomer => watchHasUserRole(UserRole.customer);
}
