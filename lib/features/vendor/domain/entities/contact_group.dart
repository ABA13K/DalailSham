import 'package:equatable/equatable.dart';

import 'vendor_contact.dart';

/// All the vendor's contacts of one type, as `GET /vendor/contacts` groups them.
///
/// The reply also spells out `count`, `has_primary` and `primary`; all three are
/// read back from [contacts], whose rows carry `is_primary`, so the group cannot
/// disagree with its own rows.
class ContactGroup extends Equatable {
  const ContactGroup({
    required this.type,
    required this.contacts,
    this.typeLabel,
  });

  final String type;

  /// The name the endpoint gives [type] in the requested language.
  final String? typeLabel;
  final List<VendorContact> contacts;

  int get count => contacts.length;

  bool get hasPrimary => primary != null;

  VendorContact? get primary {
    for (final contact in contacts) {
      if (contact.isPrimary) return contact;
    }
    return null;
  }

  @override
  List<Object?> get props => [type, typeLabel, contacts];
}
