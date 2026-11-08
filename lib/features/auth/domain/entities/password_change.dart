import 'package:equatable/equatable.dart';

/// A password change payload: `current_password`, `password` and
/// `password_confirmation`.
///
/// Both endpoints that take it — `/user/profile/change-password` and
/// `/vendor/service/account/change-password` — check the current one before
/// they accept the new one; the session on this device survives, the others are
/// logged out.
class PasswordChange extends Equatable {
  const PasswordChange({
    required this.currentPassword,
    required this.password,
    required this.confirmation,
  });

  final String currentPassword;
  final String password;
  final String confirmation;

  @override
  List<Object?> get props => [currentPassword, password, confirmation];
}
