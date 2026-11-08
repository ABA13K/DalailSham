import 'package:equatable/equatable.dart';

import 'vendor_story.dart';

/// What `POST /vendor/stories` is sent.
///
/// The picture or clip travels beside these fields as a multipart part, so it
/// is not held here — a write that picked one passes it along separately, the
/// same way a product write passes its photo.
class VendorStoryEdit extends Equatable {
  const VendorStoryEdit({
    required this.type,
    this.captionAr,
    this.captionEn,
    this.poll,
  });

  final VendorStoryType type;
  final String? captionAr;
  final String? captionEn;

  /// Only a poll carries one; the other two types leave it null.
  final VendorStoryPollEdit? poll;

  @override
  List<Object?> get props => [type, captionAr, captionEn, poll];
}

/// The question and the choices a poll story asks customers to vote on.
class VendorStoryPollEdit extends Equatable {
  const VendorStoryPollEdit({
    required this.questionAr,
    this.questionEn,
    required this.options,
  });

  final String questionAr;
  final String? questionEn;

  /// In the order the vendor wrote them, which is the order the endpoint keeps.
  final List<VendorStoryOptionEdit> options;

  @override
  List<Object?> get props => [questionAr, questionEn, options];
}

/// One answer to a poll question.
class VendorStoryOptionEdit extends Equatable {
  const VendorStoryOptionEdit({required this.optionAr, this.optionEn});

  final String optionAr;
  final String? optionEn;

  @override
  List<Object?> get props => [optionAr, optionEn];
}
