import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/region.dart';
import '../../domain/usecases/get_random_regions.dart';

sealed class RegionsState extends Equatable {
  const RegionsState();

  @override
  List<Object?> get props => [];
}

class RegionsInitial extends RegionsState {
  const RegionsInitial();
}

class RegionsLoading extends RegionsState {
  const RegionsLoading();
}

class RegionsReady extends RegionsState {
  const RegionsReady(this.regions);

  final List<Region> regions;

  @override
  List<Object?> get props => [regions];
}

class RegionsError extends RegionsState {
  const RegionsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads the random region showcase for the feed.
class RegionsCubit extends Cubit<RegionsState> {
  RegionsCubit(this._getRandomRegions) : super(const RegionsInitial());

  final GetRandomRegions _getRandomRegions;
  String? _locale;

  Future<void> load(String locale) async {
    _locale = locale;
    // A refresh keeps the showcase that is already on screen; a placeholder is
    // only worth showing while there is nothing to show yet.
    final shown = state;
    final hasShowcase = shown is RegionsReady && shown.regions.isNotEmpty;
    if (!hasShowcase) emit(const RegionsLoading());
    final result = await _getRandomRegions(RandomRegionsParams(locale: locale));
    // Ignore a response that arrives after the locale changed.
    if (isClosed || _locale != locale) return;
    result.fold(
      (failure) {
        if (!hasShowcase) emit(RegionsError(failure));
      },
      // An identical response leaves the state untouched.
      (regions) => emit(RegionsReady(regions)),
    );
  }

  Future<void> reload() async {
    final locale = _locale;
    if (locale != null) await load(locale);
  }
}
