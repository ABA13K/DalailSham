import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_gallery.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_amenity_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/cubit/vendor_amenities_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorAmenityRepository extends Mock
    implements VendorAmenityRepository {}

const _wifi = VendorAmenity(
  id: 1,
  nameAr: 'واي فاي',
  nameEn: 'Wi-Fi',
  isApproved: true,
  status: 'approved',
);

const _hall = VendorAmenity(
  id: 2,
  nameAr: 'قاعة اجتماعات',
  nameEn: 'Conference Rooms',
  isApproved: false,
  status: 'pending',
);

const _two = VendorAmenityGallery(
  amenities: [_wifi, _hall],
  maxAllowed: 20,
  canAdd: true,
);

/// The same set with the last place taken, as the endpoint answers after the
/// write that filled it.
const _full = VendorAmenityGallery(
  amenities: [_wifi, _hall],
  maxAllowed: 2,
  canAdd: false,
);

const _empty = VendorAmenityGallery(
  amenities: [],
  maxAllowed: 20,
  canAdd: true,
);

const _edit = VendorAmenityEdit(
  nameAr: 'قاعة اجتماعات',
  nameEn: 'Conference Rooms',
);

void main() {
  late _MockVendorAmenityRepository repository;
  late VendorAmenitiesCubit cubit;

  setUpAll(() => registerFallbackValue(_edit));

  setUp(() {
    repository = _MockVendorAmenityRepository();
    cubit = VendorAmenitiesCubit(repository);

    when(
      () => repository.gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_two));
    when(
      () => repository.remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.clear(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(2));
  });

  tearDown(() async => cubit.close());

  test(
    'the amenities, the limit and the room left come from the read',
    () async {
      await cubit.load('ar');

      expect(cubit.state.status, VendorAmenitiesStatus.ready);
      expect(cubit.state.gallery.amenities, const [_wifi, _hall]);
      expect(cubit.state.gallery.maxAllowed, 20);
      expect(cubit.state.gallery.canAdd, isTrue);
      verify(() => repository.gallery(locale: 'ar')).called(1);
    },
  );

  test('a gallery that will not load leaves the page a retry', () async {
    when(
      () => repository.gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await cubit.load('en');

    expect(cubit.state.status, VendorAmenitiesStatus.failure);
    expect(cubit.state.gallery.amenities, isEmpty);
  });

  test('adding sends the two names and reads the limit back', () async {
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_hall));
    when(
      () => repository.gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_full));

    expect(await cubit.add(_edit), isNull);
    // The write reply names one amenity; only the read says the set is full.
    expect(cubit.state.gallery.canAdd, isFalse);
    verify(() => repository.add(edit: _edit, locale: 'en')).called(1);
    verify(() => repository.gallery(locale: 'en')).called(1);
  });

  test('editing writes under the id the row carries', () async {
    when(
      () => repository.update(
        id: any(named: 'id'),
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_hall));

    expect(await cubit.update(id: 2, edit: _edit), isNull);
    verify(() => repository.update(id: 2, edit: _edit, locale: 'en')).called(1);
  });

  test('removing one amenity re-reads the set', () async {
    await cubit.load('en');

    expect(await cubit.remove(id: 2), isNull);
    verify(() => repository.remove(id: 2, locale: 'en')).called(1);
    verify(() => repository.gallery(locale: 'en')).called(2);
  });

  test('clearing hands the empty set back to the page', () async {
    await cubit.load('en');
    when(
      () => repository.gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_empty));

    expect(await cubit.clear(), isNull);
    expect(cubit.state.gallery.amenities, isEmpty);
    verify(() => repository.clear(locale: 'en')).called(1);
  });

  test('a write uses the language the page loaded in', () async {
    await cubit.load('ar');
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_hall));

    await cubit.add(_edit);

    verify(() => repository.add(edit: _edit, locale: 'ar')).called(1);
  });

  test('a refused write shows the sentence the backend wrote', () async {
    await cubit.load('en');
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('This amenity already exists')),
    );

    expect(await cubit.add(_edit), 'This amenity already exists');
    // The amenities that were on screen stay there until the server says else.
    expect(cubit.state.gallery.amenities, const [_wifi, _hall]);
    expect(cubit.state.isBusy, isFalse);
    // Only the load read the gallery; the refused write read nothing.
    verify(() => repository.gallery(locale: 'en')).called(1);
  });

  test(
    'a write in flight keeps the page busy until the server answers',
    () async {
      await cubit.load('en');
      final held = Completer<Result<VendorAmenity>>();
      when(
        () => repository.add(
          edit: any(named: 'edit'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer((_) => held.future);

      final first = cubit.add(_edit);
      await Future<void>(() {});

      expect(cubit.state.isBusy, isTrue);

      held.complete(const Success(_hall));
      expect(await first, isNull);
      expect(cubit.state.isBusy, isFalse);
    },
  );
}
