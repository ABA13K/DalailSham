import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/settings/presentation/token_cubit.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/join_request.dart';
import '../../domain/entities/registration.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState extends Equatable {
  const AuthState({this.user, this.isSubmitting = false});

  /// The signed-in account, or null while the app runs without one.
  final AuthUser? user;
  final bool isSubmitting;

  @override
  List<Object?> get props => [user, isSubmitting];
}

/// Drives the login and register forms and keeps the stored session in view.
///
/// The repository writes the token; [TokenCubit] re-reads it so every screen
/// that switches on a bearer token — favorites, the top-rated rail — reacts to
/// the new session at once. [login] and [register] answer with the message to
/// show, or null when the account got in.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._tokenCubit) : super(const AuthState());

  final AuthRepository _repository;
  final TokenCubit _tokenCubit;

  /// Restores the account of a session that survived the last launch.
  Future<void> load() async =>
      emit(AuthState(user: await _repository.account()));

  Future<String?> login(Credentials credentials) =>
      _submit(() => _repository.login(credentials));

  Future<String?> register(Registration registration) =>
      _submit(() => _repository.register(registration));

  /// The vendor application. A success stores the session the reply handed
  /// back, so the applicant is signed in while the service waits for review.
  Future<String?> joinRequest(JoinRequest request) =>
      _submit(() => _repository.joinRequest(request));

  Future<void> signOut() async {
    await _repository.signOut();
    if (isClosed) return;
    await _tokenCubit.load();
    if (isClosed) return;
    emit(const AuthState());
  }

  Future<String?> _submit(
    Future<Result<AuthSession>> Function() request,
  ) async {
    emit(AuthState(user: state.user, isSubmitting: true));
    final result = await request();

    return result.fold(
      (failure) async {
        if (!isClosed) emit(AuthState(user: state.user));
        return failure.message;
      },
      (session) async {
        await _tokenCubit.load();
        if (!isClosed) emit(AuthState(user: session.user));
        return null;
      },
    );
  }
}
