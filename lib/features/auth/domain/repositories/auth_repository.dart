import '../../../../core/error/result.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';
import '../entities/credentials.dart';
import '../entities/join_request.dart';
import '../entities/registration.dart';

abstract interface class AuthRepository {
  /// `POST /auth/login`; a success stores the token and the account.
  Future<Result<AuthSession>> login(Credentials credentials);

  /// `POST /auth/register`; a success stores the token and the account.
  Future<Result<AuthSession>> register(Registration registration);

  /// `POST /vendor/join-request`; a success stores the token and the account
  /// the application created, so the applicant is signed in while the admin
  /// reviews the service.
  Future<Result<AuthSession>> joinRequest(JoinRequest request);

  /// The stored account, or null while signed out.
  Future<AuthUser?> account();

  /// Forgets both the bearer token and the stored account.
  Future<void> signOut();
}
