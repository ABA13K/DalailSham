import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_user.dart';
import 'package:dali_alsham/features/auth/domain/repositories/account_repository.dart';
import 'package:dali_alsham/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:dali_alsham/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/profile/domain/entities/profile_edit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class _MockAccountRepository extends Mock implements AccountRepository {}

const _user = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
);

const _edit = ProfileEdit(fullName: 'Imran Alsalame', address: 'Damascus');

const _change = PasswordChange(
  currentPassword: 'secret1',
  password: 'secret2',
  confirmation: 'secret2',
);

final _file = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'me.jpg',
);

void main() {
  late _MockProfileRemoteDataSource remote;
  late _MockAccountRepository account;
  late ProfileRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_user);
    registerFallbackValue(_edit);
    registerFallbackValue(_change);
    registerFallbackValue(_file);
  });

  setUp(() {
    remote = _MockProfileRemoteDataSource();
    account = _MockAccountRepository();
    repository = ProfileRepositoryImpl(remote, account);

    when(() => account.saveUser(any())).thenAnswer((_) async {});
  });

  test(
    'a read caches the account so the drawer greets the same name',
    () async {
      when(() => remote.profile('ar')).thenAnswer((_) async => _user);

      final result = await repository.load('ar');

      expect(result.fold((_) => 'failure', (user) => user), _user);
      verify(() => account.saveUser(_user)).called(1);
    },
  );

  test('a saved edit is cached too', () async {
    final saved = AuthUser(
      id: 12,
      fullName: 'Imran Alsalame',
      mobile: '0944444444',
      address: 'Shalash Street',
    );
    when(
      () => remote.update(edit: _edit, locale: 'ar'),
    ).thenAnswer((_) async => saved);

    final result = await repository.update(edit: _edit, locale: 'ar');

    expect(result.fold((_) => 'failure', (user) => user), saved);
    verify(() => account.saveUser(saved)).called(1);
  });

  test('a rejected edit leaves the cache alone', () async {
    when(
      () => remote.update(edit: _edit, locale: 'ar'),
    ).thenThrow(const ServerException('The full name is required.'));

    final result = await repository.update(edit: _edit, locale: 'ar');

    expect(
      result.fold((failure) => failure, (_) => 'success'),
      isA<ServerFailure>().having(
        (f) => f.message,
        'message',
        'The full name is required.',
      ),
    );
    verifyNever(() => account.saveUser(any()));
  });

  test('the picture address gains the live host', () async {
    when(
      () => remote.uploadAvatar(file: _file, locale: 'ar'),
    ).thenAnswer((_) async => 'http://127.0.0.1/storage/avatars/99.jpg');

    final result = await repository.uploadAvatar(file: _file, locale: 'ar');

    expect(
      result.fold((_) => 'failure', (avatar) => avatar),
      'https://dalildimashq.com/storage/avatars/99.jpg',
    );
  });

  test(
    'a failed upload answers with its failure, not a thrown error',
    () async {
      when(
        () => remote.uploadAvatar(
          file: any(named: 'file'),
          locale: any(named: 'locale'),
        ),
      ).thenThrow(const NetworkException());

      final result = await repository.uploadAvatar(file: _file, locale: 'ar');

      expect(
        result.fold((failure) => failure, (_) => 'success'),
        isA<NetworkFailure>(),
      );
    },
  );

  test('a removal that reached nothing still counts as done', () async {
    when(remote.removeAvatar).thenAnswer((_) async {});

    expect(await repository.removeAvatar(), isA<Success<void>>());
  });

  test('a refused password change is turned into a failure', () async {
    when(
      () => remote.changePassword(_change),
    ).thenThrow(const ServerException('Current password is incorrect'));

    final result = await repository.changePassword(_change);

    expect(
      result.fold((failure) => failure, (_) => 'success'),
      isA<ServerFailure>().having(
        (f) => f.message,
        'message',
        'Current password is incorrect',
      ),
    );
  });

  test('a vendor refused deletion keeps the admin message', () async {
    when(() => remote.deleteAccount('12345678')).thenThrow(
      const ServerException(
        'Cannot delete vendor account with services. Contact admin first.',
      ),
    );

    final result = await repository.deleteAccount('12345678');

    expect(
      result.fold((failure) => failure, (_) => 'success'),
      isA<ServerFailure>().having(
        (f) => f.message,
        'message',
        'Cannot delete vendor account with services. Contact admin first.',
      ),
    );
  });

  test('a stalled read is a timeout failure', () async {
    when(() => remote.profile('en')).thenThrow(const TimeoutException());

    expect(
      await repository.load('en'),
      isA<FailureResult<AuthUser>>().having(
        (r) => r.failure,
        'failure',
        isA<TimeoutFailure>(),
      ),
    );
  });
}
