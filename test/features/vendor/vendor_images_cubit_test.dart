import 'dart:typed_data';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/profile/domain/repositories/avatar_picker.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_image.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_image_gallery.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_image_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/cubit/vendor_images_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorImageRepository extends Mock
    implements VendorImageRepository {}

class _MockAvatarPicker extends Mock implements AvatarPicker {}

const _first = VendorImage(
  id: 1,
  url: 'https://dalildimashq.com/storage/app/public/services/images/a.png',
  isApproved: false,
  sortOrder: 1,
);

const _second = VendorImage(
  id: 2,
  url: 'https://dalildimashq.com/storage/app/public/services/images/b.png',
  isApproved: true,
  sortOrder: 2,
);

const _two = VendorImageGallery(
  images: [_first, _second],
  maxAllowed: 20,
  canAdd: true,
);

/// The same set with the last place taken, as the endpoint answers after the
/// upload that filled it.
const _full = VendorImageGallery(
  images: [_first, _second],
  maxAllowed: 2,
  canAdd: false,
);

const _empty = VendorImageGallery(images: [], maxAllowed: 20, canAdd: true);

final _file = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'shop.png',
);

void main() {
  late _MockVendorImageRepository repository;
  late _MockAvatarPicker picker;
  late VendorImagesCubit cubit;

  setUpAll(() => registerFallbackValue(_file));

  setUp(() {
    repository = _MockVendorImageRepository();
    picker = _MockAvatarPicker();
    cubit = VendorImagesCubit(repository, picker);

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
    'the pictures, the limit and the room left come from the read',
    () async {
      await cubit.load('ar');

      expect(cubit.state.status, VendorImagesStatus.ready);
      expect(cubit.state.gallery.images, const [_first, _second]);
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

    expect(cubit.state.status, VendorImagesStatus.failure);
    expect(cubit.state.gallery.images, isEmpty);
  });

  test('adding sends the chosen file and reads the limit back', () async {
    when(() => picker.pick()).thenAnswer((_) async => _file);
    when(
      () => repository.add(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_second));
    when(
      () => repository.gallery(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success(_full));

    expect(await cubit.add(), isNull);
    expect(cubit.state.gallery.canAdd, isFalse);
    verify(() => repository.add(file: _file, locale: 'en')).called(1);
    // The upload reply names one picture; only the read says the set is full.
    verify(() => repository.gallery(locale: 'en')).called(1);
  });

  test('backing out of the chooser sends nothing', () async {
    when(() => picker.pick()).thenAnswer((_) async => null);

    expect(await cubit.add(), isNull);
    verifyNever(
      () => repository.add(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    );
  });

  test('a write uses the language the page loaded in', () async {
    await cubit.load('ar');
    when(() => picker.pick()).thenAnswer((_) async => _file);
    when(
      () => repository.add(
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_second));

    await cubit.add();

    verify(() => repository.add(file: _file, locale: 'ar')).called(1);
  });

  test('removing one picture re-reads the set', () async {
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
    expect(cubit.state.gallery.images, isEmpty);
    verify(() => repository.clear(locale: 'en')).called(1);
  });

  test('a refused write shows the sentence the backend wrote', () async {
    await cubit.load('en');
    when(() => repository.clear(locale: any(named: 'locale'))).thenAnswer(
      (_) async => const FailureResult(
        ServerFailure('Only a vendor can change these pictures.'),
      ),
    );

    expect(await cubit.clear(), 'Only a vendor can change these pictures.');
    // The pictures that were on screen stay there until the server says else.
    expect(cubit.state.gallery.images, const [_first, _second]);
    expect(cubit.state.isBusy, isFalse);
  });
}
