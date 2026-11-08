import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/registration.dart';

/// `PUT /user/profile` payload: the only three fields the endpoint edits.
///
/// [gender] is left out of the request until the account has chosen one.
class ProfileEdit extends Equatable {
  const ProfileEdit({required this.fullName, this.gender, this.address});

  final String fullName;
  final AuthGender? gender;
  final String? address;

  @override
  List<Object?> get props => [fullName, gender, address];
}
