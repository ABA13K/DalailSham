import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/banner_ad.dart';
import '../../domain/usecases/get_banners.dart';

sealed class BannersState extends Equatable {
  const BannersState();

  @override
  List<Object?> get props => [];
}

class BannersInitial extends BannersState {
  const BannersInitial();
}

class BannersLoading extends BannersState {
  const BannersLoading();
}

class BannersReady extends BannersState {
  const BannersReady(this.banners);

  final List<BannerAd> banners;

  @override
  List<Object?> get props => [banners];
}

class BannersError extends BannersState {
  const BannersError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads the promotional banners shown in the feed.
class BannersCubit extends Cubit<BannersState> {
  BannersCubit(this._getBanners) : super(const BannersInitial());

  final GetBanners _getBanners;
  String? _locale;

  Future<void> load(String locale) async {
    _locale = locale;
    // A refresh keeps the banners that are already on screen; a placeholder is
    // only worth showing while there is nothing to show yet.
    final shown = state;
    final hasBanners = shown is BannersReady && shown.banners.isNotEmpty;
    if (!hasBanners) emit(const BannersLoading());
    final result = await _getBanners(locale);
    // Ignore a response that arrives after the locale changed.
    if (isClosed || _locale != locale) return;
    result.fold(
      (failure) {
        if (!hasBanners) emit(BannersError(failure));
      },
      // An identical response leaves the state untouched.
      (banners) => emit(BannersReady(banners)),
    );
  }

  Future<void> reload() async {
    final locale = _locale;
    if (locale != null) await load(locale);
  }
}
