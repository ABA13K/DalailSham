import 'package:equatable/equatable.dart';

/// What `POST /vendor/contacts` and `PUT /vendor/contacts/{id}` take: the type
/// token and the value, nothing else.
class VendorContactEdit extends Equatable {
  const VendorContactEdit({required this.type, required this.value});

  final String type;
  final String value;

  @override
  List<Object?> get props => [type, value];
}
