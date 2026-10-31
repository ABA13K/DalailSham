import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/tutorial_repository.dart';

/// Whether the guided tour has been completed; null while loading.
class TutorialCubit extends Cubit<bool?> {
  TutorialCubit(this._repository) : super(null);

  final TutorialRepository _repository;

  Future<void> load() async {
    final completed = await _repository.hasCompleted();
    if (!isClosed) emit(completed);
  }

  Future<void> complete() async {
    if (state == true) return;
    emit(true);
    await _repository.setCompleted(true);
  }

  Future<void> restart() async {
    emit(false);
    await _repository.setCompleted(false);
  }
}
