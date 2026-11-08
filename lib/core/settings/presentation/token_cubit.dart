import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/token_repository.dart';

/// Holds the bearer token used by the authenticated endpoints.
///
/// [AuthRepository] is the only writer — a login, a register or a sign-out
/// stores the token and this cubit re-reads it so the app reacts.
class TokenCubit extends Cubit<String?> {
  TokenCubit(this._repository) : super(null);

  final TokenRepository _repository;

  Future<void> load() async => emit(await _repository.getToken());
}
