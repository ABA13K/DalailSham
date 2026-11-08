import 'package:equatable/equatable.dart';

/// The account returned by the login and register endpoints.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.fullName,
    this.email,
    this.mobile,
    this.gender,
    this.address,
    this.avatar,
    this.locale,
    this.type,
  });

  final int id;
  final String fullName;
  final String? email;
  final String? mobile;

  /// `male` or `female` as the backend spells them.
  final String? gender;
  final String? address;
  final String? avatar;

  /// Language the account prefers, `ar` or `en`.
  final String? locale;

  /// What kind of account this is, `user` or `vendor`. Only a vendor owns the
  /// service the `/vendor/service` endpoints edit.
  final String? type;

  /// Secondary line for the account header: mobile when present, else email.
  String get contact => mobile ?? email ?? '';

  bool get isVendor => type?.toLowerCase() == 'vendor';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'full_name': fullName,
    'email': email,
    'mobile': mobile,
    'gender': gender,
    'address': address,
    'avatar': avatar,
    'locale': locale,
    'type': type,
  };

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    mobile,
    gender,
    address,
    avatar,
    locale,
    type,
  ];
}
