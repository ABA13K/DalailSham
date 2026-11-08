import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/avatar_file.dart';
import 'registration.dart';

/// `POST /vendor/join-request` — an account and the service it wants listed,
/// in the one application the admin reviews.
///
/// [password] is sent twice, as `password_confirmation`; [regionId] and
/// [categoryId] come from the two pick lists, and [mainImage] stays out of the
/// request when the applicant skipped the cover photo.
class JoinRequest extends Equatable {
  const JoinRequest({
    required this.fullName,
    required this.mobile,
    required this.password,
    required this.gender,
    required this.regionId,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.email,
    this.phone,
    this.companyEmail,
    this.addressAr,
    this.addressEn,
    this.descriptionAr,
    this.descriptionEn,
    this.mainImage,
  });

  final String fullName;
  final String mobile;
  final String password;
  final AuthGender gender;
  final int regionId;
  final int categoryId;
  final String nameAr;
  final String nameEn;
  final String? email;
  final String? phone;
  final String? companyEmail;
  final String? addressAr;
  final String? addressEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final AvatarFile? mainImage;

  /// The only plan an applicant can ask for; a paid one is set after review.
  static const String subscriptionType = 'free';

  @override
  List<Object?> get props => [
    fullName,
    mobile,
    password,
    gender,
    regionId,
    categoryId,
    nameAr,
    nameEn,
    email,
    phone,
    companyEmail,
    addressAr,
    addressEn,
    descriptionAr,
    descriptionEn,
    mainImage,
  ];
}
