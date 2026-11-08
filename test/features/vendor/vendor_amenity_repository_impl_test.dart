import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_amenity_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_amenity_repository_impl.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_gallery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorAmenityRemoteDataSource extends Mock
    implements VendorAmenityRemoteDataSource {}

const _pending = VendorAmenity(
  id: 2,
  nameAr: 'قاعة اجتماعات',
  nameEn: 'Conference Rooms',
  isApproved: false,
  status: 'pending',
);

const _gallery = VendorAmenityGallery(
  amenities: [_pending],
  maxAllowed: 20,
  canAdd: true,
);

const _edit = VendorAmenityEdit(
  nameAr: 'قاعة اجتماعات',
  nameEn: 'Conference Rooms',
);

void main() {
  late _MockVendorAmenityRemoteDataSource remote;
  late VendorAmenityRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_edit));

  setUp(() {
    remote = _MockVendorAmenityRemoteDataSource();
    repository = VendorAmenityRepositoryImpl(remote);
  });

  test('the gallery the endpoint answers is passed through', () async {
    when(() => remote.gallery('ar')).thenAnswer((_) async => _gallery);

    final result = await repository.gallery(locale: 'ar');

    expect((result as Success).value, _gallery);
    verify(() => remote.gallery('ar')).called(1);
  });

  test('an added amenity is answered with what the server stored', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        locale: 'ar',
      ),
    ).thenAnswer((_) async => _pending);

    final result = await repository.add(edit: _edit, locale: 'ar');

    expect((result as Success).value.id, 2);
    verify(() => remote.add(edit: _edit, locale: 'ar')).called(1);
  });

  test('an edited amenity keeps the id it was written under', () async {
    when(
      () => remote.update(
        id: any(named: 'id'),
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => _pending);

    final result = await repository.update(id: 2, edit: _edit, locale: 'en');

    expect((result as Success).value, _pending);
    verify(() => remote.update(id: 2, edit: _edit, locale: 'en')).called(1);
  });

  test('a deleted amenity leaves nothing to show', () async {
    when(() => remote.remove(id: 7, locale: 'en')).thenAnswer((_) async {});

    final result = await repository.remove(id: 7, locale: 'en');

    expect((result as Success).value, isNull);
  });

  test('the clear answer keeps the count it removed', () async {
    when(() => remote.clear('en')).thenAnswer((_) async => 4);

    final result = await repository.clear(locale: 'en');

    expect((result as Success).value, 4);
  });

  test(
    'an amenity that already exists reaches the page as its sentence',
    () async {
      when(
        () => remote.add(
          edit: any(named: 'edit'),
          locale: 'en',
        ),
      ).thenThrow(const ServerException('This amenity already exists'));

      final result = await repository.add(edit: _edit, locale: 'en');

      final failure = (result as FailureResult).failure;
      expect(failure.message, 'This amenity already exists');
      expect(failure, isA<ServerFailure>());
    },
  );

  test('a gallery that will not load is a failure, not an empty set', () async {
    when(() => remote.gallery('en')).thenThrow(const NetworkException());

    final result = await repository.gallery(locale: 'en');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('an error the data source did not wrap is still a failure', () async {
    when(() => remote.clear('en')).thenThrow(StateError('boom'));

    final result = await repository.clear(locale: 'en');

    expect((result as FailureResult).failure, isA<UnexpectedFailure>());
  });
}
