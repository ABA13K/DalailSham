import '../../domain/entities/contact_group.dart';
import 'vendor_contact_model.dart';

/// JSON/DTO representation of a [ContactGroup].
class ContactGroupModel extends ContactGroup {
  const ContactGroupModel({
    required super.type,
    required super.contacts,
    super.typeLabel,
  });

  factory ContactGroupModel.fromJson(Map<String, dynamic> json) {
    final type = _text(json['type']);
    final rows = json['contacts'];
    if (type == null || rows is! List) {
      throw const FormatException('Invalid contact group payload');
    }

    // The grouped reply names the type once, on the group, and leaves each row
    // with only its id, value and flag — so both are read with what the group
    // arrived with.
    final typeLabel = _text(json['type_label']);
    return ContactGroupModel(
      type: type,
      typeLabel: typeLabel,
      contacts: [
        for (final row in rows.whereType<Map<String, dynamic>>())
          VendorContactModel.fromJson(<String, dynamic>{
            ...row,
            'type': row['type'] ?? type,
            'type_label': row['type_label'] ?? typeLabel,
          }),
      ],
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
