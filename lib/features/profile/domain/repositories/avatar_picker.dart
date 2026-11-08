import '../entities/avatar_file.dart';

/// Opens the device photo chooser for `POST /user/profile/avatar`.
abstract interface class AvatarPicker {
  /// The chosen picture, or null when the user backed out.
  Future<AvatarFile?> pick();
}
