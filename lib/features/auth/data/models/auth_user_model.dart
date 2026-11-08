import '../../../../core/network/remote_image.dart';
import '../../domain/entities/auth_user.dart';

/// JSON/DTO representation of [AuthUser].
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    super.email,
    super.mobile,
    super.gender,
    super.address,
    super.avatar,
    super.locale,
    super.type,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final fullName = _text(json['full_name']);
    if (id is! num || fullName == null) {
      throw const FormatException('Invalid account payload');
    }

    return AuthUserModel(
      id: id.toInt(),
      fullName: fullName,
      email: _text(json['email']),
      mobile: _text(json['mobile']),
      gender: _text(json['gender']),
      address: _text(json['address']),
      avatar: normalizeRemoteImageUrl(json['avatar']),
      locale: _text(json['locale']),
      type: _text(json['type']),
    );
  }

  static String? _text(Object? value) {
    final text = (value as String?)?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
