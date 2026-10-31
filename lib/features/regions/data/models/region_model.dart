import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';

/// JSON/DTO representation of [Region].
class RegionModel extends Region {
  const RegionModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.welcomePhrase,
    super.servicesCount,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! num || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid region payload');
    }

    final phrase = json['welcome_phrase'];
    final services = json['services_count'];
    return RegionModel(
      id: id.toInt(),
      name: name.trim(),
      imageUrl: normalizeRemoteImageUrl(json['image']),
      welcomePhrase: phrase is String && phrase.trim().isNotEmpty
          ? phrase.trim()
          : null,
      servicesCount: services is num ? services.toInt() : null,
    );
  }
}
