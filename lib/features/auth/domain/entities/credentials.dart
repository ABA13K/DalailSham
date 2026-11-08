import 'package:equatable/equatable.dart';

/// `POST /auth/login` payload: the account identifier is either the email or
/// the mobile number, which the backend resolves itself.
class Credentials extends Equatable {
  const Credentials({required this.login, required this.password});

  final String login;
  final String password;

  @override
  List<Object?> get props => [login, password];
}
