import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/stories_seen_repository.dart';

/// Ids of the stories the user has watched, kept in sync with local storage.
/// Both strips write here, so a service story is keyed apart from a place one
/// with `Story.seenKey`.
class StoriesSeenCubit extends Cubit<Set<String>> {
  StoriesSeenCubit(this._repository) : super(const {});

  final StoriesSeenRepository _repository;

  Future<void> load() async {
    final ids = await _repository.getViewedIds();
    if (!isClosed) emit(ids);
  }

  Future<void> markViewed(String placeId) async {
    if (state.contains(placeId)) return;
    final updated = {...state, placeId};
    emit(updated);
    await _repository.saveViewedIds(updated);
  }
}
