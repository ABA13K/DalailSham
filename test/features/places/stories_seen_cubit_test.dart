import 'package:dali_alsham/features/places/domain/repositories/stories_seen_repository.dart';
import 'package:dali_alsham/features/places/presentation/cubit/stories_seen_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStoriesSeenRepository extends Mock
    implements StoriesSeenRepository {}

void main() {
  late _MockStoriesSeenRepository repository;
  late StoriesSeenCubit cubit;

  setUpAll(() {
    registerFallbackValue(<String>{});
  });

  setUp(() {
    repository = _MockStoriesSeenRepository();
    cubit = StoriesSeenCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loads previously viewed story ids', () async {
    when(
      () => repository.getViewedIds(),
    ).thenAnswer((_) async => {'node/1', 'node/2'});

    await cubit.load();

    expect(cubit.state, {'node/1', 'node/2'});
  });

  test('marks a story viewed once and persists it', () async {
    when(() => repository.getViewedIds()).thenAnswer((_) async => <String>{});
    when(() => repository.saveViewedIds(any())).thenAnswer((_) async {});

    await cubit.load();
    await cubit.markViewed('node/1');
    await cubit.markViewed('node/1');

    expect(cubit.state, {'node/1'});
    verify(() => repository.saveViewedIds({'node/1'})).called(1);
  });
}
