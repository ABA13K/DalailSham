import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/settings/domain/token_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/join_request.dart';
import '../../domain/entities/registration.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/auth_repository.dart';

/// Keeps the bearer token and the account next to each other so a later launch
/// can restore the session from storage alone.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenRepository, this._account);

  final AuthRemoteDataSource _remote;
  final TokenRepository _tokenRepository;
  final AccountRepository _account;

  @override
  Future<Result<AuthSession>> login(Credentials credentials) =>
      _keep(() => _remote.login(credentials));

  @override
  Future<Result<AuthSession>> register(Registration registration) =>
      _keep(() => _remote.register(registration));

  @override
  Future<Result<AuthSession>> joinRequest(JoinRequest request) =>
      _keep(() => _remote.joinRequest(request));

  @override
  Future<AuthUser?> account() => _account.getUser();

  @override
  Future<void> signOut() async {
    await _tokenRepository.clearToken();
    await _account.clearUser();
  }

  Future<Result<AuthSession>> _keep(
    Future<AuthSession> Function() request,
  ) async {
    try {
      final session = await request();
      await _tokenRepository.saveToken(session.token);
      await _account.saveUser(session.user);
      return Success(session);
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
