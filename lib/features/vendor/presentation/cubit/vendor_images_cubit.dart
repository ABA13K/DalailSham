import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../profile/domain/repositories/avatar_picker.dart';
import '../../domain/entities/vendor_image_gallery.dart';
import '../../domain/repositories/vendor_image_repository.dart';

enum VendorImagesStatus { initial, loading, ready, failure }

class VendorImagesState extends Equatable {
  const VendorImagesState({
    this.gallery = const VendorImageGallery(
      images: [],
      maxAllowed: 0,
      canAdd: false,
    ),
    this.status = VendorImagesStatus.initial,
    this.isBusy = false,
  });

  final VendorImageGallery gallery;
  final VendorImagesStatus status;

  /// A write is in flight, so no second one should start.
  final bool isBusy;

  VendorImagesState copyWith({
    VendorImageGallery? gallery,
    VendorImagesStatus? status,
    bool? isBusy,
  }) => VendorImagesState(
    gallery: gallery ?? this.gallery,
    status: status ?? this.status,
    isBusy: isBusy ?? this.isBusy,
  );

  @override
  List<Object?> get props => [gallery, status, isBusy];
}

/// Reads and edits the sub-images of the signed-in vendor's service.
///
/// Every write answers with the message to show, or null when it worked, so a
/// rejected request still reaches the vendor with the words the backend used.
class VendorImagesCubit extends Cubit<VendorImagesState> {
  VendorImagesCubit(this._repository, this._picker, {String locale = 'en'})
    : _locale = locale,
      super(const VendorImagesState());

  final VendorImageRepository _repository;
  final AvatarPicker _picker;

  String _locale;

  Future<void> load(String locale) async {
    _locale = locale;
    emit(const VendorImagesState(status: VendorImagesStatus.loading));
    await _read();
  }

  /// Opens the gallery chooser, sends what was picked, and reads the limit back
  /// because the reply only names the one picture it stored.
  Future<String?> add() async {
    final file = await _picker.pick();
    if (file == null) return null;
    return _write(() => _repository.add(file: file, locale: _locale));
  }

  Future<String?> remove({required int id}) =>
      _write(() => _repository.remove(id: id, locale: _locale));

  Future<String?> clear() => _write(() => _repository.clear(locale: _locale));

  Future<String?> _write(Future<Result<Object?>> Function() request) async {
    _emit(state.copyWith(isBusy: true));
    final result = await request();
    return result.fold(
      (failure) {
        _emit(state.copyWith(isBusy: false));
        return failure.message;
      },
      (_) async {
        _emit(state.copyWith(isBusy: false));
        // The limit and the approval flags are the server's, so the page shows
        // the gallery it re-reads rather than what the write echoed back.
        await _read();
        return null;
      },
    );
  }

  /// Reads the gallery, keeping whatever is already on screen meanwhile.
  Future<void> _read() async {
    final result = await _repository.gallery(locale: _locale);
    if (isClosed) return;
    result.fold(
      (failure) => _emit(state.copyWith(status: VendorImagesStatus.failure)),
      (gallery) => _emit(
        state.copyWith(gallery: gallery, status: VendorImagesStatus.ready),
      ),
    );
  }

  /// A write can answer after the page that started it is gone.
  void _emit(VendorImagesState next) {
    if (isClosed) return;
    emit(next);
  }
}
