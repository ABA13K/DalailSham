import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/settings/domain/token_repository.dart';
import 'package:dali_alsham/core/settings/presentation/token_cubit.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_session.dart';
import 'package:dali_alsham/features/auth/domain/entities/auth_user.dart';
import 'package:dali_alsham/features/auth/domain/entities/credentials.dart';
import 'package:dali_alsham/features/auth/domain/entities/join_request.dart';
import 'package:dali_alsham/features/auth/domain/entities/registration.dart';
import 'package:dali_alsham/features/auth/domain/repositories/auth_repository.dart';
import 'package:dali_alsham/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenRepository extends Mock implements TokenRepository {}

const _user = AuthUser(
  id: 12,
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  locale: 'ar',
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
  late _MockAuthRepository repository;
  late _MockTokenRepository tokenRepository;
  late TokenCubit tokens;
  late AuthCubit cubit;

  setUpAll(() {
    registerFallbackValue(_credentials);
    registerFallbackValue(_joinRequest);
  });

  setUp(() {
    repository = _MockAuthRepository();
    tokenRepository = _MockTokenRepository();
    tokens = TokenCubit(tokenRepository);
    cubit = AuthCubit(repository, tokens);

    when(() => repository.account()).thenAnswer((_) async => null);
    when(() => repository.signOut()).thenAnswer((_) async {});
    when(() => tokenRepository.getToken()).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await cubit.close();
    await tokens.close();
  });

  test('restores the account a previous launch stored', () async {
    when(() => repository.account()).thenAnswer((_) async => _user);

    await cubit.load();

    expect(cubit.state.user, _user);
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('a login reads the token the repository just stored', () async {
    when(
      () => repository.login(_credentials),
    ).thenAnswer((_) async => const Success(_session));
    when(
      () => tokenRepository.getToken(),
    ).thenAnswer((_) async => '5|mVV6lY6Z');

    final message = await cubit.login(_credentials);

    expect(message, isNull);
    expect(cubit.state.user, _user);
    expect(tokens.state, '5|mVV6lY6Z');
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('a register signs the new account straight in', () async {
    when(
      () => repository.register(_registration),
    ).thenAnswer((_) async => const Success(_session));
    when(
      () => tokenRepository.getToken(),
    ).thenAnswer((_) async => '5|mVV6lY6Z');

    expect(await cubit.register(_registration), isNull);
    expect(cubit.state.user, _user);
  });

  test('a join request leaves the applicant signed in', () async {
    when(
      () => repository.joinRequest(_joinRequest),
    ).thenAnswer((_) async => const Success(_session));
    when(
      () => tokenRepository.getToken(),
    ).thenAnswer((_) async => '5|mVV6lY6Z');

    expect(await cubit.joinRequest(_joinRequest), isNull);
    expect(cubit.state.user, _user);
    expect(tokens.state, '5|mVV6lY6Z');
  });

  test('a rejected join request answers with the backend sentence', () async {
    when(() => repository.joinRequest(any())).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('The name ar field is required.')),
    );

    expect(
      await cubit.joinRequest(_joinRequest),
      'The name ar field is required.',
    );
    expect(cubit.state, const AuthState());
  });

  test('submitting is visible while the request is in flight', () async {
    final pending = Completer<Result<AuthSession>>();
    when(() => repository.login(any())).thenAnswer((_) => pending.future);
    when(
      () => tokenRepository.getToken(),
    ).thenAnswer((_) async => '5|mVV6lY6Z');

    final submitted = <bool>[];
    cubit.stream.listen((state) => submitted.add(state.isSubmitting));

    final result = cubit.login(_credentials);
    await pumpEventQueue();
    expect(cubit.state.isSubmitting, isTrue);

    pending.complete(const Success(_session));
    expect(await result, isNull);
    await pumpEventQueue();

    expect(submitted, [true, false]);
  });

  test('a rejected login answers with the backend message', () async {
    when(() => repository.login(any())).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('These credentials do not match our records.'),
      ),
    );

    final message = await cubit.login(_credentials);

    expect(message, 'These credentials do not match our records.');
    expect(cubit.state, const AuthState());
  });

  test('the same rejection twice still answers', () async {
    when(() => repository.login(any())).thenAnswer(
      (_) async => const FailureResult(ServerFailure('Wrong password')),
    );

    expect(await cubit.login(_credentials), 'Wrong password');
    expect(await cubit.login(_credentials), 'Wrong password');
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('a sign-out forgets the account and the stored token', () async {
    when(
      () => repository.login(any()),
    ).thenAnswer((_) async => const Success(_session));
    when(
      () => tokenRepository.getToken(),
    ).thenAnswer((_) async => '5|mVV6lY6Z');
    await cubit.login(_credentials);

    when(() => tokenRepository.getToken()).thenAnswer((_) async => null);

    await cubit.signOut();

    verify(() => repository.signOut()).called(1);
    expect(cubit.state.user, isNull);
    expect(tokens.state, isNull);
  });
}
