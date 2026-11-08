import 'package:image_picker/image_picker.dart';

import '../domain/entities/avatar_file.dart';
import '../domain/repositories/avatar_picker.dart';

/// Gallery-backed [AvatarPicker]. The picture is shrunk on the way out so the
/// upload stays small on a phone connection.
class GalleryAvatarPicker implements AvatarPicker {
  GalleryAvatarPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<AvatarFile?> pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return null;
    return AvatarFile(bytes: await file.readAsBytes(), fileName: file.name);
  }
}
