import 'dart:convert';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/auth/domain/entities/registration.dart';
import 'package:dali_alsham/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/profile/domain/entities/profile_edit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.payload});

  final int status;
  final Object? payload;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode(payload ?? <String, dynamic>{}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DalilProfileRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilProfileRemoteDataSource(Dio()..httpClientAdapter = adapter);

Map<String, dynamic> _sent(_StubAdapter adapter) {
  final data = adapter.captured?.data;
  return data is String
      ? jsonDecode(data) as Map<String, dynamic>
      : data as Map<String, dynamic>;
}

const _account = {
  'id': 12,
  'type': 'user',
  'full_name': 'Imran Alsalame',
  'email': 'imran@dalil.test',
  'email_verified_at': null,
  'is_email_verified': false,
  'mobile': '0944444444',
  'mobile_verified_at': null,
  'is_mobile_verified': false,
  'avatar': 'http://127.0.0.1/storage/avatars/12.jpg',
  'gender': 'male',
  'address': 'Damascus',
  'locale': 'ar',
  'created_at': '2026-01-04T09:12:00Z',
};

void main() {
  test('reads the account with the language it asks for', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _account});

    final user = await _dataSource(adapter).profile('ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.profilePath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(user.fullName, 'Imran Alsalame');
    expect(user.address, 'Damascus');
    expect(user.avatar, 'https://dalildimashq.com/storage/avatars/12.jpg');
  });

  test('a reply without an account is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'Done'});

    await expectLater(
      _dataSource(adapter).profile('en'),
      throwsA(isA<ParseException>()),
    );
  });

  test('saves the three fields the edit endpoint takes', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _account});

    await _dataSource(adapter).update(
      edit: const ProfileEdit(
        fullName: 'Imran Alsalame',
        gender: AuthGender.male,
        address: 'Shalash Street',
      ),
      locale: 'ar',
    );

    expect(adapter.captured?.method, 'PUT');
    expect(adapter.captured?.path, ApiConstants.profilePath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(_sent(adapter), {
      'full_name': 'Imran Alsalame',
      'address': 'Shalash Street',
      'gender': 'male',
    });
  });

  test('leaves the gender out when the account never chose one', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _account});

    await _dataSource(adapter).update(
      edit: const ProfileEdit(fullName: 'Imran Alsalame', address: null),
      locale: 'en',
    );

    expect(_sent(adapter), {'full_name': 'Imran Alsalame', 'address': null});
  });

  test('uploads the picked picture as a multipart file', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'Avatar updated successfully',
        'data': {
          'avatar': 'http://127.0.0.1/storage/avatars/99.jpg',
          'avatar_path': 'storage/avatars/99.jpg',
        },
      },
    );

    final avatar = await _dataSource(adapter).uploadAvatar(
      file: AvatarFile(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'me.jpg',
      ),
      locale: 'ar',
    );

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.profileAvatarPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    final form = adapter.captured?.data as FormData;
    expect(form.files.single.key, 'avatar');
    expect(form.files.single.value.filename, 'me.jpg');
    expect(avatar, 'http://127.0.0.1/storage/avatars/99.jpg');
  });

  test('an upload answer without an address is a parsing failure', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'Avatar updated successfully',
        'data': <String, dynamic>{},
      },
    );

    await expectLater(
      _dataSource(adapter).uploadAvatar(
        file: AvatarFile(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'me.jpg',
        ),
        locale: 'en',
      ),
      throwsA(isA<ParseException>()),
    );
  });

  test('removes the picture', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Avatar deleted successfully', 'data': null},
    );

    await _dataSource(adapter).removeAvatar();

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.profileAvatarPath);
  });

  test('a picture that was never there counts as removed', () async {
    final adapter = _StubAdapter(
      status: 404,
      payload: {
        'message': 'No avatar to delete',
        'errors': <String, dynamic>{},
      },
    );

    await expectLater(_dataSource(adapter).removeAvatar(), completes);
  });

  test('a server refusal to remove the picture is shown', () async {
    final adapter = _StubAdapter(status: 500, payload: {'message': 'Boom'});

    await expectLater(
      _dataSource(adapter).removeAvatar(),
      throwsA(
        isA<ServerException>().having((e) => e.message, 'message', 'Boom'),
      ),
    );
  });

  test('changes the password with the keys the endpoint names', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message':
            'Password changed successfully. Logged out from other devices.',
      },
    );

    await _dataSource(adapter).changePassword(
      const PasswordChange(
        currentPassword: 'secret1',
        password: 'secret2',
        confirmation: 'secret2',
      ),
    );

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.profilePasswordPath);
    expect(_sent(adapter), {
      'current_password': 'secret1',
      'password': 'secret2',
      'password_confirmation': 'secret2',
    });
  });

  test('a wrong current password keeps the backend sentence', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {'message': 'Current password is incorrect'},
    );

    await expectLater(
      _dataSource(adapter).changePassword(
        const PasswordChange(
          currentPassword: 'nope',
          password: 'secret2',
          confirmation: 'secret2',
        ),
      ),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Current password is incorrect',
        ),
      ),
    );
  });

  test('a mismatch is read from the field the reply names', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The password confirmation does not match.',
        'errors': {
          'password': ['Password confirmation does not match'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).changePassword(
        const PasswordChange(
          currentPassword: 'secret1',
          password: 'secret2',
          confirmation: 'secret3',
        ),
      ),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Password confirmation does not match',
        ),
      ),
    );
  });

  test('deletes the account with the password in the body', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Account deleted successfully', 'data': null},
    );

    await _dataSource(adapter).deleteAccount('12345678');

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.profileAccountPath);
    expect(_sent(adapter), {'password': '12345678'});
  });

  test('a vendor still holding services is refused in its own words', () async {
    final adapter = _StubAdapter(
      status: 409,
      payload: {
        'message':
            'Cannot delete vendor account with services. Contact admin first.',
      },
    );

    await expectLater(
      _dataSource(adapter).deleteAccount('12345678'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Cannot delete vendor account with services. Contact admin first.',
        ),
      ),
    );
  });
}
