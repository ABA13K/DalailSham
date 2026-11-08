import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../../domain/entities/vendor_service.dart';
import '../../domain/entities/vendor_service_edit.dart';
import '../../domain/repositories/vendor_repository.dart';

enum VendorStatus { initial, loading, ready, failure }

class VendorState extends Equatable {
  const VendorState({
    this.service,
    this.status = VendorStatus.initial,
    this.isSaving = false,
    this.isEditingImage = false,
  });

  final VendorService? service;
  final VendorStatus status;

  /// A `PUT /vendor/service` is in flight.
  final bool isSaving;

  /// The main-image removal is in flight.
  final bool isEditingImage;

  /// A write is in flight, so no second one should start.
  bool get isBusy => isSaving || isEditingImage;

  VendorState copyWith({
    VendorService? service,
    VendorStatus? status,
    bool? isSaving,
    bool? isEditingImage,
  }) => VendorState(
    service: service ?? this.service,
    status: status ?? this.status,
    isSaving: isSaving ?? this.isSaving,
    isEditingImage: isEditingImage ?? this.isEditingImage,
  );

  @override
  List<Object?> get props => [service, status, isSaving, isEditingImage];
}

/// Loads and edits the signed-in vendor's own service.
///
/// Every write answers with the message to show, or null when it worked, so a
/// rejected request still reaches the vendor with the words the backend used.
class VendorCubit extends Cubit<VendorState> {
  VendorCubit(this._repository) : super(const VendorState());

  final VendorRepository _repository;

  String _locale = 'en';

  Future<void> load(String locale) async {
    _locale = locale;
    emit(const VendorState(status: VendorStatus.loading));
    await _read();
  }

  Future<String?> save(VendorServiceEdit edit) async {
    _emit(state.copyWith(isSaving: true));
    final result = await _repository.update(edit: edit, locale: _locale);
    return result.fold(
      (failure) {
        _emit(state.copyWith(isSaving: false));
        return failure.message;
      },
      (_) async {
        _emit(state.copyWith(isSaving: false));
        // `PUT` answers with the service minus its region and category, so the
        // read-only part of the page comes back from the full record.
        await _read();
        return null;
      },
    );
  }

  Future<String?> removeMainImage() =>
      _editImage(() => _repository.removeMainImage());

  Future<String?> changePassword(PasswordChange change) async {
    final result = await _repository.changePassword(change);
    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<String?> _editImage(Future<Result<void>> Function() request) async {
    _emit(state.copyWith(isEditingImage: true));
    final result = await request();
    return result.fold(
      (failure) {
        _emit(state.copyWith(isEditingImage: false));
        return failure.message;
      },
      (_) async {
        _emit(state.copyWith(isEditingImage: false));
        await _read();
        return null;
      },
    );
  }

  /// Reads the service, keeping whatever is already on screen meanwhile.
  Future<void> _read() async {
    final result = await _repository.load(_locale);
    if (isClosed) return;
    result.fold(
      (failure) => _emit(state.copyWith(status: VendorStatus.failure)),
      (service) =>
          _emit(state.copyWith(service: service, status: VendorStatus.ready)),
    );
  }

  /// A write can answer after the page that started it is gone.
  void _emit(VendorState next) {
    if (isClosed) return;
    emit(next);
  }
}
