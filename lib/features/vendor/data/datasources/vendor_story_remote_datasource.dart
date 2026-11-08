import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_story.dart';
import '../../domain/entities/vendor_story_edit.dart';
import '../models/vendor_story_model.dart';

/// What the vendor story endpoint answers.
abstract interface class VendorStoryRemoteDataSource {
  /// `POST /vendor/stories` — the new story waits for an admin.
  Future<VendorStory> add({
    required VendorStoryEdit edit,
    AvatarFile? file,
    required String locale,
  });
}

/// Remote data source backed by the Dali Alsham vendor story endpoint.
///
/// It is authenticated and scoped to the signed-in vendor's own service; the
/// shared Dio carries the bearer token through `AuthInterceptor`.
class DalilVendorStoryRemoteDataSource implements VendorStoryRemoteDataSource {
  DalilVendorStoryRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<VendorStory> add({
    required VendorStoryEdit edit,
    AvatarFile? file,
    required String locale,
  }) async {
    final body = await _reply(
      () => _dio.post<dynamic>(
        ApiConstants.vendorStoriesPath,
        data: _fields(edit, file),
        queryParameters: <String, String>{'locale': locale},
      ),
    );
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Story reply carried no story');
    }
    try {
      return VendorStoryModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Story reply carried no story');
    }
  }

  /// The call is multipart whatever the vendor posts — a clip, a picture, or a
  /// poll with no file at all — so the words travel as form parts too.
  ///
  /// Dio flattens the nested poll map into the `poll[question_ar]` and
  /// `poll[options][0][option_ar]` parts the endpoint reads.
  static FormData _fields(VendorStoryEdit edit, AvatarFile? file) {
    final fileField = edit.type.fileField;

    return FormData.fromMap(<String, dynamic>{
      'type': edit.type.wire,
      'caption_ar': edit.captionAr ?? '',
      'caption_en': edit.captionEn ?? '',
      if (file != null && fileField != null)
        fileField: MultipartFile.fromBytes(
          file.bytes,
          filename: file.fileName,
        ),
      if (edit.poll != null) 'poll': _poll(edit.poll!),
    });
  }

  static Map<String, Object?> _poll(VendorStoryPollEdit poll) =>
      <String, Object?>{
        'question_ar': poll.questionAr,
        'question_en': poll.questionEn ?? '',
        'options': <Object?>[
          for (final option in poll.options)
            <String, Object?>{
              'option_ar': option.optionAr,
              'option_en': option.optionEn ?? '',
            },
        ],
      };

  Future<Map<String, dynamic>?> _reply(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return _body(await request());
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static Map<String, dynamic>? _body(Response<dynamic>? response) =>
      response?.data is Map<String, dynamic>
      ? response!.data as Map<String, dynamic>
      : null;

  /// A validation reply names the offending field, which says more than the
  /// generic `message` the endpoint returns alongside it.
  static String _message(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    if (errors is Map) {
      for (final messages in errors.values) {
        final first = messages is List && messages.isNotEmpty
            ? messages.first
            : null;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }
    }
    return (body?['message'] as String?)?.trim() ?? '';
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final message = _message(_body(error.response));
      return ServerException(
        message.isEmpty ? 'HTTP ${error.response?.statusCode}' : message,
      );
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      _ => ServerException(error.message ?? 'Request failed'),
    };
  }
}
