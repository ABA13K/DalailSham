import 'package:equatable/equatable.dart';

/// The outcome of a favorite add/remove call, carrying the backend's `message`
/// so the presentation layer can show it.
class FavoriteMutation extends Equatable {
  const FavoriteMutation({required this.isFavorited, this.message = ''});

  final bool isFavorited;
  final String message;

  @override
  List<Object?> get props => [isFavorited, message];
}
