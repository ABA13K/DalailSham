import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/contact_group.dart';
import '../../domain/entities/vendor_contact_edit.dart';
import '../../domain/repositories/vendor_contact_repository.dart';

enum VendorContactsStatus { initial, loading, ready, failure }

class VendorContactsState extends Equatable {
  const VendorContactsState({
    this.groups = const [],
    this.status = VendorContactsStatus.initial,
    this.isSaving = false,
  });

  final List<ContactGroup> groups;
  final VendorContactsStatus status;

  /// A write is in flight, so no second one should start.
  final bool isSaving;

  VendorContactsState copyWith({
    List<ContactGroup>? groups,
    VendorContactsStatus? status,
    bool? isSaving,
  }) => VendorContactsState(
    groups: groups ?? this.groups,
    status: status ?? this.status,
    isSaving: isSaving ?? this.isSaving,
  );

  @override
  List<Object?> get props => [groups, status, isSaving];
}

/// Reads and edits the signed-in vendor's contact lines.
///
/// Every write answers with the message to show, or null when it worked, so a
/// rejected request still reaches the vendor with the words the backend used.
class VendorContactsCubit extends Cubit<VendorContactsState> {
  /// [locale] is the language the writes answer in; the page that only writes
  /// passes the one it is showing, the one that reads calls [load] first.
  VendorContactsCubit(this._repository, {String locale = 'en'})
    : _locale = locale,
      super(const VendorContactsState());

  final VendorContactRepository _repository;

  String _locale;

  Future<void> load(String locale) async {
    _locale = locale;
    emit(const VendorContactsState(status: VendorContactsStatus.loading));
    await _read();
  }

  Future<String?> add(VendorContactEdit edit) =>
      _write(() => _repository.add(edit: edit, locale: _locale));

  Future<String?> update({required int id, required VendorContactEdit edit}) =>
      _write(() => _repository.update(id: id, edit: edit, locale: _locale));

  Future<String?> remove({required int id}) =>
      _write(() => _repository.remove(id: id, locale: _locale));

  Future<String?> setPrimary({required int id}) =>
      _write(() => _repository.setPrimary(id: id, locale: _locale));

  Future<String?> _write(Future<Result<Object?>> Function() request) async {
    _emit(state.copyWith(isSaving: true));
    final result = await request();
    return result.fold(
      (failure) {
        _emit(state.copyWith(isSaving: false));
        return failure.message;
      },
      (_) async {
        _emit(state.copyWith(isSaving: false));
        // The grouped read is what the page shows, and it is the only reply
        // carrying the counts and which line leads each type.
        await _read();
        return null;
      },
    );
  }

  /// Reads the groups, keeping whatever is already on screen meanwhile.
  Future<void> _read() async {
    final result = await _repository.contacts(locale: _locale);
    if (isClosed) return;
    result.fold(
      (failure) => _emit(state.copyWith(status: VendorContactsStatus.failure)),
      (groups) => _emit(
        state.copyWith(groups: groups, status: VendorContactsStatus.ready),
      ),
    );
  }

  /// A write can answer after the page that started it is gone.
  void _emit(VendorContactsState next) {
    if (isClosed) return;
    emit(next);
  }
}
