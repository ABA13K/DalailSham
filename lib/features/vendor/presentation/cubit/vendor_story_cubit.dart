import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_story_edit.dart';
import '../../domain/repositories/vendor_story_repository.dart';

class VendorStoryState extends Equatable {
  const VendorStoryState({this.isBusy = false});

  /// A post is in flight, so a second one should not start behind it.
  final bool isBusy;

  @override
  List<Object?> get props => [isBusy];
}

/// Writes the vendor's own story and waits for an admin to approve it.
///
/// [post] answers with the message to show, or null when the story was stored,
/// so a rejected request still reaches the vendor with the words the backend
/// used.
class VendorStoryCubit extends Cubit<VendorStoryState> {
  VendorStoryCubit(this._repository) : super(const VendorStoryState());

  final VendorStoryRepository _repository;

  Future<String?> post({
    required VendorStoryEdit edit,
    AvatarFile? file,
    required String locale,
  }) async {
    _emit(const VendorStoryState(isBusy: true));
    final result = await _repository.add(
      edit: edit,
      file: file,
      locale: locale,
    );
    _emit(const VendorStoryState());

    return result.fold((failure) => failure.message, (_) => null);
  }

  /// A reply can land after the form that posted it is already gone.
  void _emit(VendorStoryState next) {
    if (isClosed) return;
    emit(next);
  }
}
