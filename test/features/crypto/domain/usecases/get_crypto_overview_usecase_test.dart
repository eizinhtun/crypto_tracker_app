import 'package:crypto_tracker_app/core/error/failures.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/global_market.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/trending_coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_crypto_overview_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GetCryptoOverviewUseCase', () {
    test('normalizes pagination and composes overview data', () async {
      final repository = _FakeCryptoRepository();
      final useCase = GetCryptoOverviewUseCase(repository);

      final result = await useCase(page: -4, perPage: 999);

      expect(repository.requestedPage, 1);
      expect(repository.requestedPerPage, 250);

      final overviewResult = switch (result) {
        Success(value: final value) => value,
        Error(failure: final failure) => fail(failure.message),
      };
      final overview = overviewResult.data;

      expect(overview.coins, repository.coins);
      expect(overview.trendingCoins, repository.trendingCoins);
      expect(overview.globalMarket, repository.globalMarket);
      expect(overview.hasReachedMax, isTrue);
    });

    test('keeps required coin data and records optional data warnings',
        () async {
      final repository = _FakeCryptoRepository()
        ..trendingResult = const Result.failure(
          CacheFailure('Trending unavailable'),
        )
        ..globalResult = const Result.failure(
          CacheFailure('Market unavailable'),
        );
      final useCase = GetCryptoOverviewUseCase(repository);

      final result = await useCase();

      final overviewResult = switch (result) {
        Success(value: final value) => value,
        Error(failure: final failure) => fail(failure.message),
      };
      final overview = overviewResult.data;

      expect(overview.coins, repository.coins);
      expect(overview.trendingCoins, isEmpty);
      expect(overview.globalMarket, isNull);
      expect(
        overview.warnings,
        ['Trending unavailable', 'Market unavailable'],
      );
      expect(
        overview.warningCategories,
        [
          FailureCategory.cacheUnavailable,
          FailureCategory.cacheUnavailable,
        ],
      );
    });

    test('preserves cache source metadata from required coin data', () async {
      final repository = _FakeCryptoRepository()
        ..coinsResult = const Result.success(
          DataResult.cache(
            [
              Coin(
                id: 'bitcoin',
                symbol: 'btc',
                name: 'Bitcoin',
              ),
            ],
          ),
        );
      final useCase = GetCryptoOverviewUseCase(repository);

      final result = await useCase();

      switch (result) {
        case Success(value: final overviewResult):
          expect(overviewResult.source, ResultSource.cache);
          expect(overviewResult.isFromCache, isTrue);
          expect(overviewResult.data.coins.single.id, 'bitcoin');
        case Error(failure: final failure):
          fail(failure.message);
      }
    });

    test(
        'preserves remote source when only optional overview data comes from cache',
        () async {
      final repository = _FakeCryptoRepository();
      repository.trendingResult = Result.success(
        DataResult.cache(
          repository.trendingCoins,
          lastUpdated: DateTime.utc(2026, 1, 1),
        ),
      );
      final useCase = GetCryptoOverviewUseCase(repository);

      final result = await useCase();

      switch (result) {
        case Success(value: final overviewResult):
          expect(overviewResult.source, ResultSource.remote);
          expect(overviewResult.isFromCache, isFalse);
          expect(overviewResult.data.hasCachedData, isTrue);
          expect(overviewResult.lastUpdated, DateTime.utc(2026, 1, 1));
        case Error(failure: final failure):
          fail(failure.message);
      }
    });
  });
}

class _FakeCryptoRepository implements CryptoRepository {
  int? requestedPage;
  int? requestedPerPage;

  final coins = const [
    Coin(
      id: 'bitcoin',
      symbol: 'btc',
      name: 'Bitcoin',
      currentPrice: 100000,
    ),
  ];

  final trendingCoins = const [
    TrendingCoin(
      id: 'ethereum',
      name: 'Ethereum',
      symbol: 'eth',
    ),
  ];

  final globalMarket = const GlobalMarket(
    activeCryptocurrencies: 10000,
    markets: 1200,
    totalMarketCapUsd: 3000000000000,
    totalVolumeUsd: 100000000000,
    marketCapChangePercentage24hUsd: 2.5,
  );

  late Result<DataResult<List<Coin>>> coinsResult =
      Result.success(DataResult.remote(coins));
  late Result<DataResult<List<TrendingCoin>>> trendingResult =
      Result.success(DataResult.remote(trendingCoins));
  late Result<DataResult<GlobalMarket>> globalResult =
      Result.success(DataResult.remote(globalMarket));

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    requestedPage = page;
    requestedPerPage = perPage;
    return coinsResult;
  }

  @override
  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket() async =>
      globalResult;

  @override
  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins() async =>
      trendingResult;

  @override
  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> toggleFavorite(String coinId) {
    throw UnimplementedError();
  }
}
