import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_local_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_remote_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_detail_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Local extends Mock implements CryptoLocalDataSource {}

class _Remote extends Mock implements CryptoRemoteDataSource {}

class _Network extends Mock implements NetworkInfo {}

void main() {
  test('loads only saved IDs across market cache and detail cache offline',
      () async {
    final local = _Local();
    final network = _Network();
    when(() => network.isConnected).thenAnswer((_) async => false);
    when(() => local.getFavoriteIds())
        .thenAnswer((_) async => {'bitcoin', 'ethereum', 'missing'});
    when(() => local.searchCachedCoins('', allowStale: true))
        .thenAnswer((_) async => const [
              CoinModel(id: 'bitcoin', name: 'Bitcoin', symbol: 'btc'),
              CoinModel(id: 'other', name: 'Other', symbol: 'oth'),
            ]);
    when(() =>
            local.getCachedCoinDetailWithMetadata('ethereum', allowStale: true))
        .thenAnswer((_) async => CachedData(
              data: const CoinDetailModel(
                  id: 'ethereum',
                  name: 'Ethereum',
                  symbol: 'eth',
                  currentPrice: 20),
              cachedAt: DateTime.utc(2026),
            ));
    when(() =>
            local.getCachedCoinDetailWithMetadata('missing', allowStale: true))
        .thenAnswer((_) async => null);
    final repository = CryptoRepositoryImpl(
        remoteDataSource: _Remote(),
        localDataSource: local,
        networkInfo: network);
    final result = await repository.getFavorites();
    switch (result) {
      case Success(value: final coins):
        expect(
            coins.map((coin) => coin.id), ['bitcoin', 'ethereum', 'missing']);
        expect(coins.every((coin) => coin.isFavorite), isTrue);
        expect(coins[1].currentPrice, 20);
        expect(coins.last.currentPrice, isNull);
      case Error(failure: final failure):
        fail(failure.message);
    }
  });

  test('empty favorites skips market cache and network access', () async {
    final local = _Local();
    final network = _Network();
    when(() => local.getFavoriteIds()).thenAnswer((_) async => {});
    final repository = CryptoRepositoryImpl(
        remoteDataSource: _Remote(),
        localDataSource: local,
        networkInfo: network);
    final result = await repository.getFavorites();
    expect(result,
        isA<Success>().having((result) => result.value, 'favorites', isEmpty));
    verifyNever(() => network.isConnected);
    verifyNever(() => local.searchCachedCoins('', allowStale: true));
  });
}
