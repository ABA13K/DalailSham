import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/vendor_amenity_edit.dart';
import '../../domain/entities/vendor_amenity_gallery.dart';
import '../../domain/repositories/vendor_amenity_repository.dart';

enum VendorAmenitiesStatus { initial, loading, ready, failure }

class VendorAmenitiesState extends Equatable {
  const VendorAmenitiesState({
    this.gallery = const VendorAmenityGallery(
      amenities: [],
      maxAllowed: 0,
      canAdd: false,
    ),
    this.status = VendorAmenitiesStatus.initial,
    this.isBusy = false,
  });

  final VendorAmenityGallery gallery;
  final VendorAmenitiesStatus status;

  /// A write is in flight, so no second one should start.
  final bool isBusy;

  VendorAmenitiesState copyWith({
    VendorAmenityGallery? gallery,
    VendorAmenitiesStatus? status,
    bool? isBusy,
  }) => VendorAmenitiesState(
    gallery: gallery ?? this.gallery,
    status: status ?? this.status,
    isBusy: isBusy ?? this.isBusy,
  );

  @override
  List<Object?> get props => [gallery, status, isBusy];
}

/// Reads and edits the amenities of the signed-in vendor's service.
///
/// Every write answers with the message to show, or null when it worked, so a
/// rejected request still reaches the vendor with the words the backend used —
/// including the one it uses when the amenity already exists.
class VendorAmenitiesCubit extends Cubit<VendorAmenitiesState> {
  VendorAmenitiesCubit(this._repository, {String locale = 'en'})
    : _locale = locale,
      super(const VendorAmenitiesState());

  final VendorAmenityRepository _repository;

  String _locale;

  Future<void> load(String locale) async {
    _locale = locale;
    emit(const VendorAmenitiesState(status: VendorAmenitiesStatus.loading));
    await _read();
  }

  Future<String?> add(VendorAmenityEdit edit) =>
      _write(() => _repository.add(edit: edit, locale: _locale));

  Future<String?> update({required int id, required VendorAmenityEdit edit}) =>
      _write(() => _repository.update(id: id, edit: edit, locale: _locale));

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
      (failure) => _emit(state.copyWith(status: VendorAmenitiesStatus.failure)),
      (gallery) => _emit(
        state.copyWith(gallery: gallery, status: VendorAmenitiesStatus.ready),
      ),
    );
  }

  /// A write can answer after the page that started it is gone.
  void _emit(VendorAmenitiesState next) {
    if (isClosed) return;
    emit(next);
  }
}
