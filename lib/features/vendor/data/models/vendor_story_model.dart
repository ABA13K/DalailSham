import '../../../../core/network/remote_image.dart';
import '../../domain/entities/vendor_story.dart';

/// JSON/DTO representation of [VendorStory].
class VendorStoryModel extends VendorStory {
  const VendorStoryModel({
    required super.id,
    required super.type,
    super.caption,
    super.imageUrl,
    super.videoUrl,
    super.status,
    super.isApproved,
    super.isPending,
  });

  factory VendorStoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    // The reply is read to tell the vendor what was stored, so a story with no
    // id — or a type the app does not know how to post — is not worth showing.
    final type = VendorStoryType.fromWire(json['type']);
    if (id is! num || type == null) {
      throw const FormatException('Invalid vendor story payload');
    }

    return VendorStoryModel(
      id: id.toInt(),
      type: type,
      caption: _text(json['caption']),
      imageUrl: normalizeRemoteImageUrl(json['image']),
      videoUrl: normalizeRemoteImageUrl(json['video']),
      status: _text(json['status']),
      isApproved: _flag(json['is_approved']),
      isPending: json['is_pending'] == null
          ? !_flag(json['is_approved'])
          : _flag(json['is_pending']),
    );
  }

  /// The endpoint answers `true`/`false` here and `1`/`0` elsewhere.
  static bool _flag(Object? value) => value == true || value == 1 || value == '1';

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
