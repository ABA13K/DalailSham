import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_service.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_service_edit.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/cubit/vendor_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorRepository extends Mock implements VendorRepository {}

const _service = VendorService(
  id: 1,
  nameAr: 'الاسد',
  nameEn: 'amran',
  isMain: true,
  regionName: 'المزة',
  categoryName: 'مطاعم',
  addressAr: 'دمشق',
  lat: 33,
  mainImage: 'https://dalildimashq.com/storage/join_requests/images/a.png',
  subscriptionType: 'free',
);

/// The same service after the vendor renamed it — what the page shows back.
const _renamed = VendorService(
  id: 1,
  nameAr: 'الأسد',
  nameEn: 'Asad',
  isMain: true,
  regionName: 'المزة',
  categoryName: 'مطاعم',
  addressAr: 'دمشق',
  lat: 33,
  mainImage: 'https://dalildimashq.com/storage/join_requests/images/a.png',
  subscriptionType: 'free',
);

const _edit = VendorServiceEdit(
  nameAr: 'الأسد',
  nameEn: 'Asad',
  addressAr: 'دمشق',
  lat: 33,
);

const _withoutPicture = VendorService(
  id: 1,
  nameAr: 'الاسد',
  nameEn: 'amran',
  regionName: 'المزة',
  categoryName: 'مطاعم',
  addressAr: 'دمشق',
  lat: 33,
);

const _change = PasswordChange(
  currentPassword: 'oldpass123',
  password: 'newpass456',
  confirmation: 'newpass456',
);

void main() {
  late _MockVendorRepository repository;
  late VendorCubit cubit;

  setUpAll(() {
    registerFallbackValue(_edit);
    registerFallbackValue(_change);
  });

  setUp(() {
    repository = _MockVendorRepository();
    cubit = VendorCubit(repository);
    when(
      () => repository.load(any()),
    ).thenAnswer((_) async => const Success(_service));
  });

  tearDown(() async => cubit.close());

  test('opening the page reads the vendor service', () async {
    await cubit.load('ar');

    expect(cubit.state.status, VendorStatus.ready);
    expect(cubit.state.service, _service);
    verify(() => repository.load('ar')).called(1);
  });

  test('a read that failed offers the retry the page shows', () async {
    when(
      () => repository.load(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure('Nope')));

    await cubit.load('en');

    expect(cubit.state.status, VendorStatus.failure);
    expect(cubit.state.service, isNull);
  });

  test('a saved edit re-reads the record the reply only halves', () async {
    when(
      () => repository.update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));
    var reads = 0;
    when(() => repository.load('ar')).thenAnswer((_) async {
      reads++;
      return Success(reads == 1 ? _service : _renamed);
    });

    await cubit.load('ar');
    expect(await cubit.save(_edit), isNull);

    expect(cubit.state.service, _renamed);
    expect(cubit.state.isSaving, isFalse);
    verify(() => repository.load('ar')).called(2);
  });

  test(
    'a rejected edit keeps the service on screen and answers verbatim',
    () async {
      await cubit.load('ar');
      when(
        () => repository.update(
          edit: any(named: 'edit'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer(
        (_) async => const FailureResult(
          ServerFailure('The name ar field is required.'),
        ),
      );

      final message = await cubit.save(
        const VendorServiceEdit(nameAr: '', nameEn: 'amran'),
      );

      expect(message, 'The name ar field is required.');
      expect(cubit.state.service, _service);
      expect(cubit.state.isSaving, isFalse);
      verify(() => repository.load('ar')).called(1);
    },
  );

  test('saving shows the form is busy until the answer arrives', () async {
    final pending = Completer<Result<void>>();
    when(
      () => repository.update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) => pending.future);
    await cubit.load('ar');

    final saved = cubit.save(_edit);
    await pumpEventQueue();
    expect(cubit.state.isBusy, isTrue);

    pending.complete(const Success<void>(null));
    expect(await saved, isNull);
    await pumpEventQueue();

    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.isEditingImage, isFalse);
  });

  test('removing the picture re-reads the service, not the reply', () async {
    when(
      () => repository.removeMainImage(),
    ).thenAnswer((_) async => const Success<void>(null));
    var reads = 0;
    when(() => repository.load('ar')).thenAnswer((_) async {
      reads++;
      return Success(reads == 1 ? _service : _withoutPicture);
    });

    await cubit.load('ar');
    expect(cubit.state.service?.mainImage, isNotNull);

    expect(await cubit.removeMainImage(), isNull);
    expect(cubit.state.service, _withoutPicture);
    expect(cubit.state.isEditingImage, isFalse);
    verify(() => repository.load('ar')).called(2);
  });

  test('a refused removal reports it and leaves the picture alone', () async {
    await cubit.load('ar');
    when(() => repository.removeMainImage()).thenAnswer(
      (_) async => const FailureResult(ServerFailure('No image to delete')),
    );

    expect(await cubit.removeMainImage(), 'No image to delete');
    expect(cubit.state.service, _service);
    expect(cubit.state.isEditingImage, isFalse);
  });

  test('a password change answers with the backend sentence', () async {
    when(
      () => repository.changePassword(_change),
    ).thenAnswer((_) async => const Success<void>(null));
    expect(await cubit.changePassword(_change), isNull);

    when(() => repository.changePassword(any())).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('كلمة المرور الحالية غير صحيحة')),
    );
    expect(
      await cubit.changePassword(_change),
      'كلمة المرور الحالية غير صحيحة',
    );
  });

  test('a write that answers after the page is gone stays quiet', () async {
    final pending = Completer<Result<void>>();
    when(
      () => repository.update(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) => pending.future);
    await cubit.load('ar');

    final saved = cubit.save(_edit);
    await cubit.close();
    pending.complete(const Success<void>(null));

    expect(await saved, isNull);
  });
}
