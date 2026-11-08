import 'package:equatable/equatable.dart';

/// One of the sub-images a vendor publishes with their service.
///
/// The backend keeps a new picture out of the public listing until an admin
/// approves it, so the flag is what the gallery shows instead of a guess.
class VendorImage extends Equatable {
  const VendorImage({
    required this.id,
    required this.url,
    required this.isApproved,
    required this.sortOrder,
  });

  final int id;
  final String url;
  final bool isApproved;

  /// Where the admin's gallery puts the picture, lowest first.
  final int sortOrder;

  @override
  List<Object?> get props => [id, url, isApproved, sortOrder];
}
