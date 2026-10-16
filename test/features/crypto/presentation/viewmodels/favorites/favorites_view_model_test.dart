import 'dart:async';

import 'package:crypto_tracker_app/core/error/failures.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/favorites_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorites_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/favorites/favorites_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock
    implements CryptoRepository, FavoritesRepository {}

const coins = [
  Coin(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'btc',
      currentPrice: 100,
      marketCap: 500,
      priceChangePercentage24h: -2,
      isFavorite: true),
  Coin(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'eth',
      currentPrice: 20,
      marketCap: 200,
      priceChangePercentage24h: 3,
      isFavorite: true),
  Coin(id: 'unknown', name: 'Unknown', symbol: 'unk', isFavorite: true),
];

void main() {
  late _Repository repository;
  late FavoritesViewModel model;
  setUp(() {
    repository = _Repository();
    when(() => repository.getFavorites())
        .thenAnswer((_) async => const Result.success(coins));
    model = FavoritesViewModel(
        GetFavoritesUseCase(repository), ToggleFavoriteUseCase(repository));
  });
  tearDown(() => model.close());

  test('searches saved names and symbols, ignoring case and spaces', () async {
    await model.load();
    model.search(' BTC ');
    expect(model.state.visibleCoins.map((coin) => coin.id), ['bitcoin']);
    model.search('there');
    expect(model.state.visibleCoins.map((coin) => coin.id), ['ethereum']);
    model.search('missing');
    expect(model.state.visibleCoins, isEmpty);
    expect(model.state.coins, hasLength(3));
  });

  test('sorts descending numeric values with missing values last', () async {
    await model.load();
    for (final sort in [FavoriteSort.price, FavoriteSort.marketCap]) {
      model.sortBy(sort);
      expect(model.state.visibleCoins.map((coin) => coin.id),
          ['bitcoin', 'ethereum', 'unknown']);
    }
    model.sortBy(FavoriteSort.change);
    expect(model.state.visibleCoins.map((coin) => coin.id),
        ['ethereum', 'bitcoin', 'unknown']);
  });

  test('prevents duplicate removal and preserves search and sorting', () async {
    await model.load();
    model.search('btc');
    model.sortBy(FavoriteSort.price);
    final pending = Completer<Result<bool>>();
    when(() => repository.toggleFavorite('bitcoin'))
        .thenAnswer((_) => pending.future);
    final removal = model.remove('bitcoin');
    await model.remove('bitcoin');
    expect(model.state.coins, hasLength(3));
    pending.complete(const Result.success(false));
    await removal;
    expect(model.state.visibleCoins, isEmpty);
    expect(model.state.coins, hasLength(2));
    expect(model.state.sort, FavoriteSort.price);
    verify(() => repository.toggleFavorite('bitcoin')).called(1);
  });

  test('failed removal retains the saved coin and reports failure', () async {
    await model.load();
    when(() => repository.toggleFavorite('bitcoin'))
        .thenAnswer((_) async => const Result.failure(CacheFailure('failed')));
    await model.remove('bitcoin');
    expect(model.state.coins, hasLength(3));
    expect(model.state.failure, FailureCategory.cacheUnavailable);
    expect(model.state.removing, isEmpty);
  });

  test('refresh retains query and sort', () async {
    await model.load();
    model.search('eth');
    model.sortBy(FavoriteSort.change);
    await model.load();
    expect(model.state.query, 'eth');
    expect(model.state.sort, FavoriteSort.change);
  });
}
