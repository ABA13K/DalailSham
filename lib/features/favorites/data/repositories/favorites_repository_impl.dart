import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/favorite_mutation.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._remoteDataSource);

  final FavoritesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<FavoriteMutation>> add(String slug) =>
      _run(() => _remoteDataSource.favorite(slug));

  @override
  Future<Result<FavoriteMutation>> remove(String slug) =>
      _run(() => _remoteDataSource.unfavorite(slug));

  Future<Result<FavoriteMutation>> _run(
    Future<FavoriteMutation> Function() request,
  ) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
