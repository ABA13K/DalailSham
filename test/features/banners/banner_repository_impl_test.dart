import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/banners/data/datasources/banner_remote_datasource.dart';
import 'package:dali_alsham/features/banners/data/models/banner_ad_model.dart';
import 'package:dali_alsham/features/banners/data/repositories/banner_repository_impl.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBannerRemoteDataSource extends Mock
    implements BannerRemoteDataSource {}

void main() {
  late _MockBannerRemoteDataSource remote;

  setUp(() {
    remote = _MockBannerRemoteDataSource();
  });

  test('returns every banner the API serves', () async {
    when(
      () => remote.fetchBanners(locale: any(named: 'locale')),
    ).thenAnswer(
      (_) async => const [
        BannerAdModel(
          id: 1,
          text: '20% discount with Banque Saudi Fransi (BSF)',
        ),
        BannerAdModel(id: 2, text: 'Free delivery across Damascus'),
      ],
    );

    final result = await BannerRepositoryImpl(remote).getBanners(locale: 'en');

    expect((result as Success<List<BannerAd>>).value, hasLength(2));
  });

  test('maps datasource errors to failures', () async {
    when(
      () => remote.fetchBanners(locale: any(named: 'locale')),
    ).thenThrow(const NetworkException());

    final result = await BannerRepositoryImpl(remote).getBanners(locale: 'ar');

    expect(result, isA<FailureResult<List<BannerAd>>>());
    expect(
      (result as FailureResult<List<BannerAd>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('rewrites localhost image origins to the public host', () {
    final banner = BannerAdModel.fromJson(<String, dynamic>{
      'id': 1,
      'image': 'http://127.0.0.1:8000/storage/banners/x.png',
      'text': 'خصم بنسى 20 بالمية',
    });

    expect(banner.imageUrl, 'https://dalildimashq.com/storage/banners/x.png');
    expect(banner.text, 'خصم بنسى 20 بالمية');
  });

  test('rejects banner payloads without text', () {
    expect(
      () => BannerAdModel.fromJson(<String, dynamic>{'id': 1, 'image': 'x'}),
      throwsFormatException,
    );
  });
}
