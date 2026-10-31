import 'package:equatable/equatable.dart';

/// A category served by the Dali Alsham backend.
class ExploreCategory extends Equatable {
  const ExploreCategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.tagline,
  });

  final int id;
  final String name;
  final String? imageUrl;

  /// Inspirational phrase shown under [name].
  final String? tagline;

  @override
  List<Object?> get props => [id, name, imageUrl, tagline];
}
