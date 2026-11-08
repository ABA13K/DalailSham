import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/remote_image.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/repositories/account_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../domain/entities/avatar_file.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../../domain/entities/profile_edit.dart';
import '../../domain/repositories/profile_repository.dart';

/// Talks to the profile endpoints and keeps the cached account — the one the
/// drawer greets the user with — in step with what they return.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._account);

  final ProfileRemoteDataSource _remote;
  final AccountRepository _account;

  @override
  Future<Result<AuthUser>> load(String locale) =>
      _cached(() => _remote.profile(locale));

  @override
  Future<Result<AuthUser>> update({
    required ProfileEdit edit,
    required String locale,
  }) => _cached(() => _remote.update(edit: edit, locale: locale));

  @override
  Future<Result<String>> uploadAvatar({
    required AvatarFile file,
    required String locale,
  }) async {
    final result = await _run(
      () => _remote.uploadAvatar(file: file, locale: locale),
    );
    return result.fold(
      (failure) => FailureResult<String>(failure),
      (avatar) => Success(normalizeRemoteImageUrl(avatar) ?? avatar),
    );
  }

  @override
  Future<Result<void>> removeAvatar() => _run(_remote.removeAvatar);

  @override
  Future<Result<void>> changePassword(PasswordChange change) =>
      _run(() => _remote.changePassword(change));

  @override
  Future<Result<void>> deleteAccount(String password) =>
      _run(() => _remote.deleteAccount(password));

  Future<Result<AuthUser>> _cached(Future<AuthUser> Function() request) async {
    final result = await _run(request);
    if (result case Success(:final value)) await _account.saveUser(value);
    return result;
  }

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
