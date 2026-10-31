import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/regions/data/datasources/region_remote_datasource.dart';
import 'package:dali_alsham/features/regions/data/models/region_model.dart';
import 'package:dali_alsham/features/regions/data/repositories/region_repository_impl.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/entities/region_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegionRemoteDataSource extends Mock
    implements RegionRemoteDataSource {}

void main() {
  late _MockRegionRemoteDataSource remote;

  setUp(() {
    remote = _MockRegionRemoteDataSource();
  });

  test('trims the random regions to the requested limit', () async {
    when(
      () => remote.fetchRandomRegions(locale: any(named: 'locale')),
    ).thenAnswer(
      (_) async => const [
        RegionModel(id: 1, name: 'Mazzeh'),
        RegionModel(id: 2, name: 'Dummer'),
        RegionModel(id: 3, name: 'Kafr Sousa'),
      ],
    );

    final result = await RegionRepositoryImpl(
      remote,
    ).getRandomRegions(locale: 'en', limit: 2);

    final regions = (result as Success<List<Region>>).value;
    expect(regions.map((region) => region.id), [1, 2]);
  });

  test('maps random datasource errors to failures', () async {
    when(
      () => remote.fetchRandomRegions(locale: any(named: 'locale')),
    ).thenThrow(const NetworkException());

    final result = await RegionRepositoryImpl(
      remote,
    ).getRandomRegions(locale: 'en');

    expect(result, isA<FailureResult<List<Region>>>());
    expect(
      (result as FailureResult<List<Region>>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('maps paged datasource errors to failures', () async {
    when(
      () => remote.fetchRegions(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
      ),
    ).thenThrow(const NetworkException());

    final result = await RegionRepositoryImpl(remote).getRegions(locale: 'en');

    expect(result, isA<FailureResult<RegionPage>>());
    expect(
      (result as FailureResult<RegionPage>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('rewrites localhost image origins and reads region fields', () {
    final region = RegionModel.fromJson(<String, dynamic>{
      'id': 1,
      'name': 'المزة',
      'image': 'http://127.0.0.1:8000/storage/regions/x.png',
      'welcome_phrase': 'اهلا بك في المزة',
      'services_count': 3,
    });

    expect(region.imageUrl, 'https://dalildimashq.com/storage/regions/x.png');
    expect(region.welcomePhrase, 'اهلا بك في المزة');
    expect(region.servicesCount, 3);
  });
}
