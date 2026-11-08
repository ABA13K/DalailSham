import 'package:dali_alsham/core/network/auth_interceptor.dart';
import 'package:dali_alsham/core/settings/domain/token_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenRepository extends Mock implements TokenRepository {}

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString('', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockTokenRepository tokenRepository;
  late _CapturingAdapter adapter;
  late Dio dio;

  setUp(() {
    tokenRepository = _MockTokenRepository();
    when(() => tokenRepository.getToken()).thenAnswer((_) async => null);
    adapter = _CapturingAdapter();
    dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(tokenRepository));
  });

  test('sends the stored token as a bearer header', () async {
    when(() => tokenRepository.getToken()).thenAnswer((_) async => 't-123');

    await dio.get<dynamic>('/categories/1/services');

    expect(adapter.captured?.headers['Authorization'], 'Bearer t-123');
  });

  test('sends no authorization header without a token', () async {
    await dio.get<dynamic>('/categories/1/services');

    expect(adapter.captured?.headers.containsKey('Authorization'), isFalse);
  });
}
