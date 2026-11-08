import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A photo chosen for `POST /user/profile/avatar`, held as bytes so the domain
/// layer stays free of the picker plugin.
class AvatarFile extends Equatable {
  const AvatarFile({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  @override
  List<Object?> get props => [bytes, fileName];
}
