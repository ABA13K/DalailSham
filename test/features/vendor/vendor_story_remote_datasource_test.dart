import 'dart:convert';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_story_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_story_edit.dart';
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

DalilVendorStoryRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorStoryRemoteDataSource(Dio()..httpClientAdapter = adapter);

/// The write is multipart, so the words come back off the [FormData] rather
/// than a JSON body.
Map<String, String> _fields(_StubAdapter adapter) {
  final form = adapter.captured?.data as FormData;
  return {for (final entry in form.fields) entry.key: entry.value};
}

Map<String, MultipartFile> _files(_StubAdapter adapter) {
  final form = adapter.captured?.data as FormData;
  return {for (final entry in form.files) entry.key: entry.value};
}

/// A reply as `POST /vendor/stories` answers it: the story is stored but no
/// admin has looked at it yet.
const _stored = <String, dynamic>{
  'id': 12,
  'type': 'image',
  'image': 'http://127.0.0.1/storage/vendor/stories/12.jpg',
  'caption': 'قهوة',
  'status': 'pending',
  'is_approved': false,
  'is_pending': true,
  'expires_at': '2026-11-05 19:24:00',
  'service': {'id': 3, 'name': 'مقهي', 'slug': 'mqhy'},
};

final _photo = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'story.jpg',
);

final _clip = AvatarFile(
  bytes: Uint8List.fromList([4, 5, 6]),
  fileName: 'story.mp4',
);

const _poll = VendorStoryPollEdit(
  questionAr: 'أي نوع تفضل؟',
  questionEn: 'Which do you prefer?',
  options: [
    VendorStoryOptionEdit(optionAr: 'ساخن', optionEn: 'Hot'),
    VendorStoryOptionEdit(optionAr: 'بارد'),
  ],
);

void main() {
  test('a picture posts to the story endpoint with the locale asked for', () async {
    final adapter = _StubAdapter(status: 201, payload: {'data': _stored});

    final story = await _dataSource(adapter).add(
      edit: const VendorStoryEdit(
        type: VendorStoryType.image,
        captionAr: 'قهوة',
        captionEn: 'Coffee',
      ),
      file: _photo,
      locale: 'ar',
    );

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.vendorStoriesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(_fields(adapter), {
      'type': 'image',
      'caption_ar': 'قهوة',
      'caption_en': 'Coffee',
    });
    expect(_files(adapter).keys, ['image']);
    expect(_files(adapter)['image']?.filename, 'story.jpg');
    expect(story.id, 12);
    expect(story.type, VendorStoryType.image);
    expect(story.caption, 'قهوة');
    expect(story.status, 'pending');
    expect(story.isApproved, isFalse);
    expect(story.isPending, isTrue);
    // A storage address on the dev host still has to load on a device.
    expect(
      story.imageUrl,
      'https://dalildimashq.com/storage/vendor/stories/12.jpg',
    );
  });

  test('a clip rides under the video part, not the image one', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {
        'data': <String, dynamic>{
          ..._stored,
          'type': 'video',
          'image': null,
          'video': 'http://127.0.0.1/storage/vendor/stories/13.mp4',
        },
      },
    );

    final story = await _dataSource(adapter).add(
      edit: const VendorStoryEdit(type: VendorStoryType.video),
      file: _clip,
      locale: 'en',
    );

    expect(_fields(adapter)['type'], 'video');
    expect(_files(adapter).keys, ['video']);
    expect(_files(adapter)['video']?.filename, 'story.mp4');
    expect(story.videoUrl, 'https://dalildimashq.com/storage/vendor/stories/13.mp4');
    expect(story.imageUrl, isNull);
  });

  test('an omitted caption half is sent empty rather than left out', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _stored});

    await _dataSource(adapter).add(
      edit: const VendorStoryEdit(type: VendorStoryType.image, captionAr: 'قهوة'),
      file: _photo,
      locale: 'ar',
    );

    expect(_fields(adapter)['caption_ar'], 'قهوة');
    expect(_fields(adapter)['caption_en'], '');
  });

  test(
    'a poll arrives flattened into the parts the endpoint reads',
    () async {
      final adapter = _StubAdapter(
        status: 201,
        payload: {
          'data': <String, dynamic>{
            ..._stored,
            'type': 'poll',
            'image': null,
            'poll': {
              'id': 4,
              'question': 'أي نوع تفضل؟',
              'total_votes': 0,
              'options': [
                {'id': 1, 'option': 'ساخن', 'votes_count': 0},
                {'id': 2, 'option': 'بارد', 'votes_count': 0},
              ],
            },
          },
        },
      );

      final story = await _dataSource(adapter).add(
        edit: const VendorStoryEdit(type: VendorStoryType.poll, poll: _poll),
        locale: 'ar',
      );

      expect(_fields(adapter), {
        'type': 'poll',
        'caption_ar': '',
        'caption_en': '',
        'poll[question_ar]': 'أي نوع تفضل؟',
        'poll[question_en]': 'Which do you prefer?',
        'poll[options][0][option_ar]': 'ساخن',
        'poll[options][0][option_en]': 'Hot',
        'poll[options][1][option_ar]': 'بارد',
        'poll[options][1][option_en]': '',
      });
      // The question is the story, so no file is expected beside it.
      expect(_files(adapter), isEmpty);
      expect(story.type, VendorStoryType.poll);
    },
  );

  test('the choices keep the order they were written in', () async {
    final adapter = _StubAdapter(status: 201, payload: {'data': _stored});

    await _dataSource(adapter).add(
      edit: const VendorStoryEdit(
        type: VendorStoryType.poll,
        poll: VendorStoryPollEdit(
          questionAr: 'سؤال',
          options: [
            VendorStoryOptionEdit(optionAr: 'أول'),
            VendorStoryOptionEdit(optionAr: 'ثاني'),
            VendorStoryOptionEdit(optionAr: 'ثالث'),
          ],
        ),
      ),
      locale: 'ar',
    );

    expect(_fields(adapter)['poll[options][0][option_ar]'], 'أول');
    expect(_fields(adapter)['poll[options][1][option_ar]'], 'ثاني');
    expect(_fields(adapter)['poll[options][2][option_ar]'], 'ثالث');
  });

  test('a pending story is pending even when the reply says nothing', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {
        'data': <String, dynamic>{'id': 1, 'type': 'image'},
      },
    );

    final story = await _dataSource(adapter).add(
      edit: const VendorStoryEdit(type: VendorStoryType.image),
      locale: 'en',
    );

    expect(story.isApproved, isFalse);
    expect(story.isPending, isTrue);
    expect(story.caption, isNull);
  });

  test('an approval the reply already carries is kept', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': <String, dynamic>{
          'id': 2,
          'type': 'poll',
          'is_approved': 1,
          'is_pending': 0,
        },
      },
    );

    final story = await _dataSource(adapter).add(
      edit: const VendorStoryEdit(type: VendorStoryType.poll),
      locale: 'en',
    );

    expect(story.isApproved, isTrue);
    expect(story.isPending, isFalse);
  });

  test('a reply of a type the app cannot post is a parsing failure', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': <String, dynamic>{'id': 3, 'type': 'gif'},
      },
    );

    await expectLater(
      _dataSource(adapter).add(
        edit: const VendorStoryEdit(type: VendorStoryType.image),
        locale: 'en',
      ),
      throwsA(isA<ParseException>()),
    );
  });

  test('a reply with no story in it is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    await expectLater(
      _dataSource(adapter).add(
        edit: const VendorStoryEdit(type: VendorStoryType.image),
        locale: 'en',
      ),
      throwsA(isA<ParseException>()),
    );
  });

  test('a refused write shows the sentence about the field', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The given data was invalid.',
        'errors': <String, dynamic>{
          'image': <dynamic>['The image field is required.'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).add(
        edit: const VendorStoryEdit(type: VendorStoryType.image),
        locale: 'ar',
      ),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'The image field is required.',
        ),
      ),
    );
  });

  test('a refusal that names nothing falls back to the status', () async {
    final adapter = _StubAdapter(status: 403, payload: <String, dynamic>{});

    await expectLater(
      _dataSource(adapter).add(
        edit: const VendorStoryEdit(type: VendorStoryType.video),
        locale: 'en',
      ),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'HTTP 403',
        ),
      ),
    );
  });
}
