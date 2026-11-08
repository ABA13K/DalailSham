import 'dart:async';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_user.dart';
import 'package:dali_alsham/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/profile/domain/entities/profile_edit.dart';
import 'package:dali_alsham/features/profile/domain/repositories/avatar_picker.dart';
import 'package:dali_alsham/features/profile/domain/repositories/profile_repository.dart';
import 'package:dali_alsham/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAvatarPicker extends Mock implements AvatarPicker {}

class _MockAuthCubit extends Mock implements AuthCubit {}

const _user = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  address: 'Damascus',
);

const _renamed = AuthUser(
  id: 12,
  fullName: 'Imran Al-Salame',
  mobile: '0944444444',
  address: 'Damascus',
);

const _edit = ProfileEdit(fullName: 'Imran Al-Salame', address: 'Damascus');

const _change = PasswordChange(
  currentPassword: 'secret1',
  password: 'secret2',
  confirmation: 'secret2',
);

final _file = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'me.jpg',
);

const _withPicture = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  avatar: 'https://dalildimashq.com/storage/avatars/99.jpg',
);

void main() {
  late _MockProfileRepository repository;
  late _MockAvatarPicker picker;
  late _MockAuthCubit auth;
  late ProfileCubit cubit;

  setUpAll(() {
    registerFallbackValue(_edit);
    registerFallbackValue(_file);
    registerFallbackValue(_change);
  });

  setUp(() {
    repository = _MockProfileRepository();
    picker = _MockAvatarPicker();
    auth = _MockAuthCubit();
    cubit = ProfileCubit(repository, picker, auth);

    when(() => auth.load()).thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(
      () => repository.load(any()),
    ).thenAnswer((_) async => const Success(_user));
  });

  tearDown(() async => cubit.close());

  test('opening the page reads the account', () async {
    await cubit.load('ar');

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.user, _user);
    verify(() => repository.load('ar')).called(1);
  });

  test('a read that failed offers the same retry the page shows', () async {
    when(
      () => repository.load(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure('Nope')));

    await cubit.load('en');

    expect(cubit.state.status, ProfileStatus.failure);
    expect(cubit.state.user, isNull);
  });

  test('a saved edit is kept on screen and handed to the drawer', () async {
    when(
      () => repository.update(edit: _edit, locale: 'ar'),
    ).thenAnswer((_) async => const Success(_renamed));

    await cubit.load('ar');
    expect(await cubit.save(_edit), isNull);

    expect(cubit.state.user, _renamed);
    expect(cubit.state.isSaving, isFalse);
    verify(() => auth.load()).called(1);
  });

  test(
    'a rejected edit keeps the picture on screen and answers verbatim',
    () async {
      await cubit.load('ar');
      when(
        () => repository.update(
          edit: any(named: 'edit'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult(
          ServerFailure('The full name field is required.'),
        ),
      );

      final message = await cubit.save(const ProfileEdit(fullName: ''));

      expect(message, 'The full name field is required.');
      expect(cubit.state.user, _user);
      expect(cubit.state.isSaving, isFalse);
      verifyNever(() => auth.load());
    },
  );

  test('saving shows the form is busy until the answer arrives', () async {
    final pending = Completer<Result<AuthUser>>();
    when(
      () => repository.update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) => pending.future);
    await cubit.load('ar');

    final saved = cubit.save(_edit);
    await pumpEventQueue();
    expect(cubit.state.isBusy, isTrue);

    pending.complete(const Success(_renamed));
    expect(await saved, isNull);
    await pumpEventQueue();

    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.isEditingAvatar, isFalse);
  });

  test('backing out of the chooser uploads nothing and says nothing', () async {
    when(picker.pick).thenAnswer((_) async => null);

    expect(await cubit.pickAvatar('Couldn’t get that photo'), isNull);
    verifyNever(
      () => repository.uploadAvatar(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );
  });

  test(
    'a chooser the system refused answers with the page’s own words',
    () async {
      when(picker.pick).thenThrow(Exception('permission denied'));

      expect(await cubit.pickAvatar('Couldn’t get that photo'), isNotNull);
    },
  );

  test('an upload is followed by a fresh read of the account', () async {
    when(picker.pick).thenAnswer((_) async => _file);
    when(
      () => repository.uploadAvatar(file: _file, locale: 'ar'),
    ).thenAnswer((_) async => const Success('https://dalildimashq.com/a.jpg'));
    var reads = 0;
    when(() => repository.load('ar')).thenAnswer((_) async {
      reads++;
      return Success(reads == 1 ? _user : _withPicture);
    });

    await cubit.load('ar');
    final message = await cubit.pickAvatar('Couldn’t get that photo');

    expect(message, isNull);
    expect(cubit.state.user, _withPicture);
    expect(cubit.state.isEditingAvatar, isFalse);
    verify(() => repository.load('ar')).called(2);
    verify(() => auth.load()).called(1);
  });

  test('a refused upload reports it and leaves the picture alone', () async {
    when(picker.pick).thenAnswer((_) async => _file);
    when(() => repository.uploadAvatar(file: _file, locale: 'ar')).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('The image is too large.')),
    );

    await cubit.load('ar');
    expect(
      await cubit.pickAvatar('Couldn’t get that photo'),
      'The image is too large.',
    );
    expect(cubit.state.user, _user);
    expect(cubit.state.isEditingAvatar, isFalse);
  });

  test('removing the picture re-reads the account, not the reply', () async {
    when(
      () => repository.removeAvatar(),
    ).thenAnswer((_) async => const Success<void>(null));
    var reads = 0;
    when(() => repository.load('ar')).thenAnswer((_) async {
      reads++;
      return Success(reads == 1 ? _withPicture : _user);
    });

    await cubit.load('ar');
    expect(cubit.state.user?.avatar, isNotNull);

    expect(await cubit.removeAvatar(), isNull);
    expect(cubit.state.user, _user);
    verify(() => auth.load()).called(1);
  });

  test('a password change answers with the backend sentence', () async {
    when(
      () => repository.changePassword(_change),
    ).thenAnswer((_) async => const Success<void>(null));
    expect(await cubit.changePassword(_change), isNull);

    when(() => repository.changePassword(any())).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('Password confirmation does not match'),
      ),
    );
    expect(
      await cubit.changePassword(_change),
      'Password confirmation does not match',
    );
  });

  test('a deleted account signs this device out', () async {
    when(
      () => repository.deleteAccount('12345678'),
    ).thenAnswer((_) async => const Success<void>(null));

    expect(await cubit.deleteAccount('12345678'), isNull);
    verify(() => auth.signOut()).called(1);
  });

  test('a vendor refused deletion keeps the session', () async {
    when(() => repository.deleteAccount(any())).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure(
          'Cannot delete vendor account with services. Contact admin first.',
        ),
      ),
    );

    expect(
      await cubit.deleteAccount('12345678'),
      'Cannot delete vendor account with services. Contact admin first.',
    );
    verifyNever(() => auth.signOut());
  });
}
