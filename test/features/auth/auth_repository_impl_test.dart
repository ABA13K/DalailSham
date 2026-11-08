import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/settings/domain/token_repository.dart';
import 'package:dali_alsham/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dali_alsham/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_session.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_user.dart';
import 'package:dali_alsham/features/auth/domain/entities/credentials.dart';
import 'package:dali_alsham/features/auth/domain/entities/join_request.dart';
import 'package:dali_alsham/features/auth/domain/entities/registration.dart';
import 'package:dali_alsham/features/auth/domain/repositories/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockTokenRepository extends Mock implements TokenRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

const _user = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
);

const _session = AuthSession(user: _user, token: '5|mVV6lY6Z');

const _credentials = Credentials(login: '0944444444', password: 'secret1');

const _registration = Registration(
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  password: 'secret1',
  gender: AuthGender.male,
);

const _joinRequest = JoinRequest(
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  password: 'secret1',
  gender: AuthGender.male,
  regionId: 1,
  categoryId: 4,
  nameAr: 'الاسد',
  nameEn: 'Asad',
);

void main() {
  late _MockAuthRemoteDataSource remote;
  late _MockTokenRepository tokens;
  late _MockAccountRepository account;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_user);
    registerFallbackValue(_credentials);
    registerFallbackValue(_registration);
    registerFallbackValue(_joinRequest);
  });

  setUp(() {
    remote = _MockAuthRemoteDataSource();
    tokens = _MockTokenRepository();
    account = _MockAccountRepository();
    repository = AuthRepositoryImpl(remote, tokens, account);

    when(() => tokens.saveToken(any())).thenAnswer((_) async {});
    when(() => tokens.clearToken()).thenAnswer((_) async {});
    when(() => account.saveUser(any())).thenAnswer((_) async {});
    when(() => account.clearUser()).thenAnswer((_) async {});
  });

  test(
    'a login stores the handed token and the account it came with',
    () async {
      when(() => remote.login(_credentials)).thenAnswer((_) async => _session);

      final result = await repository.login(_credentials);

      expect(result.fold((_) => 'failure', (session) => session), _session);
      verify(() => tokens.saveToken('5|mVV6lY6Z')).called(1);
      verify(() => account.saveUser(_user)).called(1);
    },
  );

  test('a register stores the session the same way', () async {
    when(
      () => remote.register(_registration),
    ).thenAnswer((_) async => _session);

    final result = await repository.register(_registration);

    expect(result.fold((_) => 'failure', (session) => session), _session);
    verify(() => tokens.saveToken('5|mVV6lY6Z')).called(1);
    verify(() => account.saveUser(_user)).called(1);
  });

  test('an accepted join request signs the applicant in', () async {
    when(
      () => remote.joinRequest(_joinRequest),
    ).thenAnswer((_) async => _session);

    final result = await repository.joinRequest(_joinRequest);

    expect(result.fold((_) => 'failure', (session) => session), _session);
    verify(() => tokens.saveToken('5|mVV6lY6Z')).called(1);
    verify(() => account.saveUser(_user)).called(1);
  });

  test('a rejected join request stores nothing', () async {
    when(
      () => remote.joinRequest(any()),
    ).thenThrow(const ServerException('The mobile has already been taken.'));

    final result = await repository.joinRequest(_joinRequest);

    expect(
      result.fold((failure) => failure, (_) => 'success'),
      isA<ServerFailure>().having(
        (f) => f.message,
        'message',
        'The mobile has already been taken.',
      ),
    );
    verifyNever(() => tokens.saveToken(any()));
    verifyNever(() => account.saveUser(any()));
  });

  test(
    'a rejected login stores nothing and answers with its message',
    () async {
      when(() => remote.login(any())).thenThrow(
        const ServerException('These credentials do not match our records.'),
      );

      final result = await repository.login(_credentials);

      expect(
        result.fold((failure) => failure, (_) => 'success'),
        isA<ServerFailure>().having(
          (f) => f.message,
          'message',
          'These credentials do not match our records.',
        ),
      );
      verifyNever(() => tokens.saveToken(any()));
      verifyNever(() => account.saveUser(any()));
    },
  );

  test('signing out forgets the token and the account together', () async {
    await repository.signOut();

    verify(() => tokens.clearToken()).called(1);
    verify(() => account.clearUser()).called(1);
  });

  test('the stored account is what the drawer shows on launch', () async {
    when(() => account.getUser()).thenAnswer((_) async => _user);

    expect(await repository.account(), _user);
  });
}
