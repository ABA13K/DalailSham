import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/explore_category.dart';
import '../../domain/usecases/get_random_categories.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesReady extends CategoriesState {
  const CategoriesReady(this.categories);

  final List<ExploreCategory> categories;

  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  const CategoriesError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads the random category showcase for the feed.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._getRandomCategories) : super(const CategoriesInitial());

  final GetRandomCategories _getRandomCategories;
  String? _locale;

  Future<void> load(String locale) async {
    _locale = locale;
    // A refresh keeps the showcase that is already on screen; a placeholder is
    // only worth showing while there is nothing to show yet.
    final shown = state;
    final hasShowcase = shown is CategoriesReady && shown.categories.isNotEmpty;
    if (!hasShowcase) emit(const CategoriesLoading());
    final result = await _getRandomCategories(
      RandomCategoriesParams(locale: locale),
    );
    // Ignore a response that arrives after the locale changed.
    if (isClosed || _locale != locale) return;
    result.fold(
      (failure) {
        if (!hasShowcase) emit(CategoriesError(failure));
      },
      // An identical response leaves the state untouched.
      (categories) => emit(CategoriesReady(categories)),
    );
  }

  Future<void> reload() async {
    final locale = _locale;
    if (locale != null) await load(locale);
  }
}
