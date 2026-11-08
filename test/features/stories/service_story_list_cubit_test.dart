import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/stories/domain/entities/story.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:dali_alsham/features/stories/domain/usecases/get_service_story_feed.dart';
import 'package:dali_alsham/features/stories/presentation/cubit/service_story_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetServiceStoryFeed extends Mock
    implements GetServiceStoryFeed {}

Story _posted(int id) => Story(
  id: id,
  type: StoryType.image,
  caption: 'عرض جديد اليوم',
  service: const StoryService(id: 1, name: 'الاسد'),
);

void main() {
  late _MockGetServiceStoryFeed getServiceStoryFeed;
  late ServiceStoryListCubit cubit;

  setUpAll(
    () => registerFallbackValue(
      const ServiceStoryFeedParams(serviceId: 1, locale: 'en'),
    ),
  );

  setUp(() {
    getServiceStoryFeed = _MockGetServiceStoryFeed();
    cubit = ServiceStoryListCubit(getServiceStoryFeed);
  });

  tearDown(() => cubit.close());

  void answer(StoryFeed feed) => when(
    () => getServiceStoryFeed.call(any()),
  ).thenAnswer((_) async => Success(feed));

  test('the archive is asked for by service, language and page', () async {
    answer(
      StoryFeed(
        stories: [_posted(6), _posted(5)],
        hasMore: true,
        nextPage: 2,
      ),
    );

    await cubit.load(serviceId: 1, locale: 'ar');

    final params = verify(
      () => getServiceStoryFeed.call(captureAny()),
    ).captured.single as ServiceStoryFeedParams;
    expect(params.serviceId, 1);
    expect(params.locale, 'ar');
    expect(params.page, 1);
    expect(params.perPage, 20);

    expect(cubit.state.status, ServiceStoryListStatus.ready);
    expect(cubit.state.stories.map((story) => story.id), [6, 5]);
    expect(cubit.state.hasMore, isTrue);
  });

  test('the page that follows is added under the first', () async {
    answer(
      StoryFeed(
        stories: [_posted(6)],
        hasMore: true,
        nextPage: 2,
      ),
    );
    await cubit.load(serviceId: 1, locale: 'ar');

    answer(
      StoryFeed(
        stories: [_posted(3)],
        hasMore: false,
      ),
    );
    await cubit.loadMore();

    expect(cubit.state.stories.map((story) => story.id), [6, 3]);
    // Nothing further was offered, so no third page is asked for.
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.isLoadingMore, isFalse);

    await cubit.loadMore();
    verify(() => getServiceStoryFeed.call(any())).called(2);
  });

  test('a service with nothing posted is a ready, empty archive', () async {
    answer(StoryFeed(stories: [], hasMore: false));

    await cubit.load(serviceId: 7, locale: 'en');

    expect(cubit.state.status, ServiceStoryListStatus.ready);
    expect(cubit.state.stories, isEmpty);
  });

  test('a failed archive is kept so the page can offer a retry', () async {
    when(
      () => getServiceStoryFeed.call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure('HTTP 500')));

    await cubit.load(serviceId: 1, locale: 'ar');

    expect(cubit.state.status, ServiceStoryListStatus.failure);
    expect(cubit.state.failure?.message, 'HTTP 500');
  });

  test('a page that arrives after the reader moved on is dropped', () async {
    final stale = Completer<Result<StoryFeed>>();
    var calls = 0;
    when(() => getServiceStoryFeed.call(any())).thenAnswer((_) {
      calls++;
      return calls == 1
          ? stale.future
          : Future.value(
              Success(StoryFeed(stories: [_posted(20)], hasMore: false)),
            );
    });

    final pending = cubit.load(serviceId: 1, locale: 'ar');
    await cubit.load(serviceId: 2, locale: 'ar');

    stale.complete(Success(StoryFeed(stories: [_posted(6)], hasMore: false)));
    await pending;

    expect(cubit.state.stories.map((story) => story.id), [20]);
  });

  test('a late second page that fails leaves the list on screen', () async {
    answer(
      StoryFeed(
        stories: [_posted(6)],
        hasMore: true,
        nextPage: 2,
      ),
    );
    await cubit.load(serviceId: 1, locale: 'ar');

    when(
      () => getServiceStoryFeed.call(any()),
    ).thenAnswer((_) async => const FailureResult(NetworkFailure()));
    await cubit.loadMore();

    expect(cubit.state.status, ServiceStoryListStatus.ready);
    expect(cubit.state.stories.map((story) => story.id), [6]);
    expect(cubit.state.isLoadingMore, isFalse);
  });
}
