import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_contact_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/domain/entities/contact_group.dart';
import 'package:dali_alsham/features/vendor/domain/entities/contact_type.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact_edit.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_contact_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorContactRemoteDataSource extends Mock
    implements VendorContactRemoteDataSource {}

const _edit = VendorContactEdit(type: 'whatsapp', value: '+9630933314349');

const _contact = VendorContact(
  id: 11,
  type: 'whatsapp',
  typeLabel: 'واتساب',
  value: '+9630933314349',
);

const _group = ContactGroup(
  type: 'phone',
  typeLabel: 'هاتف',
  contacts: [
    VendorContact(id: 2, type: 'phone', value: '0999111222', isPrimary: true),
  ],
);

void main() {
  late _MockVendorContactRemoteDataSource remote;
  late VendorContactRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_edit));

  setUp(() {
    remote = _MockVendorContactRemoteDataSource();
    repository = VendorContactRepositoryImpl(remote);
  });

  test('the types the endpoint offers are passed through', () async {
    when(() => remote.types('ar')).thenAnswer(
      (_) async => const [ContactType(value: 'phone', label: 'هاتف')],
    );

    final result = await repository.types(locale: 'ar');

    expect((result as Success).value.single.value, 'phone');
    verify(() => remote.types('ar')).called(1);
  });

  test('a read passes the groups through', () async {
    when(() => remote.contacts('ar')).thenAnswer((_) async => const [_group]);

    final result = await repository.contacts(locale: 'ar');

    expect((result as Success).value, const [_group]);
  });

  test('an added line is answered with what the server stored', () async {
    when(
      () => remote.add(edit: _edit, locale: 'ar'),
    ).thenAnswer((_) async => _contact);

    final result = await repository.add(edit: _edit, locale: 'ar');

    expect((result as Success).value.id, 11);
  });

  test('an edit names the line it changes', () async {
    when(
      () => remote.update(id: 6, edit: _edit, locale: 'ar'),
    ).thenAnswer((_) async => _contact);

    final result = await repository.update(id: 6, edit: _edit, locale: 'ar');

    expect((result as Success).value, _contact);
    verify(() => remote.update(id: 6, edit: _edit, locale: 'ar')).called(1);
  });

  test('a deletion that worked answers with nothing to show', () async {
    when(
      () => remote.remove(id: 1, locale: 'ar'),
    ).thenAnswer((_) async => Future<void>.value());

    expect(await repository.remove(id: 1, locale: 'ar'), isA<Success<void>>());
  });

  test('a primary line is answered with the flag it took', () async {
    when(() => remote.setPrimary(id: 2, locale: 'ar')).thenAnswer(
      (_) async => const VendorContact(
        id: 2,
        type: 'phone',
        value: '0999111222',
        isPrimary: true,
      ),
    );

    final result = await repository.setPrimary(id: 2, locale: 'ar');

    expect((result as Success).value.isPrimary, isTrue);
  });

  test('a refusal is turned into the failure the page shows', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const ServerException('The selected type is invalid.'));

    final result = await repository.add(edit: _edit, locale: 'ar');

    expect(
      (result as FailureResult).failure,
      const ServerFailure('The selected type is invalid.'),
    );
  });

  test('a dropped connection is a network failure', () async {
    when(() => remote.contacts('ar')).thenThrow(const NetworkException());

    final result = await repository.contacts(locale: 'ar');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('a malformed reply is a parsing failure', () async {
    when(
      () => remote.setPrimary(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(
      const ParseException('Contact reply carried no primary contact'),
    );

    final result = await repository.setPrimary(id: 2, locale: 'ar');

    expect((result as FailureResult).failure, isA<ParsingFailure>());
  });

  test('a timeout is a timeout failure', () async {
    when(
      () => remote.remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const TimeoutException());

    final result = await repository.remove(id: 1, locale: 'ar');

    expect((result as FailureResult).failure, isA<TimeoutFailure>());
  });
}
