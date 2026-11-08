import 'dart:convert';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/stories/data/datasources/story_remote_datasource.dart';
import 'package:dali_alsham/features/stories/domain/entities/story.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.payload});

  final int status;
  final Object? payload;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode(payload ?? <String, dynamic>{}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DalilStoryRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilStoryRemoteDataSource(Dio()..httpClientAdapter = adapter);

/// The body the stub captured, however Dio chose to encode it.
Map<String, dynamic> _sentBody(_StubAdapter adapter) {
  final data = adapter.captured?.data;
  return data is String
      ? jsonDecode(data) as Map<String, dynamic>
      : data as Map<String, dynamic>;
}

/// The service every story in the sample was posted from.
const _alAsad = <String, dynamic>{
  'id': 1,
  'name': 'الاسد',
  'slug': 'amran',
  'image': null,
};

/// One reply as `GET /stories` answers it: a poll, a clip and a picture, each
/// still unread and about to expire.
const _listing = <String, dynamic>{
  'locale': 'ar',
  'count': 3,
  'pagination': <String, dynamic>{
    'current_page': 1,
    'per_page': 20,
    'total': 3,
    'last_page': 1,
    'has_more': false,
    'next_page': null,
    'prev_page': null,
  },
  'data': <dynamic>[
    <String, dynamic>{
      'id': 5,
      'type': 'poll',
      'image': null,
      'video': null,
      'caption': 'عرض جديد اليوم',
      'status': 'approved',
      'is_approved': true,
      'is_pending': false,
      'is_seen': false,
      'expires_at': '2026-11-05T15:26:11+00:00',
      'hours_left': 21,
      'service': _alAsad,
      'poll': <String, dynamic>{
        'id': 2,
        'question': 'ما هو طبقك المفضل؟',
        'total_votes': 0,
        'my_vote': null,
        'options': <dynamic>[
          <String, dynamic>{'id': 4, 'option': 'شاورما', 'votes_count': 0},
          <String, dynamic>{'id': 5, 'option': 'فلافل', 'votes_count': 0},
        ],
      },
      'created_at': '2026-11-04T15:26:11+00:00',
    },
    <String, dynamic>{
      'id': 3,
      'type': 'video',
      'image': null,
      'video': 'https://dalildimashq.com/storage/app/public/stories/videos/clip.mp4',
      'caption': 'عرض جديد اليوم',
      'is_seen': false,
      'hours_left': 21,
      'service': _alAsad,
      'poll': null,
    },
    <String, dynamic>{
      'id': 2,
      'type': 'image',
      'image': 'http://127.0.0.1/storage/app/public/stories/images/photo.png',
      'video': null,
      'caption': 'عرض جديد اليوم',
      'is_seen': true,
      'hours_left': 20,
      'service': _alAsad,
      'poll': null,
    },
  ],
};

Future<StoryFeed> _fetch(Object? payload, {int status = 200}) =>
    _dataSource(_StubAdapter(status: status, payload: payload)).fetchStories(
      locale: 'ar',
      page: 1,
      perPage: 20,
    );

/// One service's whole archive, as `GET /stories/service/1` answers it: three
/// polls, a clip and two pictures, newest first, each row naming the service it
/// belongs to.
const _serviceListing = <String, dynamic>{
  'locale': 'ar',
  'service': _alAsad,
  'count': 6,
  'pagination': <String, dynamic>{
    'current_page': 1,
    'per_page': 20,
    'total': 6,
    'last_page': 1,
    'has_more': false,
    'next_page': null,
    'prev_page': null,
  },
  'data': <dynamic>[
    <String, dynamic>{
      'id': 6,
      'type': 'poll',
      'image': null,
      'video': null,
      'caption': 'عرض جديد اليوم',
      'status': 'approved',
      'is_approved': true,
      'is_pending': false,
      'is_seen': false,
      'expires_at': '2026-11-05T18:00:00+00:00',
      'hours_left': 23,
      'service': _alAsad,
      'poll': <String, dynamic>{
        'id': 3,
        'question': 'ما هو طبقك المفضل؟',
        'total_votes': 0,
        'my_vote': null,
        'options': <dynamic>[
          <String, dynamic>{'id': 8, 'option': 'شاورما', 'votes_count': 0},
          <String, dynamic>{'id': 9, 'option': 'فلافل', 'votes_count': 0},
          <String, dynamic>{'id': 10, 'option': 'برجر', 'votes_count': 0},
        ],
      },
      'created_at': '2026-11-04T18:00:00+00:00',
    },
    <String, dynamic>{
      'id': 5,
      'type': 'poll',
      'caption': 'عرض جديد اليوم',
      'is_seen': false,
      'hours_left': 22,
      'service': _alAsad,
      'poll': <String, dynamic>{
        'id': 2,
        'question': 'أين تأكل؟',
        'total_votes': 0,
        'my_vote': null,
        'options': <dynamic>[
          <String, dynamic>{'id': 5, 'option': 'المزة', 'votes_count': 0},
          <String, dynamic>{'id': 6, 'option': 'الحميدية', 'votes_count': 0},
          <String, dynamic>{'id': 7, 'option': 'القصاع', 'votes_count': 0},
        ],
      },
    },
    <String, dynamic>{
      'id': 4,
      'type': 'poll',
      'caption': 'عرض جديد اليوم',
      'is_seen': false,
      'hours_left': 22,
      'service': _alAsad,
      'poll': <String, dynamic>{
        'id': 1,
        'question': 'متى تزورنا؟',
        'total_votes': 1,
        'my_vote': null,
        'options': <dynamic>[
          <String, dynamic>{'id': 1, 'option': 'صباحاً', 'votes_count': 1},
          <String, dynamic>{'id': 2, 'option': 'مساءً', 'votes_count': 0},
          <String, dynamic>{'id': 3, 'option': 'نهائياً', 'votes_count': 0},
        ],
      },
    },
    <String, dynamic>{
      'id': 3,
      'type': 'video',
      'image': null,
      'video': 'https://dalildimashq.com/storage/app/public/stories/videos/VKrm.mp4',
      'caption': 'عرض جديد اليوم',
      'is_seen': false,
      'hours_left': 21,
      'service': _alAsad,
      'poll': null,
    },
    <String, dynamic>{
      'id': 2,
      'type': 'image',
      'image': 'https://dalildimashq.com/storage/app/public/stories/images/nPel.png',
      'video': null,
      'caption': 'عرض جديد اليوم',
      'is_seen': false,
      'hours_left': 21,
      'service': _alAsad,
      'poll': null,
    },
    <String, dynamic>{
      'id': 1,
      'type': 'image',
      'image': 'https://dalildimashq.com/storage/app/public/stories/images/Qs1d.png',
      'video': null,
      'caption': 'عرض جديد اليوم',
      'is_seen': false,
      'hours_left': 20,
      'service': _alAsad,
      'poll': null,
    },
  ],
};

Future<StoryFeed> _fetchService(
  Object? payload, {
  int serviceId = 1,
  int page = 1,
  int status = 200,
}) =>
    _dataSource(_StubAdapter(status: status, payload: payload))
        .fetchServiceStories(
          serviceId: serviceId,
          locale: 'ar',
          page: page,
          perPage: 20,
        );

void main() {
  test('the listing is asked for in the readers language, page by page', () async {
    final adapter = _StubAdapter(status: 200, payload: _listing);

    final feed = await _dataSource(adapter).fetchStories(
      locale: 'ar',
      page: 2,
      perPage: 10,
    );

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.storiesPath);
    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'per_page': 10,
      'page': 2,
    });
    // The sample page is the only one, so nothing follows it.
    expect(feed.hasMore, isFalse);
    expect(feed.nextPage, isNull);
  });

  test('the three kinds of story arrive as the app draws them', () async {
    final feed = await _fetch(_listing);

    expect(feed.stories.map((story) => story.id), [5, 3, 2]);

    final poll = feed.stories.first;
    expect(poll.type, StoryType.poll);
    expect(poll.caption, 'عرض جديد اليوم');
    expect(poll.hoursLeft, 21);
    expect(poll.isSeen, isFalse);
    expect(poll.service?.name, 'الاسد');
    expect(poll.service?.slug, 'amran');
    expect(poll.poll?.question, 'ما هو طبقك المفضل؟');
    expect(poll.poll?.options.map((option) => option.text), ['شاورما', 'فلافل']);

    final clip = feed.stories[1];
    expect(clip.type, StoryType.video);
    expect(clip.videoUrl, 'https://dalildimashq.com/storage/app/public/stories/videos/clip.mp4');
    expect(clip.poll, isNull);

    final photo = feed.stories[2];
    expect(photo.type, StoryType.image);
    expect(photo.isSeen, isTrue);
  });

  test('a storage address on the dev host still loads on a device', () async {
    final feed = await _fetch(_listing);

    expect(
      feed.stories.last.imageUrl,
      'https://dalildimashq.com/storage/app/public/stories/images/photo.png',
    );
  });

  test('the count of votes is taken from the options when the total is missing', () async {
    final feed = await _fetch({
      'pagination': {'has_more': false},
      'data': [
        <String, dynamic>{
          'id': 9,
          'type': 'poll',
          'service': _alAsad,
          'poll': <String, dynamic>{
            'id': 3,
            'question': 'كم مرة؟',
            'total_votes': 0,
            'my_vote': 2,
            'options': <dynamic>[
              <String, dynamic>{'id': 1, 'option': 'يومياً', 'votes_count': 7},
              <String, dynamic>{'id': 2, 'option': 'نادراً', 'votes_count': 3},
            ],
          },
        },
      ],
    });

    final poll = feed.stories.single.poll!;
    expect(poll.totalVotes, 10);
    expect(poll.myVoteOptionId, 2);
    expect(poll.shareOf(poll.options.first), 0.7);
    expect(poll.shareOf(poll.options.last), 0.3);
  });

  test('the page that follows is handed to whoever asks for it', () async {
    final feed = await _fetch({
      'pagination': <String, dynamic>{'has_more': true, 'next_page': 2},
      'data': <dynamic>[
        <String, dynamic>{'id': 1, 'type': 'image'},
      ],
    });

    expect(feed.hasMore, isTrue);
    expect(feed.nextPage, 2);
  });

  test('a story of a kind the app cannot draw is left out', () async {
    final feed = await _fetch({
      'pagination': {'has_more': false},
      'data': <dynamic>[
        <String, dynamic>{'id': 7, 'type': 'gif'},
        <String, dynamic>{'type': 'image'},
        <String, dynamic>{'id': 8, 'type': 'IMAGE'},
      ],
    });

    // The unknown kind and the row with no id go; the type left is read
    // whatever case the endpoint sent it in.
    expect(feed.stories.map((story) => story.id), [8]);
  });

  test('a poll nobody can answer is still a story, minus the card', () async {
    final feed = await _fetch({
      'pagination': {'has_more': false},
      'data': <dynamic>[
        <String, dynamic>{
          'id': 11,
          'type': 'poll',
          'poll': <String, dynamic>{
            'id': 4,
            'question': 'سؤال',
            'options': <dynamic>[],
          },
        },
      ],
    });

    expect(feed.stories.single.type, StoryType.poll);
    expect(feed.stories.single.poll, isNull);
  });

  test('a reply with no list in it is a parsing failure', () async {
    await expectLater(
      _fetch({'message': 'No stories'}),
      throwsA(isA<ParseException>()),
    );
  });

  test('a refusal shows the status the endpoint answered with', () async {
    await expectLater(
      _fetch({'message': 'Server Error'}, status: 500),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'HTTP 500',
        ),
      ),
    );
  });

  test('one service\'s whole archive is asked for by its id', () async {
    final adapter = _StubAdapter(status: 200, payload: _serviceListing);

    final feed = await _dataSource(adapter).fetchServiceStories(
      serviceId: 1,
      locale: 'ar',
      page: 2,
      perPage: 20,
    );

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.storiesServicePath(1));
    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'per_page': 20,
      'page': 2,
    });
    // The archive fits in one page, so the list has nothing further to fetch.
    expect(feed.hasMore, isFalse);
    expect(feed.nextPage, isNull);
  });

  test('everything a service posted arrives newest first', () async {
    final feed = await _fetchService(_serviceListing);

    expect(feed.stories.map((story) => story.id), [6, 5, 4, 3, 2, 1]);
    expect(feed.stories.map((story) => story.type), [
      StoryType.poll,
      StoryType.poll,
      StoryType.poll,
      StoryType.video,
      StoryType.image,
      StoryType.image,
    ]);

    // Each row names the service it came from, so the archive needs no extra
    // request to say whose it is.
    expect(feed.stories.every((story) => story.service?.id == 1), isTrue);
    expect(feed.stories.first.service?.name, 'الاسد');
    expect(feed.stories.first.caption, 'عرض جديد اليوم');
    expect(feed.stories.first.hoursLeft, 23);

    expect(
      feed.stories.first.poll?.options.map((option) => option.text),
      ['شاورما', 'فلافل', 'برجر'],
    );
    expect(
      feed.stories[3].videoUrl,
      'https://dalildimashq.com/storage/app/public/stories/videos/VKrm.mp4',
    );
    expect(
      feed.stories.last.imageUrl,
      'https://dalildimashq.com/storage/app/public/stories/images/Qs1d.png',
    );

    // The poll that already has a vote keeps the total the endpoint counted.
    final answered = feed.stories[2];
    expect(answered.poll?.totalVotes, 1);
    expect(answered.poll?.options.first.votesCount, 1);
    expect(answered.poll?.shareOf(answered.poll!.options.first), 1.0);
  });

  test('a service with nothing left to show is an empty archive', () async {
    final feed = await _fetchService({
      'pagination': {'has_more': false},
      'data': <dynamic>[],
    });

    expect(feed.stories, isEmpty);
    expect(feed.hasMore, isFalse);
  });

  test('an archive refusal shows the status the endpoint answered with', () async {
    await expectLater(
      _fetchService({'message': 'Server Error'}, status: 500),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'HTTP 500',
        ),
      ),
    );
  });

  test('watching a story posts the view in the reader\'s language', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'View recorded', 'data': null},
    );

    final message = await _dataSource(adapter).recordView(
      storyId: 4,
      locale: 'ar',
    );

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.storyViewPath(4));
    expect(adapter.captured?.queryParameters['locale'], 'ar');
    expect(message, 'View recorded');
  });

  test('answering a poll posts the option the reader picked', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Vote recorded', 'data': null},
    );

    final message = await _dataSource(adapter).votePoll(
      storyId: 4,
      optionId: 9,
      locale: 'ar',
    );

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.storyPollVotePath(4));
    expect(_sentBody(adapter), {'option_id': 9});
    expect(message, 'Vote recorded');
  });

  test('a refused vote carries the sentence the endpoint wrote', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {'message': 'Invalid poll option', 'errors': <String, dynamic>{}},
    );

    await expectLater(
      _dataSource(adapter).votePoll(storyId: 4, optionId: 99, locale: 'ar'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'Invalid poll option',
        ),
      ),
    );
  });
}
