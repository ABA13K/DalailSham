import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_image_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_image_repository_impl.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_image.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_image_gallery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorImageRemoteDataSource extends Mock
    implements VendorImageRemoteDataSource {}

const _image = VendorImage(
  id: 1,
  url: 'https://dalildimashq.com/storage/app/public/services/images/a.png',
  isApproved: false,
  sortOrder: 1,
);

const _gallery = VendorImageGallery(
  images: [_image],
  maxAllowed: 20,
  canAdd: true,
);

final _file = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'shop.png',
);

void main() {
  late _MockVendorImageRemoteDataSource remote;
  late VendorImageRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_file));

  setUp(() {
    remote = _MockVendorImageRemoteDataSource();
    repository = VendorImageRepositoryImpl(remote);
  });

  test('the gallery the endpoint answers is passed through', () async {
    when(() => remote.gallery('ar')).thenAnswer((_) async => _gallery);

    final result = await repository.gallery(locale: 'ar');

    expect((result as Success).value, _gallery);
    verify(() => remote.gallery('ar')).called(1);
  });

  test('an added picture is answered with what the server stored', () async {
    when(
      () => remote.add(
        file: any(named: 'file'),
        locale: 'ar',
      ),
    ).thenAnswer((_) async => _image);

    final result = await repository.add(file: _file, locale: 'ar');

    expect((result as Success).value.id, 1);
    verify(() => remote.add(file: _file, locale: 'ar')).called(1);
  });

  test('a deleted picture leaves nothing to show', () async {
    when(() => remote.remove(id: 7, locale: 'en')).thenAnswer((_) async {});

    final result = await repository.remove(id: 7, locale: 'en');

    expect((result as Success).value, isNull);
  });

  test('the clear answer keeps the count it removed', () async {
    when(() => remote.clear('en')).thenAnswer((_) async => 2);

    final result = await repository.clear(locale: 'en');

    expect((result as Success).value, 2);
  });

  test('a refusal becomes the failure the page shows', () async {
    when(
      () => remote.add(
        file: any(named: 'file'),
        locale: 'en',
      ),
    ).thenThrow(const ServerException('The image must be an image.'));

    final result = await repository.add(file: _file, locale: 'en');

    final failure = (result as FailureResult).failure;
    expect(failure.message, 'The image must be an image.');
    expect(failure, isA<ServerFailure>());
  });

  test('a gallery that will not load is a failure, not an empty set', () async {
    when(() => remote.gallery('en')).thenThrow(const NetworkException());

    final result = await repository.gallery(locale: 'en');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });
}
