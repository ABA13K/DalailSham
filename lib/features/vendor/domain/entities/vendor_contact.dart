import 'package:equatable/equatable.dart';

/// One contact line of the signed-in vendor's service, as the contacts
/// endpoints return it.
class VendorContact extends Equatable {
  const VendorContact({
    required this.id,
    required this.type,
    required this.value,
    this.typeLabel,
    this.isPrimary = false,
  });

  final int id;

  /// The wire token — one of `GET /vendor/contacts/types` values.
  final String type;

  /// The name the endpoint gives [type] in the requested language.
  final String? typeLabel;
  final String value;

  /// The line shown first for its type, and the one a caller reaches for.
  final bool isPrimary;

  @override
  List<Object?> get props => [id, type, typeLabel, value, isPrimary];
}
