import '../../domain/entities/vendor_contact.dart';

/// JSON/DTO representation of [VendorContact].
class VendorContactModel extends VendorContact {
  const VendorContactModel({
    required super.id,
    required super.type,
    required super.value,
    super.typeLabel,
    super.isPrimary,
  });

  factory VendorContactModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final type = _text(json['type']);
    final value = _text(json['value']);
    if (id is! num || type == null || value == null) {
      throw const FormatException('Invalid vendor contact payload');
    }

    return VendorContactModel(
      id: id.toInt(),
      type: type,
      typeLabel: _text(json['type_label']),
      value: value,
      isPrimary: json['is_primary'] == true,
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
