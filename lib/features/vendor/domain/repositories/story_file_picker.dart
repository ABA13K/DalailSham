import '../../../profile/domain/entities/avatar_file.dart';

/// Opens the device gallery for the picture or clip a story is built from.
abstract interface class StoryFilePicker {
  /// The chosen picture, shrunk so the upload stays small on a phone
  /// connection, or null when the vendor backed out.
  Future<AvatarFile?> pickImage();

  /// The chosen clip as it is stored, or null when the vendor backed out.
  Future<AvatarFile?> pickVideo();
}
