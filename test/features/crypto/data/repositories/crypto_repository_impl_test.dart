import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/error/failures.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_local_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_remote_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_detail_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/global_market_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/trending_coin_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CryptoRepositoryImpl', () {
    test(
        'Given remote coins succeed, when coins are requested, then favorites are applied and response is cached',
        () async {
      final remote = _FakeRemoteDataSource()
        ..coins = const [
          CoinModel(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
        ];
      final local = _FakeLocalDataSource()..favoriteIds = {'bitcoin'};
      final repository = CryptoRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: const _FakeNetworkInfo(isConnected: true),
      );

      final result = await repository.getCoins(page: 1, perPage: 25);

      switch (result) {
        case Success(value: final coinsResult):
          expect(coinsResult.source, ResultSource.remote);
          final coins = coinsResult.data;
          expect(coins.single.id, 'bitcoin');
          expect(coins.single.isFavorite, isTrue);
        case Error(failure: final failure):
          fail(failure.message);
      }
      expect(local.cachedCoinPages.keys, [1]);
    });

    test(
        'Given device is offline and cache exists, when coins are requested, then cached data is returned',
        () async {
      final local = _FakeLocalDataSource()
        ..cachedCoinPages[1] = const [
          CoinModel(id: 'ethereum', symbol: 'eth', name: 'Ethereum'),
        ];
      final repository = CryptoRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(),
        localDataSource: local,
        networkInfo: const _FakeNetworkInfo(isConnected: false),
      );

      final result = await repository.getCoins(page: 1, perPage: 25);

      switch (result) {
        case Success(value: final coinsResult):
          expect(coinsResult.source, ResultSource.cache);
          expect(coinsResult.lastUpdated, local.cachedAt);
          final coins = coinsResult.data;
          expect(coins.single.id, 'ethereum');
        case Error(failure: final failure):
          fail(failure.message);
      }
    });

    test(
        'Given remote fails and cache exists, when coins are requested, then cached data is returned with cache source',
        () async {
      final remote = _FakeRemoteDataSource()
        ..coinsError = const ServerException('Rate limited');
      final local = _FakeLocalDataSource()
        ..cachedCoinPages[1] = const [
          CoinModel(id: 'solana', symbol: 'sol', name: 'Solana'),
        ];
      final repository = CryptoRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: const _FakeNetworkInfo(isConnected: true),
      );

      final result = await repository.getCoins(page: 1, perPage: 25);

      switch (result) {
        case Success(value: final coinsResult):
          expect(coinsResult.source, ResultSource.cache);
          final coins = coinsResult.data;
          expect(coins.single.id, 'solana');
        case Error(failure: final failure):
          fail(failure.message);
      }
    });

    test(
        'Given remote is rate limited and cache exists, when coins are requested, then cached data is returned',
        () async {
      final remote = _FakeRemoteDataSource()
        ..coinsError = const RateLimitException(
          'Rate limited',
          code: '429',
          retryAfter: Duration(seconds: 30),
        );
      final local = _FakeLocalDataSource()
        ..cachedCoinPages[1] = const [
          CoinModel(id: 'ethereum', symbol: 'eth', name: 'Ethereum'),
        ];
      final repository = CryptoRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
        networkInfo: const _FakeNetworkInfo(isConnected: true),
      );

      final result = await repository.getCoins(page: 1, perPage: 25);

      switch (result) {
        case Success(value: final coinsResult):
          expect(coinsResult.source, ResultSource.cache);
          expect(coinsResult.data.single.id, 'ethereum');
        case Error(failure: final failure):
          fail(failure.message);
      }
    });

    test(
        'Given remote is rate limited and cache is empty, when coins are requested, then rate-limit failure is returned',
        () async {
      final remote = _FakeRemoteDataSource()
        ..coinsError = const RateLimitException(
          'Rate limited',
          code: '429',
          retryAfter: Duration(seconds: 30),
        );
      final repository = CryptoRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: _FakeLocalDataSource(),
        networkInfo: const _FakeNetworkInfo(isConnected: true),
      );

      final result = await repository.getCoins(page: 1, perPage: 25);

      switch (result) {
        case Success():
          fail('Expected rate-limit failure');
        case Error(failure: final failure):
          expect(failure, isA<RateLimitFailure>());
          expect(
            failure.message,
            'Too many requests. Please wait and try again.',
          );
          expect(
            (failure as RateLimitFailure).retryAfter,
            const Duration(seconds: 30),
          );
      }
    });

    test(
        'Given remote failure contains raw Dio text, when no cache exists, then user-facing failure is returned',
        () async {
      final remote = _FakeRemoteDataSource()
        ..coinsError = const ServerException(
          'DioException [bad response]: https://api.coingecko.com/api/v3/coins/markets',
        );
      final repository = CryptoRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: _FakeLocalDataSource(),
        networkInfo: const _FakeNetworkInfo(isConnected: true),
      );

      final result = await repository.getCoins(page: 1, perPage: 25);

      switch (result) {
        case Success():
          fail('Expected sanitized failure');
        case Error(failure: final failure):
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Unable to load data. Please try again.');
          expect(failure.message, isNot(contains('DioException')));
          expect(failure.message, isNot(contains('api.coingecko.com')));
      }
    });

    test(
        'Given favorite is toggled, when repository handles request, then local datasource persists it',
        () async {
      final local = _FakeLocalDataSource();
      final repository = CryptoRepositoryImpl(
        remoteDataSource: _FakeRemoteDataSource(),
        localDataSource: local,
        networkInfo: const _FakeNetworkInfo(isConnected: true),
      );

      final result = await repository.toggleFavorite('bitcoin');

      switch (result) {
        case Success(value: final isFavorite, source: final source):
          expect(source, ResultSource.local);
          expect(isFavorite, isTrue);
          expect(local.favoriteIds, {'bitcoin'});
        case Error(failure: final failure):
          fail(failure.message);
      }
    });
  });
}

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo({required bool isConnected})
      : _isConnected = isConnected;

  final bool _isConnected;

  @override
  Future<bool> get isConnected async => _isConnected;
}

class _FakeRemoteDataSource implements CryptoRemoteDataSource {
  List<CoinModel> coins = const [];
  AppException? coinsError;

  @override
  Future<List<CoinModel>> getCoins({
    required int page,
    required int perPage,
  }) async {
    final error = coinsError;
    if (error != null) {
      throw error;
    }

    return coins;
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) {
    throw UnimplementedError();
  }

  @override
  Future<GlobalMarketModel> getGlobalMarket() {
    throw UnimplementedError();
  }

  @override
  Future<List<TrendingCoinModel>> getTrendingCoins() {
    throw UnimplementedError();
  }

  @override
  Future<List<CoinModel>> searchCoins(String query) {
    throw UnimplementedError();
  }
}

class _FakeLocalDataSource implements CryptoLocalDataSource {
  final cachedCoinPages = <int, List<CoinModel>>{};
  final cachedAt = DateTime.utc(2026, 1, 1, 12);
  Set<String> favoriteIds = {};

  @override
  Future<void> cacheCoins({
    required int page,
    required List<CoinModel> coins,
  }) async {
    cachedCoinPages[page] = coins;
  }

  @override
  Future<CachedData<List<CoinModel>>?> getCachedCoinsWithMetadata(
    int page, {
    bool allowStale = false,
  }) async {
    final coins = cachedCoinPages[page];
    if (coins == null) {
      return null;
    }

    return CachedData(data: coins, cachedAt: cachedAt);
  }

  @override
  Future<List<CoinModel>> getCachedCoins(
    int page, {
    bool allowStale = false,
  }) async {
    return cachedCoinPages[page] ?? const [];
  }

  @override
  Future<Set<String>> getFavoriteIds() async => favoriteIds;

  @override
  Future<void> invalidateExpiredCache() async {}

  @override
  Future<bool> toggleFavorite(String coinId) async {
    if (favoriteIds.contains(coinId)) {
      favoriteIds.remove(coinId);
      return false;
    }

    favoriteIds.add(coinId);
    return true;
  }

  @override
  Future<bool> isFavorite(String coinId) async {
    return favoriteIds.contains(coinId);
  }

  @override
  Future<void> cacheCoinDetail(CoinDetailModel coin) {
    throw UnimplementedError();
  }

  @override
  Future<CachedData<CoinDetailModel>?> getCachedCoinDetailWithMetadata(
    String coinId, {
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> cacheGlobalMarket(GlobalMarketModel market) {
    throw UnimplementedError();
  }

  @override
  Future<void> cacheTrendingCoins(List<TrendingCoinModel> coins) {
    throw UnimplementedError();
  }

  @override
  Future<CoinDetailModel?> getCachedCoinDetail(
    String coinId, {
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<GlobalMarketModel?> getCachedGlobalMarket({
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedData<GlobalMarketModel>?> getCachedGlobalMarketWithMetadata({
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<TrendingCoinModel>> getCachedTrendingCoins({
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedData<List<TrendingCoinModel>>?>
      getCachedTrendingCoinsWithMetadata({
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<CoinModel>> searchCachedCoins(
    String query, {
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CachedData<List<CoinModel>>?> searchCachedCoinsWithMetadata(
    String query, {
    bool allowStale = false,
  }) {
    throw UnimplementedError();
  }
}
