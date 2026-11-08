import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/stories/domain/entities/story.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:dali_alsham/features/stories/domain/usecases/get_story_feed.dart';
import 'package:dali_alsham/features/stories/presentation/cubit/story_feed_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetStoryFeed extends Mock implements GetStoryFeed {}

const _photo = Story(
  id: 2,
  type: StoryType.image,
  caption: 'عرض جديد اليوم',
  service: StoryService(id: 1, name: 'الاسد'),
);

StoryFeed _feedOf(List<Story> stories) =>
    StoryFeed(stories: stories, hasMore: false);

void main() {
  late _MockGetStoryFeed getStoryFeed;
  late StoryFeedCubit cubit;

  setUpAll(() => registerFallbackValue(const StoryFeedParams(locale: 'en')));

  setUp(() {
    getStoryFeed = _MockGetStoryFeed();
    cubit = StoryFeedCubit(getStoryFeed);
  });

  tearDown(() => cubit.close());

  test('the strip is read in the language the app is showing', () async {
    when(
      () => getStoryFeed.call(any()),
    ).thenAnswer((_) async => Success(_feedOf(const [_photo])));

    await cubit.load('ar');

    final params = verify(
      () => getStoryFeed.call(captureAny()),
    ).captured.single as StoryFeedParams;
    expect(params.locale, 'ar');
    expect(params.page, 1);
    expect(params.perPage, 20);
    expect(cubit.state.status, StoryFeedStatus.ready);
    expect(cubit.state.stories, [_photo]);
  });

  test('an empty listing is ready with nothing in it', () async {
    when(
      () => getStoryFeed.call(any()),
    ).thenAnswer((_) async => Success(_feedOf(const [])));

    await cubit.load('en');

    expect(cubit.state.status, StoryFeedStatus.ready);
    expect(cubit.state.stories, isEmpty);
  });

  test('a failed listing is kept so the strip can stand aside', () async {
    when(
      () => getStoryFeed.call(any()),
    ).thenAnswer((_) async => const FailureResult(NetworkFailure()));

    await cubit.load('en');

    expect(cubit.state.status, StoryFeedStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('reading the same page again does not blank the strip', () async {
    final states = <StoryFeedStatus>[];
    cubit.stream.listen((state) => states.add(state.status));
    when(
      () => getStoryFeed.call(any()),
    ).thenAnswer((_) async => Success(_feedOf(const [_photo])));

    await cubit.load('en');
    await cubit.load('en');
    await pumpEventQueue();

    expect(states, [StoryFeedStatus.loading, StoryFeedStatus.ready]);
  });

  test('another language refetches instead of reusing the old labels', () async {
    when(
      () => getStoryFeed.call(any()),
    ).thenAnswer((_) async => Success(_feedOf(const [_photo])));
    await cubit.load('en');

    final states = <StoryFeedStatus>[];
    cubit.stream.listen((state) => states.add(state.status));
    when(
      () => getStoryFeed.call(any()),
    ).thenAnswer((_) async => Success(_feedOf(const [])));
    await cubit.load('ar');
    await pumpEventQueue();

    expect(states, [StoryFeedStatus.loading, StoryFeedStatus.ready]);
    expect(cubit.state.stories, isEmpty);
  });

  test('an older reply that arrives last is dropped', () async {
    final stale = Completer<Result<StoryFeed>>();
    var calls = 0;
    when(() => getStoryFeed.call(any())).thenAnswer((_) {
      calls++;
      return calls == 1
          ? stale.future
          : Future.value(Success(_feedOf(const [])));
    });

    final pending = cubit.load('en');
    await cubit.load('ar');

    stale.complete(Success(_feedOf(const [_photo])));
    await pending;

    expect(cubit.state.stories, isEmpty);
  });
}
