import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_story.dart';
import '../../domain/entities/vendor_story_edit.dart';
import '../../domain/repositories/vendor_story_repository.dart';
import '../datasources/vendor_story_remote_datasource.dart';

/// Talks to the vendor story endpoint for the signed-in vendor's service.
class VendorStoryRepositoryImpl implements VendorStoryRepository {
  VendorStoryRepositoryImpl(this._remote);

  final VendorStoryRemoteDataSource _remote;

  @override
  Future<Result<VendorStory>> add({
    required VendorStoryEdit edit,
    AvatarFile? file,
    required String locale,
  }) => _run(() => _remote.add(edit: edit, file: file, locale: locale));

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
