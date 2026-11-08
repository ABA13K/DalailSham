import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/stories/data/datasources/story_remote_datasource.dart';
import 'package:dali_alsham/features/stories/data/repositories/story_repository_impl.dart';
import 'package:dali_alsham/features/stories/domain/entities/story.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStoryRemoteDataSource extends Mock
    implements StoryRemoteDataSource {}

const _photo = Story(
  id: 2,
  type: StoryType.image,
  caption: 'عرض جديد اليوم',
  imageUrl: 'https://dalildimashq.com/storage/stories/2.png',
);

const _feed = StoryFeed(stories: [_photo], hasMore: false);

void main() {
  late _MockStoryRemoteDataSource remote;
  late StoryRepositoryImpl repository;

  setUp(() {
    remote = _MockStoryRemoteDataSource();
    repository = StoryRepositoryImpl(remote);
    when(
      () => remote.fetchStories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => _feed);
    when(
      () => remote.fetchServiceStories(
        serviceId: any(named: 'serviceId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => _feed);
  });

  test('the page the endpoint answered is passed through', () async {
    final result = await repository.getFeed(locale: 'ar', page: 1, perPage: 20);

    expect((result as Success).value, _feed);
    verify(
      () => remote.fetchStories(locale: 'ar', page: 1, perPage: 20),
    ).called(1);
  });

  test('a listing that will not arrive is a network failure', () async {
    when(
      () => remote.fetchStories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.getFeed(locale: 'en', page: 1, perPage: 20);

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('a reply the parser rejects is a failure, not an empty strip', () async {
    when(
      () => remote.fetchStories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const ParseException('Missing stories in response'));

    final result = await repository.getFeed(locale: 'en', page: 1, perPage: 20);

    expect((result as FailureResult).failure, isA<ParsingFailure>());
  });

  test('a refused listing carries the sentence the server gave', () async {
    when(
      () => remote.fetchStories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const ServerException('HTTP 500'));

    final result = await repository.getFeed(locale: 'en', page: 1, perPage: 20);

    final failure = (result as FailureResult).failure;
    expect(failure, isA<ServerFailure>());
    expect(failure.message, 'HTTP 500');
  });

  test('the sentence a recorded view came back with is passed through', () async {
    when(
      () => remote.recordView(
        storyId: any(named: 'storyId'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => 'View recorded');

    final result = await repository.recordView(storyId: 4, locale: 'ar');

    expect((result as Success).value, 'View recorded');
    verify(() => remote.recordView(storyId: 4, locale: 'ar')).called(1);
  });

  test('the sentence an answered poll came back with is passed through', () async {
    when(
      () => remote.votePoll(
        storyId: any(named: 'storyId'),
        optionId: any(named: 'optionId'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => 'Vote recorded');

    final result = await repository.votePoll(
      storyId: 4,
      optionId: 9,
      locale: 'ar',
    );

    expect((result as Success).value, 'Vote recorded');
    verify(
      () => remote.votePoll(storyId: 4, optionId: 9, locale: 'ar'),
    ).called(1);
  });

  test('a vote the endpoint refuses is a failure carrying its reason', () async {
    when(
      () => remote.votePoll(
        storyId: any(named: 'storyId'),
        optionId: any(named: 'optionId'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const ServerException('Invalid poll option'));

    final result = await repository.votePoll(
      storyId: 4,
      optionId: 99,
      locale: 'ar',
    );

    final failure = (result as FailureResult).failure;
    expect(failure, isA<ServerFailure>());
    expect(failure.message, 'Invalid poll option');
  });

  test('a view that cannot reach the server is a network failure', () async {
    when(
      () => remote.recordView(
        storyId: any(named: 'storyId'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.recordView(storyId: 4, locale: 'ar');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('one service\'s archive is asked for with that service\'s id', () async {
    final result = await repository.getServiceFeed(
      serviceId: 1,
      locale: 'ar',
      page: 2,
      perPage: 20,
    );

    expect((result as Success).value, _feed);
    verify(
      () => remote.fetchServiceStories(
        serviceId: 1,
        locale: 'ar',
        page: 2,
        perPage: 20,
      ),
    ).called(1);
  });

  test('an archive the endpoint refuses is a failure carrying its reason', () async {
    when(
      () => remote.fetchServiceStories(
        serviceId: any(named: 'serviceId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenThrow(const ServerException('HTTP 500'));

    final failure = (await repository.getServiceFeed(
      serviceId: 1,
      locale: 'ar',
      page: 1,
      perPage: 20,
    ) as FailureResult)
        .failure;
    expect(failure, isA<ServerFailure>());
    expect(failure.message, 'HTTP 500');
  });
}
