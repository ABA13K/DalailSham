import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/story_feed.dart';
import '../models/story_model.dart';

abstract interface class StoryRemoteDataSource {
  Future<StoryFeed> fetchStories({
    required String locale,
    required int page,
    required int perPage,
  });

  /// `GET /stories/service/{id}` — every story one service posted, newest
  /// first, in the same page-by-page envelope as the public feed.
  Future<StoryFeed> fetchServiceStories({
    required int serviceId,
    required String locale,
    required int page,
    required int perPage,
  });

  /// `POST user/stories/{id}/view` — the server takes note that this signed-in
  /// reader watched the story.
  Future<String> recordView({required int storyId, required String locale});

  /// `POST user/stories/{id}/poll/vote` — the reader's answer to the poll.
  Future<String> votePoll({
    required int storyId,
    required int optionId,
    required String locale,
  });
}

/// Remote data source backed by the public stories listing.
class DalilStoryRemoteDataSource implements StoryRemoteDataSource {
  DalilStoryRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<StoryFeed> fetchStories({
    required String locale,
    required int page,
    required int perPage,
  }) => _page(ApiConstants.storiesPath, locale: locale, page: page, perPage: perPage);

  @override
  Future<StoryFeed> fetchServiceStories({
    required int serviceId,
    required String locale,
    required int page,
    required int perPage,
  }) => _page(
    ApiConstants.storiesServicePath(serviceId),
    locale: locale,
    page: page,
    perPage: perPage,
  );

  Future<StoryFeed> _page(
    String path, {
    required String locale,
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: <String, dynamic>{
          'locale': locale,
          'per_page': perPage,
          'page': page,
        },
      );

      return _feed(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<String> recordView({
    required int storyId,
    required String locale,
  }) => _record(ApiConstants.storyViewPath(storyId), locale: locale);

  @override
  Future<String> votePoll({
    required int storyId,
    required int optionId,
    required String locale,
  }) => _record(
    ApiConstants.storyPollVotePath(storyId),
    locale: locale,
    body: <String, Object?>{'option_id': optionId},
  );

  /// The two signed-in calls answer `{message, data}` with nothing in `data`,
  /// so the sentence is all that comes back — and it is what the reader is
  /// shown when the answer did not land.
  Future<String> _record(
    String path, {
    required String locale,
    Map<String, Object?>? body,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        queryParameters: <String, dynamic>{'locale': locale},
        data: body,
      );
      return _message(response.data);
    } on DioException catch (error) {
      throw _mapActionException(error);
    }
  }

  static String _message(Object? body) =>
      body is Map<String, dynamic>
      ? (body['message'] as String?)?.trim() ?? ''
      : '';

  /// The listing answers with the same envelope as every other one: the rows in
  /// `data`, the page that follows them in `pagination`.
  StoryFeed _feed(Object? body) {
    final listing = body is Map<String, dynamic> ? body : const {};
    final pagination = listing['pagination'];
    return StoryFeed(
      stories: _parseItems(listing['data']),
      hasMore: pagination is Map<String, dynamic>
          ? pagination['has_more'] == true
          : false,
      nextPage: pagination is Map<String, dynamic>
          ? (pagination['next_page'] as num?)?.toInt()
          : null,
    );
  }

  List<StoryModel> _parseItems(Object? items) {
    if (items is! List) {
      throw const ParseException('Missing stories in response');
    }

    return [
      for (final item in items) ?StoryModel.tryFromJson(item),
    ];
  }

  /// A refused view or vote is answered with the sentence the backend wrote,
  /// which is more use to the reader than a status code.
  AppException _mapActionException(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final message = _message(error.response?.data);
      return ServerException(
        message.isEmpty ? 'HTTP ${error.response?.statusCode}' : message,
      );
    }
    return _mapDioException(error);
  }

  AppException _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => ServerException(
        'HTTP ${error.response?.statusCode}',
      ),
      _ => ServerException(error.message ?? 'Request failed'),
    };
  }
}
