import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_review.dart';

/// JSON/DTO representation of [ServiceReview].
class ServiceReviewModel extends ServiceReview {
  const ServiceReviewModel({
    required super.rating,
    super.id,
    super.comment,
    super.isMine,
    super.userName,
    super.userAvatar,
    super.createdAt,
  });

  factory ServiceReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final createdAt = json['created_at'];
    return ServiceReviewModel(
      rating: ((json['rating'] as num?)?.toInt() ?? 0).clamp(0, 5),
      id: (json['id'] as num?)?.toInt(),
      comment: _text(json['comment']),
      isMine: json['is_mine'] == true,
      userName: user is Map<String, dynamic> ? _text(user['name']) : null,
      userAvatar: user is Map<String, dynamic>
          ? normalizeRemoteImageUrl(user['avatar'])
          : null,
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}