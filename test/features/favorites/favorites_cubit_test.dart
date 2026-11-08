import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/favorites/domain/entities/favorite_mutation.dart';
import 'package:dali_alsham/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:dali_alsham/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

const _service = ServiceSummary(
  id: 2,
  name: 'Imran',
  slug: 'amran-1',
  isFavorited: false,
);

void main() {
  late _MockFavoritesRepository repository;
  late FavoritesCubit cubit;

  setUp(() {
    repository = _MockFavoritesRepository();
    cubit = FavoritesCubit(repository);
  });

  tearDown(() => cubit.close());

  test('adds a listing favorite and remembers the new flag', () async {
    when(() => repository.add('amran-1')).thenAnswer(
      (_) async => const Success(FavoriteMutation(isFavorited: true)),
    );

    final outcome = await cubit.toggle(_service);

    expect(outcome, FavoriteOutcome.added);
    expect(cubit.isFavorited(_service), isTrue);
    verify(() => repository.add('amran-1')).called(1);
    verifyNever(() => repository.remove(any()));
  });

  test('removes a service the listing already reported as favorite', () async {
    when(() => repository.remove('amran-1')).thenAnswer(
      (_) async => const Success(FavoriteMutation(isFavorited: false)),
    );

    final outcome = await cubit.toggle(
      const ServiceSummary(
        id: 2,
        name: 'Imran',
        slug: 'amran-1',
        isFavorited: true,
      ),
    );

    expect(outcome, FavoriteOutcome.removed);
    expect(cubit.isFavorited(_service), isFalse);
    verify(() => repository.remove('amran-1')).called(1);
  });

  test('keeps the previous flag when the request fails', () async {
    when(
      () => repository.add(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    final outcome = await cubit.toggle(_service);

    expect(outcome, FavoriteOutcome.failure);
    expect(cubit.isFavorited(_service), isFalse);
    expect(cubit.isBusy(_service), isFalse);
  });

  test('marks the service busy while the request runs', () async {
    final gate = Completer<Result<FavoriteMutation>>();
    when(() => repository.add(any())).thenAnswer((_) => gate.future);

    final pending = cubit.toggle(_service);
    expect(cubit.isBusy(_service), isTrue);

    gate.complete(const Success(FavoriteMutation(isFavorited: true)));
    await pending;

    expect(cubit.isBusy(_service), isFalse);
  });

  test('ignores a second tap while a toggle is in flight', () async {
    final gate = Completer<Result<FavoriteMutation>>();
    when(() => repository.add(any())).thenAnswer((_) => gate.future);

    final first = cubit.toggle(_service);
    final second = await cubit.toggle(_service);

    expect(second, FavoriteOutcome.failure);
    gate.complete(const Success(FavoriteMutation(isFavorited: true)));
    await first;

    verify(() => repository.add(any())).called(1);
  });

  test('a service without a slug cannot be toggled', () async {
    final outcome = await cubit.toggle(
      const ServiceSummary(id: 5, name: 'No slug'),
    );

    expect(outcome, FavoriteOutcome.failure);
    verifyZeroInteractions(repository);
  });
}
