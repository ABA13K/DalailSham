import 'dart:convert';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dali_alsham/features/auth/domain/entities/credentials.dart';
import 'package:dali_alsham/features/auth/domain/entities/join_request.dart';
import 'package:dali_alsham/features/auth/domain/entities/registration.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.payload});

  final int status;
  final Map<String, dynamic> payload;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode(payload),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.error);

  final Object error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw error;
  }

  @override
  void close({bool force = false}) {}
}

DalilAuthRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilAuthRemoteDataSource(Dio()..httpClientAdapter = adapter);

Map<String, dynamic> _sent(_StubAdapter adapter) {
  final data = adapter.captured?.data;
  return data is String
      ? jsonDecode(data) as Map<String, dynamic>
      : data as Map<String, dynamic>;
}

/// The join form posts multipart, so the text fields are read back off the
/// [FormData] rather than a JSON body.
Map<String, String> _fields(_StubAdapter adapter) {
  final form = adapter.captured?.data as FormData;
  return {for (final entry in form.fields) entry.key: entry.value};
}

Map<String, MultipartFile> _files(_StubAdapter adapter) {
  final form = adapter.captured?.data as FormData;
  return {for (final entry in form.files) entry.key: entry.value};
}

const _application = JoinRequest(
  fullName: 'Imran Alsalame',
  mobile: '0944444444',
  password: 'secret1',
  gender: AuthGender.male,
  regionId: 1,
  categoryId: 4,
  nameAr: 'الاسد',
  nameEn: 'Asad',
);

const _account = {
  'id': 12,
  'type': 'user',
  'full_name': 'Imran Alsalame',
  'email': '',
  'mobile': '0944 444 444',
  'gender': 'male',
  'address': 'Damascus',
  'avatar': 'http://127.0.0.1/storage/avatars/12.jpg',
  'locale': 'ar',
};

void main() {
  test('logs in with either identifier and keeps the handed token', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'Logged in successfully',
        'data': _account,
        'token': '5|mVV6lY6Z',
      },
    );

    final session = await _dataSource(
      adapter,
    ).login(const Credentials(login: 'imran@dalil.test', password: 'secret1'));

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.authLoginPath);
    expect(_sent(adapter), {
      'login': 'imran@dalil.test',
      'password': 'secret1',
    });
    expect(session.token, '5|mVV6lY6Z');
    expect(session.user.id, 12);
    expect(session.user.fullName, 'Imran Alsalame');
    expect(session.user.locale, 'ar');
  });

  test(
    'an empty email stays absent and a local avatar gains the live host',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: {'data': _account, 'token': '5|mVV6lY6Z'},
      );

      final user = (await _dataSource(adapter).login(
        const Credentials(login: '0944444444', password: 'secret1'),
      )).user;

      expect(user.email, isNull);
      expect(user.avatar, 'https://dalildimashq.com/storage/avatars/12.jpg');
    },
  );

  test(
    'register repeats the password, names the gender and sends no avatar',
    () async {
      final adapter = _StubAdapter(
        status: 201,
        payload: {
          'message': 'Account created successfully',
          'data': _account,
          'token': '1|FUYrrrOb',
        },
      );

      final session = await _dataSource(adapter).register(
        const Registration(
          fullName: 'Imran Alsalame',
          mobile: '0944444444',
          password: 'secret1',
          gender: AuthGender.female,
          address: 'Damascus',
          locale: 'en',
        ),
      );

      expect(adapter.captured?.path, ApiConstants.authRegisterPath);
      expect(_sent(adapter), {
        'full_name': 'Imran Alsalame',
        'email': null,
        'mobile': '0944444444',
        'password': 'secret1',
        'password_confirmation': 'secret1',
        'gender': 'female',
        'address': 'Damascus',
        'avatar': null,
        'locale': 'en',
      });
      expect(session.token, '1|FUYrrrOb');
    },
  );

  test('a join request sends the account and the service in one body', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {
        'message':
            'Join request submitted successfully, please wait for admin review',
        'data': {
          'user': _account,
          'join_request': {'id': 2, 'status': 'pending'},
        },
        'token': '7|oe8bXkQm',
      },
    );

    final session = await _dataSource(adapter).joinRequest(_application);

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.vendorJoinRequestPath);
    expect(_fields(adapter), {
      'full_name': 'Imran Alsalame',
      'mobile': '0944444444',
      'password': 'secret1',
      'password_confirmation': 'secret1',
      'gender': 'male',
      'region_id': '1',
      'category_id': '4',
      'name_ar': 'الاسد',
      'name_en': 'Asad',
      'subscription_type': 'free',
    });
    // The account is data.user, not the join_request sitting next to it.
    expect(session.token, '7|oe8bXkQm');
    expect(session.user.fullName, 'Imran Alsalame');
  });

  test('an application adds only the optional fields it was given', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {
        'data': {'user': _account},
        'token': '7|oe8bXkQm',
      },
    );

    await _dataSource(adapter).joinRequest(
      const JoinRequest(
        fullName: 'Imran Alsalame',
        mobile: '0944444444',
        password: 'secret1',
        gender: AuthGender.female,
        regionId: 1,
        categoryId: 4,
        nameAr: 'الاسد',
        nameEn: 'Asad',
        email: 'imran@dalil.test',
        phone: '0112223334',
        addressAr: 'المزة',
        descriptionEn: 'A restaurant near the park.',
      ),
    );

    expect(_fields(adapter), {
      'full_name': 'Imran Alsalame',
      'mobile': '0944444444',
      'password': 'secret1',
      'password_confirmation': 'secret1',
      'gender': 'female',
      'region_id': '1',
      'category_id': '4',
      'name_ar': 'الاسد',
      'name_en': 'Asad',
      'subscription_type': 'free',
      'email': 'imran@dalil.test',
      'phone': '0112223334',
      'address_ar': 'المزة',
      'description_en': 'A restaurant near the park.',
    });
    expect(_files(adapter), isEmpty);
  });

  test('the cover photo rides as a file next to the text fields', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {
        'data': {'user': _account},
        'token': '7|oe8bXkQm',
      },
    );

    await _dataSource(adapter).joinRequest(
      JoinRequest(
        fullName: 'Imran Alsalame',
        mobile: '0944444444',
        password: 'secret1',
        gender: AuthGender.male,
        regionId: 1,
        categoryId: 4,
        nameAr: 'الاسد',
        nameEn: 'Asad',
        mainImage: AvatarFile(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'cover.png',
        ),
      ),
    );

    // Dio has already streamed the part by the time the request is captured,
    // so what it carries is the filename and the byte count it was built with.
    final file = _files(adapter)['main_image'];
    expect(file?.filename, 'cover.png');
    expect(file?.length, 3);
  });

  test(
    'an application reply that carries no account is a parsing failure',
    () async {
      final adapter = _StubAdapter(
        status: 201,
        payload: {
          'data': {
            'join_request': {'id': 2},
          },
          'token': '7|oe8bXkQm',
        },
      );

      await expectLater(
        _dataSource(adapter).joinRequest(_application),
        throwsA(isA<ParseException>()),
      );
    },
  );

  test('a validation reply is shown with the field it names', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The mobile field is required.',
        'errors': {
          'mobile': ['The mobile has already been taken.'],
        },
      },
    );

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'secret1')),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'The mobile has already been taken.',
        ),
      ),
    );
  });

  test('wrong credentials keep the backend message', () async {
    final adapter = _StubAdapter(
      status: 401,
      payload: {'message': 'These credentials do not match our records.'},
    );

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'nope')),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'These credentials do not match our records.',
        ),
      ),
    );
  });

  test('a reply without a token is a parsing failure', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Logged in successfully', 'data': _account},
    );

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'secret1')),
      throwsA(isA<ParseException>()),
    );
  });

  test('a reply with a token but no account is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'token': '5|mVV6lY6Z'});

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'secret1')),
      throwsA(isA<ParseException>()),
    );
  });

  test('an account without a name is a parsing failure', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': {'id': 12, 'full_name': '   '},
        'token': '5|mVV6lY6Z',
      },
    );

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'secret1')),
      throwsA(
        isA<ParseException>().having(
          (e) => e.message,
          'message',
          'Account payload carried no account',
        ),
      ),
    );
  });

  test('a dead connection is a network failure', () async {
    final adapter = _ThrowingAdapter(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ),
    );

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'secret1')),
      throwsA(isA<NetworkException>()),
    );
  });

  test('a stalled request is a timeout failure', () async {
    final adapter = _ThrowingAdapter(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    await expectLater(
      _dataSource(
        adapter,
      ).login(const Credentials(login: '0944444444', password: 'secret1')),
      throwsA(isA<TimeoutException>()),
    );
  });
}
