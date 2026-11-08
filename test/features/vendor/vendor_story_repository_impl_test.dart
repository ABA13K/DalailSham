import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_story_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_story_repository_impl.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story_edit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorStoryRemoteDataSource extends Mock
    implements VendorStoryRemoteDataSource {}

const _edit = VendorStoryEdit(
  type: VendorStoryType.image,
  captionAr: 'قهوة',
);

final _photo = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'story.jpg',
);

const _story = VendorStory(
  id: 12,
  type: VendorStoryType.image,
  caption: 'قهوة',
  status: 'pending',
);

void main() {
  late _MockVendorStoryRemoteDataSource remote;
  late VendorStoryRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_edit);
    registerFallbackValue(_photo);
  });

  setUp(() {
    remote = _MockVendorStoryRemoteDataSource();
    repository = VendorStoryRepositoryImpl(remote);
  });

  test('the story the endpoint stored is passed through', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: 'ar',
      ),
    ).thenAnswer((_) async => _story);

    final result = await repository.add(
      edit: _edit,
      file: _photo,
      locale: 'ar',
    );

    expect((result as Success).value, _story);
    verify(
      () => remote.add(edit: _edit, file: _photo, locale: 'ar'),
    ).called(1);
  });

  test('a poll write carries no file at all', () async {
    const poll = VendorStoryEdit(type: VendorStoryType.poll);
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: 'en',
      ),
    ).thenAnswer((_) async => _story);

    await repository.add(edit: poll, locale: 'en');

    verify(() => remote.add(edit: poll, file: null, locale: 'en')).called(1);
  });

  test('a refusal becomes the failure the form shows', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: 'ar',
      ),
    ).thenThrow(const ServerException('The image field is required.'));

    final result = await repository.add(
      edit: _edit,
      file: _photo,
      locale: 'ar',
    );

    final failure = (result as FailureResult).failure;
    expect(failure.message, 'The image field is required.');
    expect(failure, isA<ServerFailure>());
  });

  test('a story that will not reach the server is a failure, not a save', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: 'en',
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.add(edit: _edit, locale: 'en');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('a reply the parser rejects is a failure too', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: 'en',
      ),
    ).thenThrow(const ParseException('Story reply carried no story'));

    final result = await repository.add(edit: _edit, locale: 'en');

    expect((result as FailureResult).failure, isA<ParsingFailure>());
  });
}
