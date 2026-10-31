import 'package:equatable/equatable.dart';

/// A city region (district) served by the Dali Alsham backend.
class Region extends Equatable {
  const Region({
    required this.id,
    required this.name,
    this.imageUrl,
    this.welcomePhrase,
    this.servicesCount,
  });

  final int id;
  final String name;
  final String? imageUrl;

  /// Welcome phrase shown under [name].
  final String? welcomePhrase;

  /// Number of services published in the region, when the API reports it.
  final int? servicesCount;

  @override
  List<Object?> get props => [id, name, imageUrl, welcomePhrase, servicesCount];
}
