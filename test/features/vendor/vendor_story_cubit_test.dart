import 'dart:async';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story_edit.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_story_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/cubit/vendor_story_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorStoryRepository extends Mock
    implements VendorStoryRepository {}

const _story = VendorStory(
  id: 12,
  type: VendorStoryType.image,
  caption: 'قهوة',
  status: 'pending',
);

const _edit = VendorStoryEdit(type: VendorStoryType.image, captionAr: 'قهوة');

final _photo = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'story.jpg',
);

void main() {
  late _MockVendorStoryRepository repository;
  late VendorStoryCubit cubit;

  setUpAll(() => registerFallbackValue(_edit));

  setUp(() {
    repository = _MockVendorStoryRepository();
    cubit = VendorStoryCubit(repository);

    when(
      () => repository.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_story));
  });

  tearDown(() async => cubit.close());

  test('a stored story answers with nothing to show', () async {
    final message = await cubit.post(edit: _edit, locale: 'ar');

    expect(message, isNull);
    expect(cubit.state.isBusy, isFalse);
    verify(() => repository.add(edit: _edit, file: null, locale: 'ar')).called(
      1,
    );
  });

  test('the picture the vendor picked rides with the post', () async {
    await cubit.post(edit: _edit, file: _photo, locale: 'ar');

    verify(
      () => repository.add(edit: _edit, file: _photo, locale: 'ar'),
    ).called(1);
  });

  test('a refusal is handed back in the words the endpoint used', () async {
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => const FailureResult(ServerFailure('The image is required.')),
    );

    final message = await cubit.post(edit: _edit, locale: 'en');

    expect(message, 'The image is required.');
    expect(cubit.state.isBusy, isFalse);
  });

  test('the post keeps the button disabled until the answer lands', () async {
    final gate = Completer<Result<VendorStory>>();
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        file: any(named: 'file'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) => gate.future);

    final posted = cubit.post(edit: _edit, locale: 'en');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isBusy, isTrue);

    gate.complete(const Success(_story));
    expect(await posted, isNull);
    expect(cubit.state.isBusy, isFalse);
  });

  test(
    'a reply that lands after the form is gone changes nothing',
    () async {
      final gate = Completer<void>();
      when(
        () => repository.add(
          edit: any(named: 'edit'),
          file: any(named: 'file'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer((_) async {
        await gate.future;
        return const Success(_story);
      });

      final posted = cubit.post(edit: _edit, locale: 'en');
      await Future<void>(() => null);
      await cubit.close();
      gate.complete();

      expect(await posted, isNull);
    },
  );
}
