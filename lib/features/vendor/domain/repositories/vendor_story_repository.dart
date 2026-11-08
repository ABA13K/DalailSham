import '../../../../core/error/result.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../entities/vendor_story.dart';
import '../entities/vendor_story_edit.dart';

/// The stories the signed-in vendor posts about their own service.
///
/// The call needs the bearer token and only answers for an account whose
/// `type` is `vendor`; a new story is held until an admin approves it.
abstract interface class VendorStoryRepository {
  /// `POST /vendor/stories` — [file] is the picked picture or clip, and is the
  /// part named by [VendorStoryEdit.type].
  Future<Result<VendorStory>> add({
    required VendorStoryEdit edit,
    AvatarFile? file,
    required String locale,
  });
}
