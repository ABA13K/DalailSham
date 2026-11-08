import 'package:equatable/equatable.dart';

/// Genders accepted by `POST /auth/register`.
enum AuthGender {
  male('male'),
  female('female');

  const AuthGender(this.wire);

  /// Value the backend expects in the payload.
  final String wire;

  /// The gender as the backend spells it, or null for a value it never sent.
  static AuthGender? fromWire(String? wire) => switch (wire) {
    'male' => AuthGender.male,
    'female' => AuthGender.female,
    _ => null,
  };
}

/// `POST /auth/register` payload. `password_confirmation` repeats [password]
/// and `avatar` stays null until uploads exist.
class Registration extends Equatable {
  const Registration({
    required this.fullName,
    required this.mobile,
    required this.password,
    required this.gender,
    this.email,
    this.address,
    this.locale,
  });

  final String fullName;
  final String mobile;
  final String password;
  final AuthGender gender;
  final String? email;
  final String? address;

  /// Language the account is created with; the backend defaults to `ar`.
  final String? locale;

  @override
  List<Object?> get props => [
    fullName,
    mobile,
    password,
    gender,
    email,
    address,
    locale,
  ];
}
