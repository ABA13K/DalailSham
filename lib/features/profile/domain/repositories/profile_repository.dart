import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../entities/avatar_file.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../entities/profile_edit.dart';

/// The signed-in account's own record: read, edited, pictured and deleted.
///
/// Every call needs the bearer token. A read or an edit also refreshes the
/// cached profile the drawer greets the user with.
abstract interface class ProfileRepository {
  /// `GET /user/profile`
  Future<Result<AuthUser>> load(String locale);

  /// `PUT /user/profile`
  Future<Result<AuthUser>> update({
    required ProfileEdit edit,
    required String locale,
  });

  /// `POST /user/profile/avatar` — answers with the address of the new picture.
  Future<Result<String>> uploadAvatar({
    required AvatarFile file,
    required String locale,
  });

  /// `DELETE /user/profile/avatar`
  Future<Result<void>> removeAvatar();

  /// `POST /user/profile/change-password`
  Future<Result<void>> changePassword(PasswordChange change);

  /// `DELETE /user/profile/account`
  Future<Result<void>> deleteAccount(String password);
}
