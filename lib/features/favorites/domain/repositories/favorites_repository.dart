import 'package:dali_alsham/core/error/result.dart';

import '../entities/favorite_mutation.dart';

abstract interface class FavoritesRepository {
  /// `POST /favorites/services/{slug}`; a duplicate add resolves to favorited.
  Future<Result<FavoriteMutation>> add(String slug);

  /// `DELETE /favorites/services/{slug}`; removing an unknown favorite
  /// resolves to not favorited.
  Future<Result<FavoriteMutation>> remove(String slug);
}
