import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/avatar_file.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../../domain/entities/profile_edit.dart';
import '../../domain/repositories/avatar_picker.dart';
import '../../domain/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, ready, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.user,
    this.status = ProfileStatus.initial,
    this.isSaving = false,
    this.isEditingAvatar = false,
  });

  final AuthUser? user;
  final ProfileStatus status;

  /// A `PUT /user/profile` is in flight.
  final bool isSaving;

  /// An avatar upload or removal is in flight.
  final bool isEditingAvatar;

  /// A write is in flight, so no second one should start.
  bool get isBusy => isSaving || isEditingAvatar;

  ProfileState copyWith({
    AuthUser? user,
    ProfileStatus? status,
    bool? isSaving,
    bool? isEditingAvatar,
  }) => ProfileState(
    user: user ?? this.user,
    status: status ?? this.status,
    isSaving: isSaving ?? this.isSaving,
    isEditingAvatar: isEditingAvatar ?? this.isEditingAvatar,
  );

  @override
  List<Object?> get props => [user, status, isSaving, isEditingAvatar];
}

/// Loads and edits the signed-in account.
///
/// Every write answers with the message to show, or null when it worked, so a
/// rejected request still reaches the user with the words the backend used.
/// [AuthCubit] is re-read after a change so the drawer shows the account the
/// page just saved.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._picker, this._auth)
    : super(const ProfileState());

  final ProfileRepository _repository;
  final AvatarPicker _picker;
  final AuthCubit _auth;

  String _locale = 'en';

  Future<void> load(String locale) async {
    _locale = locale;
    emit(const ProfileState(status: ProfileStatus.loading));
    await _read();
  }

  Future<String?> save(ProfileEdit edit) async {
    _emit(state.copyWith(isSaving: true));
    final result = await _repository.update(edit: edit, locale: _locale);
    return result.fold(
      (failure) {
        _emit(state.copyWith(isSaving: false));
        return failure.message;
      },
      (user) async {
        _emit(
          state.copyWith(
            user: user,
            status: ProfileStatus.ready,
            isSaving: false,
          ),
        );
        await _auth.load();
        return null;
      },
    );
  }

  /// Opens the chooser and uploads what was picked; backing out stays silent.
  /// A chooser that fails to open — a permission the OS refused, say — answers
  /// with [pickFailedMessage], which the page takes from its own strings.
  Future<String?> pickAvatar(String pickFailedMessage) async {
    final AvatarFile? picked;
    try {
      picked = await _picker.pick();
    } catch (_) {
      return pickFailedMessage;
    }
    if (picked == null) return null;
    return _upload(picked);
  }

  Future<String?> _upload(AvatarFile file) =>
      _editAvatar(() => _repository.uploadAvatar(file: file, locale: _locale));

  Future<String?> removeAvatar() => _editAvatar(_repository.removeAvatar);

  Future<String?> changePassword(PasswordChange change) async {
    final result = await _repository.changePassword(change);
    return result.fold((failure) => failure.message, (_) => null);
  }

  /// Deletes the account and signs this device out with it.
  Future<String?> deleteAccount(String password) async {
    final result = await _repository.deleteAccount(password);
    return result.fold((failure) => failure.message, (_) async {
      await _auth.signOut();
      return null;
    });
  }

  Future<String?> _editAvatar(
    Future<Result<Object?>> Function() request,
  ) async {
    _emit(state.copyWith(isEditingAvatar: true));
    final result = await request();
    return result.fold(
      (failure) {
        _emit(state.copyWith(isEditingAvatar: false));
        return failure.message;
      },
      (_) async {
        // The picture lives on the account, so the account is read back here
        // rather than guessed at from the reply.
        _emit(state.copyWith(isEditingAvatar: false));
        await _read();
        await _auth.load();
        return null;
      },
    );
  }

  /// Reads the account, keeping whatever is already on screen meanwhile.
  Future<void> _read() async {
    final result = await _repository.load(_locale);
    if (isClosed) return;
    result.fold(
      (failure) => _emit(state.copyWith(status: ProfileStatus.failure)),
      (user) => _emit(state.copyWith(user: user, status: ProfileStatus.ready)),
    );
  }

  /// A write can answer after the page that started it is gone.
  void _emit(ProfileState next) {
    if (isClosed) return;
    emit(next);
  }
}
