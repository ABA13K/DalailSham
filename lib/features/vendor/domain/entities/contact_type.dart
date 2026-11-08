import 'package:equatable/equatable.dart';

/// One of the kinds a vendor contact can take, as `GET /vendor/contacts/types`
/// returns it.
///
/// [value] is what the write endpoints take (`phone`, `whatsapp`, ...) and
/// [label] is the same word in the language the app asked for.
class ContactType extends Equatable {
  const ContactType({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}
