import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/data/models/vendor_service_model.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_repository_impl.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_service_edit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorRemoteDataSource extends Mock
    implements VendorRemoteDataSource {}

const _edit = VendorServiceEdit(nameAr: 'الأسد', nameEn: 'Asad');

const _change = PasswordChange(
  currentPassword: 'oldpass123',
  password: 'newpass456',
  confirmation: 'newpass456',
);

final _model = VendorServiceModel.fromJson(const <String, dynamic>{
  'id': 1,
  'name_ar': 'الاسد',
  'name_en': 'amran',
  'is_main': true,
  'region': {'id': 1, 'name': 'المزة'},
  'category': {'id': 1, 'name': 'مطاعم'},
  'main_image': 'http://127.0.0.1:8000/storage/join_requests/images/a.png',
});

void main() {
  late _MockVendorRemoteDataSource remote;
  late VendorRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_edit));

  setUp(() {
    remote = _MockVendorRemoteDataSource();
    repository = VendorRepositoryImpl(remote);
  });

  test('a read passes the service through', () async {
    when(() => remote.service('ar')).thenAnswer((_) async => _model);

    final result = await repository.load('ar');

    expect((result as Success).value, _model);
    verify(() => remote.service('ar')).called(1);
  });

  test('the cover picture is rewritten off the local dev host', () async {
    when(() => remote.service('ar')).thenAnswer((_) async => _model);

    final result = await repository.load('ar');

    expect(
      (result as Success).value.mainImage,
      normalizeRemoteImageUrl(
        'http://127.0.0.1:8000/storage/join_requests/images/a.png',
      ),
    );
  });

  test('a successful edit answers with nothing to show', () async {
    when(
      () => remote.update(edit: _edit, locale: 'ar'),
    ).thenAnswer((_) async => Future<void>.value());

    final result = await repository.update(edit: _edit, locale: 'ar');

    expect(result, isA<Success<void>>());
  });

  test('a refusal is turned into the failure the page shows', () async {
    when(
      () => remote.update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const ServerException('The name ar field is required.'));

    final result = await repository.update(edit: _edit, locale: 'ar');

    expect(
      (result as FailureResult).failure,
      const ServerFailure('The name ar field is required.'),
    );
  });

  test('a dropped connection is a network failure', () async {
    when(() => remote.service('ar')).thenThrow(const NetworkException());

    final result = await repository.load('ar');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('a malformed reply is a parsing failure', () async {
    when(() => remote.service('ar')).thenThrow(
      const ParseException('Vendor service reply carried no service'),
    );

    final result = await repository.load('ar');

    expect((result as FailureResult).failure, isA<ParsingFailure>());
  });

  test('a timeout is a timeout failure', () async {
    when(() => remote.removeMainImage()).thenThrow(const TimeoutException());

    final result = await repository.removeMainImage();

    expect((result as FailureResult).failure, isA<TimeoutFailure>());
  });

  test('an image removal that worked answers with nothing to show', () async {
    when(() => remote.removeMainImage()).thenAnswer((_) async {});

    expect(await repository.removeMainImage(), isA<Success<void>>());
  });

  test('a password change reports the backend sentence', () async {
    when(
      () => remote.changePassword(_change),
    ).thenThrow(const ServerException('كلمة المرور الحالية غير صحيحة'));

    final result = await repository.changePassword(_change);

    expect(
      (result as FailureResult).failure.message,
      'كلمة المرور الحالية غير صحيحة',
    );
  });

  test('a password change that worked answers with nothing', () async {
    when(() => remote.changePassword(_change)).thenAnswer((_) async {});

    expect(await repository.changePassword(_change), isA<Success<void>>());
  });
}
