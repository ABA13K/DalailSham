import 'package:image_picker/image_picker.dart';

import '../../profile/domain/entities/avatar_file.dart';
import '../domain/repositories/story_file_picker.dart';

/// Gallery-backed [StoryFilePicker]. A picture is shrunk on the way out the
/// same way an avatar is; a clip is handed over as stored, since re-encoding
/// video here would need a plugin the app does not carry.
class GalleryStoryFilePicker implements StoryFilePicker {
  GalleryStoryFilePicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<AvatarFile?> pickImage() async => _read(
    await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1920,
      imageQuality: 85,
    ),
  );

  @override
  Future<AvatarFile?> pickVideo() async =>
      _read(await _picker.pickVideo(source: ImageSource.gallery));

  static Future<AvatarFile?> _read(XFile? file) async {
    if (file == null) return null;
    return AvatarFile(bytes: await file.readAsBytes(), fileName: file.name);
  }
}
