import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';

/// JSON/DTO representation of [BannerAd].
class BannerAdModel extends BannerAd {
  const BannerAdModel({required super.id, required super.text, super.imageUrl});

  factory BannerAdModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    if (id is! num || text is! String || text.trim().isEmpty) {
      throw const FormatException('Invalid banner payload');
    }

    return BannerAdModel(
      id: id.toInt(),
      text: text.trim(),
      imageUrl: normalizeRemoteImageUrl(json['image']),
    );
  }
}
