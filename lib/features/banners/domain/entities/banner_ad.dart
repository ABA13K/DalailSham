import 'package:equatable/equatable.dart';

/// Promotional banner served by the Dali Alsham API.
class BannerAd extends Equatable {
  const BannerAd({required this.id, required this.text, this.imageUrl});

  final int id;
  final String text;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, text, imageUrl];
}
