import '../../domain/entities/contact_type.dart';

/// JSON/DTO representation of [ContactType].
class ContactTypeModel extends ContactType {
  const ContactTypeModel({required super.value, required super.label});

  factory ContactTypeModel.fromJson(Map<String, dynamic> json) {
    final value = _text(json['value']);
    final label = _text(json['label']);
    if (value == null || label == null) {
      throw const FormatException('Invalid contact type payload');
    }
    return ContactTypeModel(value: value, label: label);
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
