import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/domain/entities/service_summary.dart';
import '../../domain/repositories/favorites_repository.dart';

/// How the last heart tap ended, so the card can show the right message.
enum FavoriteOutcome { added, removed, failure }

class FavoritesState extends Equatable {
  const FavoritesState({this.overrides = const {}, this.busyIds = const {}});

  /// Favorited flags resolved by the taps of this session; anything not listed
  /// keeps the flag the listing came with.
  final Map<int, bool> overrides;

  /// Services with a toggle request still in flight.
  final Set<int> busyIds;

  bool isFavorited(ServiceSummary service) =>
      overrides[service.id] ?? service.isFavorited;

  bool isBusy(int id) => busyIds.contains(id);

  @override
  List<Object?> get props => [overrides, busyIds];
}

/// App-wide favorite state so a heart keeps its value across pages.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._favoritesRepository) : super(const FavoritesState());

  final FavoritesRepository _favoritesRepository;

  bool isFavorited(ServiceSummary service) => state.isFavorited(service);

  bool isBusy(ServiceSummary service) => state.isBusy(service.id);

  Future<FavoriteOutcome> toggle(ServiceSummary service) async {
    final slug = service.slug;
    if (slug == null || state.isBusy(service.id)) {
      return FavoriteOutcome.failure;
    }

    _emit(busy: {...state.busyIds, service.id});
    final result = state.isFavorited(service)
        ? await _favoritesRepository.remove(slug)
        : await _favoritesRepository.add(slug);

    if (isClosed) return FavoriteOutcome.failure;
    final busy = {...state.busyIds}..remove(service.id);

    return result.fold(
      (_) {
        _emit(busy: busy);
        return FavoriteOutcome.failure;
      },
      (mutation) {
        _emit(
          overrides: {...state.overrides, service.id: mutation.isFavorited},
          busy: busy,
        );
        return mutation.isFavorited
            ? FavoriteOutcome.added
            : FavoriteOutcome.removed;
      },
    );
  }

  void _emit({Map<int, bool>? overrides, Set<int>? busy}) {
    emit(
      FavoritesState(
        overrides: overrides ?? state.overrides,
        busyIds: busy ?? state.busyIds,
      ),
    );
  }
}
