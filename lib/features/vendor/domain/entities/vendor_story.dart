import 'package:equatable/equatable.dart';

/// What a vendor may post as a story: a picture, a clip, or a poll.
///
/// The word is also the value the endpoint takes in `type`, so the chooser and
/// the request agree on one spelling.
enum VendorStoryType {
  image('image'),
  video('video'),
  poll('poll');

  const VendorStoryType(this.wire);

  final String wire;

  /// The multipart part the file rides in, or null for a poll, which sends no
  /// file at all.
  String? get fileField => switch (this) {
    VendorStoryType.image => 'image',
    VendorStoryType.video => 'video',
    VendorStoryType.poll => null,
  };

  static VendorStoryType? fromWire(Object? value) {
    if (value is! String) return null;
    final needle = value.trim().toLowerCase();
    for (final type in values) {
      if (type.wire == needle) return type;
    }
    return null;
  }
}

/// A story the vendor just posted, as `POST /vendor/stories` answers it.
///
/// Nothing reaches customers until an admin approves it, so [isApproved] and
/// [status] are what the app reports back after a write.
class VendorStory extends Equatable {
  const VendorStory({
    required this.id,
    required this.type,
    this.caption,
    this.imageUrl,
    this.videoUrl,
    this.status,
    this.isApproved = false,
    this.isPending = true,
  });

  final int id;
  final VendorStoryType type;

  /// The caption in the language the request asked for.
  final String? caption;
  final String? imageUrl;
  final String? videoUrl;
  final String? status;
  final bool isApproved;
  final bool isPending;

  @override
  List<Object?> get props => [
    id,
    type,
    caption,
    imageUrl,
    videoUrl,
    status,
    isApproved,
    isPending,
  ];
}
