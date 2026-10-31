import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/region.dart';
import '../../domain/usecases/get_region_page.dart';

enum AllRegionsStatus { initial, loading, ready, failure }

class AllRegionsState extends Equatable {
  const AllRegionsState({
    this.status = AllRegionsStatus.initial,
    this.regions = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final AllRegionsStatus status;
  final List<Region> regions;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  AllRegionsState copyWith({
    AllRegionsStatus? status,
    List<Region>? regions,
    bool? hasMore,
    bool? isLoadingMore,
  }) => AllRegionsState(
    status: status ?? this.status,
    regions: regions ?? this.regions,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, regions, hasMore, isLoadingMore, failure];
}

/// Paginated list of every region, used by the "see all" screen.
class AllRegionsCubit extends Cubit<AllRegionsState> {
  AllRegionsCubit(this._getRegionPage) : super(const AllRegionsState());

  final GetRegionPage _getRegionPage;
  String _locale = 'en';
  int? _nextPage;
  bool _requestInFlight = false;

  Future<void> load(String locale) async {
    _locale = locale;
    _nextPage = null;
    emit(const AllRegionsState(status: AllRegionsStatus.loading));
    await _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null || _requestInFlight) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: next, replace: false);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    final result = await _getRegionPage(
      RegionPageParams(locale: _locale, page: page),
    );
    _requestInFlight = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (replace) {
          emit(
            AllRegionsState(
              status: AllRegionsStatus.failure,
              failure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (regionPage) {
        _nextPage = regionPage.hasMore ? regionPage.nextPage : null;
        emit(
          AllRegionsState(
            status: AllRegionsStatus.ready,
            regions: replace
                ? regionPage.regions
                : [...state.regions, ...regionPage.regions],
            hasMore: _nextPage != null,
          ),
        );
      },
    );
  }
}
