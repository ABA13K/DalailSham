import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/vendor/domain/entities/contact_group.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact_edit.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_contact_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/cubit/vendor_contacts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorContactRepository extends Mock
    implements VendorContactRepository {}

const _phones = ContactGroup(
  type: 'phone',
  typeLabel: 'هاتف',
  contacts: [
    VendorContact(id: 2, type: 'phone', value: '0999111222', isPrimary: true),
    VendorContact(id: 3, type: 'phone', value: '0999111333'),
  ],
);

/// The same lines with the second one made primary.
const _phonesReordered = ContactGroup(
  type: 'phone',
  typeLabel: 'هاتف',
  contacts: [
    VendorContact(id: 2, type: 'phone', value: '0999111222'),
    VendorContact(id: 3, type: 'phone', value: '0999111333', isPrimary: true),
  ],
);

const _edit = VendorContactEdit(type: 'whatsapp', value: '+9630933314349');

const _added = VendorContact(
  id: 11,
  type: 'whatsapp',
  typeLabel: 'واتساب',
  value: '+9630933314349',
);

void main() {
  late _MockVendorContactRepository repository;
  late VendorContactsCubit cubit;

  setUpAll(() => registerFallbackValue(_edit));

  setUp(() {
    repository = _MockVendorContactRepository();
    cubit = VendorContactsCubit(repository);

    when(
      () => repository.contacts(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const Success([_phones]));
  });

  tearDown(() async => cubit.close());

  test('the lines the endpoint groups are what the page shows', () async {
    await cubit.load('ar');

    expect(cubit.state.status, VendorContactsStatus.ready);
    expect(cubit.state.groups, const [_phones]);
    verify(() => repository.contacts(locale: 'ar')).called(1);
  });

  test('a read that will not arrive says so and offers a retry', () async {
    when(
      () => repository.contacts(locale: any(named: 'locale')),
    ).thenAnswer((_) async => const FailureResult(NetworkFailure()));

    await cubit.load('ar');

    expect(cubit.state.status, VendorContactsStatus.failure);
    expect(cubit.state.groups, isEmpty);
  });

  test('an added line is followed by the groups the server kept', () async {
    await cubit.load('ar');
    when(
      () => repository.add(edit: _edit, locale: 'ar'),
    ).thenAnswer((_) async => const Success(_added));

    expect(await cubit.add(_edit), isNull);
    expect(cubit.state.isSaving, isFalse);
    verify(() => repository.contacts(locale: 'ar')).called(2);
  });

  test('a refused add answers with the sentence the backend wrote', () async {
    await cubit.load('ar');
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async =>
          const FailureResult(ServerFailure('The selected type is invalid.')),
    );

    expect(await cubit.add(_edit), 'The selected type is invalid.');
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.groups, const [_phones]);
    verify(() => repository.contacts(locale: 'ar')).called(1);
  });

  test(
    'an edit writes to the line it names, in the language it loaded',
    () async {
      await cubit.load('ar');
      when(
        () => repository.update(id: 6, edit: _edit, locale: 'ar'),
      ).thenAnswer((_) async => const Success(_added));

      expect(await cubit.update(id: 6, edit: _edit), isNull);
      verify(
        () => repository.update(id: 6, edit: _edit, locale: 'ar'),
      ).called(1);
    },
  );

  test('a deleted line leaves the page reading what is left', () async {
    await cubit.load('ar');
    when(
      () => repository.remove(id: 3, locale: 'ar'),
    ).thenAnswer((_) async => const Success<void>(null));

    expect(await cubit.remove(id: 3), isNull);
    verify(() => repository.contacts(locale: 'ar')).called(2);
  });

  test('the primary flag is the one the server answers with', () async {
    await cubit.load('ar');
    when(
      () => repository.setPrimary(id: 3, locale: 'ar'),
    ).thenAnswer((_) async => const Success(_added));
    when(
      () => repository.contacts(locale: 'ar'),
    ).thenAnswer((_) async => const Success([_phonesReordered]));

    expect(await cubit.setPrimary(id: 3), isNull);
    expect(cubit.state.groups.single.primary?.id, 3);
    expect(cubit.state.groups.single.hasPrimary, isTrue);
  });

  test(
    'a page that only writes still asks in the language it was given',
    () async {
      final form = VendorContactsCubit(repository, locale: 'ar');
      when(
        () => repository.add(edit: _edit, locale: 'ar'),
      ).thenAnswer((_) async => const Success(_added));

      expect(await form.add(_edit), isNull);
      verify(() => repository.add(edit: _edit, locale: 'ar')).called(1);
      await form.close();
    },
  );
}
