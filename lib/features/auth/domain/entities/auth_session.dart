import 'package:equatable/equatable.dart';

import 'auth_user.dart';

/// A successful login or register: the account plus its bearer token.
class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.token});

  final AuthUser user;
  final String token;

  @override
  List<Object?> get props => [user, token];
}
