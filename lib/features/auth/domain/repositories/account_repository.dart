import '../entities/auth_user.dart';

/// Cache of the signed-in account, stored next to the bearer token so the
/// drawer can greet the user before any request answers.
abstract interface class AccountRepository {
  Future<AuthUser?> getUser();

  Future<void> saveUser(AuthUser user);

  Future<void> clearUser();
}
