import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/global_market.dart';
import '../../domain/entities/trending_coin.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/crypto_local_datasource.dart';
import '../datasources/crypto_remote_datasource.dart';
import '../models/coin_model.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  const CryptoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final CryptoRemoteDataSource remoteDataSource;
  final CryptoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final coins = await remoteDataSource.getCoins(
          page: page,
          perPage: perPage,
        );
        await localDataSource.cacheCoins(page: page, coins: coins);
        return Result.success(
          DataResult.remote(await _toFavoriteAwareCoins(coins)),
        );
      } on AppException catch (error) {
        return _cachedCoins(page, _failureFromException(error));
      } on Object {
        return _cachedCoins(page, _unexpectedFailure);
      }
    }

    return _cachedCoins(
      page,
      const NetworkFailure(_noInternetMessage),
    );
  }

  @override
  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId) async {
    if (await networkInfo.isConnected) {
      try {
        final detail = await remoteDataSource.getCoinDetail(coinId);
        await localDataSource.cacheCoinDetail(detail);
        return Result.success(DataResult.remote(detail.toEntity()));
      } on AppException catch (error) {
        return _cachedCoinDetail(coinId, _failureFromException(error));
      } on Object {
        return _cachedCoinDetail(coinId, _unexpectedFailure);
      }
    }

    return _cachedCoinDetail(
      coinId,
      const NetworkFailure(_noInternetMessage),
    );
  }

  @override
  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins() async {
    if (await networkInfo.isConnected) {
      try {
        final coins = await remoteDataSource.getTrendingCoins();
        await localDataSource.cacheTrendingCoins(coins);
        return Result.success(
          DataResult.remote(coins.map((coin) => coin.toEntity()).toList()),
        );
      } on AppException catch (error) {
        return _cachedTrendingCoins(_failureFromException(error));
      } on Object {
        return _cachedTrendingCoins(_unexpectedFailure);
      }
    }

    return _cachedTrendingCoins(
      const NetworkFailure(_noInternetMessage),
    );
  }

  @override
  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket() async {
    if (await networkInfo.isConnected) {
      try {
        final market = await remoteDataSource.getGlobalMarket();
        await localDataSource.cacheGlobalMarket(market);
        return Result.success(DataResult.remote(market.toEntity()));
      } on AppException catch (error) {
        return _cachedGlobalMarket(_failureFromException(error));
      } on Object {
        return _cachedGlobalMarket(_unexpectedFailure);
      }
    }

    return _cachedGlobalMarket(
      const NetworkFailure(_noInternetMessage),
    );
  }

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const Result.success(DataResult.local([]));
    }

    if (await networkInfo.isConnected) {
      try {
        final coins = await remoteDataSource.searchCoins(trimmedQuery);
        return Result.success(
          DataResult.remote(await _toFavoriteAwareCoins(coins)),
        );
      } on AppException catch (error) {
        return _cachedSearch(trimmedQuery, _failureFromException(error));
      } on Object {
        return _cachedSearch(trimmedQuery, _unexpectedFailure);
      }
    }

    return _cachedSearch(
      trimmedQuery,
      const NetworkFailure(_noInternetMessage),
    );
  }

  @override
  Future<Result<bool>> toggleFavorite(String coinId) async {
    try {
      return Result.success(
        await localDataSource.toggleFavorite(coinId),
        source: ResultSource.local,
      );
    } on AppException catch (error) {
      return Result.failure(CacheFailure(error.message));
    } on Object {
      return const Result.failure(_unexpectedFailure);
    }
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) async {
    try {
      return Result.success(
        await localDataSource.isFavorite(coinId),
        source: ResultSource.local,
      );
    } on AppException catch (error) {
      return Result.failure(CacheFailure(error.message));
    } on Object {
      return const Result.failure(_unexpectedFailure);
    }
  }

  Future<Result<DataResult<List<Coin>>>> _cachedCoins(
    int page,
    Failure fallbackFailure,
  ) async {
    final cachedCoins = await localDataSource.getCachedCoinsWithMetadata(
      page,
      allowStale: true,
    );
    if (cachedCoins == null || cachedCoins.data.isEmpty) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(
        await _toFavoriteAwareCoins(cachedCoins.data),
        lastUpdated: cachedCoins.cachedAt,
      ),
    );
  }

  Future<Result<DataResult<CoinDetail>>> _cachedCoinDetail(
    String coinId,
    Failure fallbackFailure,
  ) async {
    final cachedDetail = await localDataSource.getCachedCoinDetailWithMetadata(
      coinId,
      allowStale: true,
    );
    if (cachedDetail == null) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(
        cachedDetail.data.toEntity(),
        lastUpdated: cachedDetail.cachedAt,
      ),
    );
  }

  Future<Result<DataResult<List<TrendingCoin>>>> _cachedTrendingCoins(
    Failure fallbackFailure,
  ) async {
    final cachedCoins =
        await localDataSource.getCachedTrendingCoinsWithMetadata(
      allowStale: true,
    );
    if (cachedCoins == null || cachedCoins.data.isEmpty) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(
        cachedCoins.data.map((coin) => coin.toEntity()).toList(),
        lastUpdated: cachedCoins.cachedAt,
      ),
    );
  }

  Future<Result<DataResult<GlobalMarket>>> _cachedGlobalMarket(
    Failure fallbackFailure,
  ) async {
    final cachedMarket =
        await localDataSource.getCachedGlobalMarketWithMetadata(
      allowStale: true,
    );
    if (cachedMarket == null) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(
        cachedMarket.data.toEntity(),
        lastUpdated: cachedMarket.cachedAt,
      ),
    );
  }

  Future<Result<DataResult<List<Coin>>>> _cachedSearch(
    String query,
    Failure fallbackFailure,
  ) async {
    final cachedCoins = await localDataSource.searchCachedCoinsWithMetadata(
      query,
      allowStale: true,
    );
    if (cachedCoins == null) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(
        await _toFavoriteAwareCoins(cachedCoins.data),
        lastUpdated: cachedCoins.cachedAt,
      ),
    );
  }

  Future<List<Coin>> _toFavoriteAwareCoins(Iterable<CoinModel> coins) async {
    final favoriteIds = await localDataSource.getFavoriteIds();
    return coins.map((coin) {
      return coin.toEntity(isFavorite: favoriteIds.contains(coin.id));
    }).toList();
  }

  Failure _failureFromException(AppException error) {
    return switch (error) {
      BadRequestException() => const BadRequestFailure(_unableToLoadData),
      UnauthorizedException() => const UnauthorizedFailure(_unableToLoadData),
      ForbiddenException() => const ForbiddenFailure(_unableToLoadData),
      NotFoundException() => const NotFoundFailure(_notFoundMessage),
      RateLimitException(retryAfter: final retryAfter) => RateLimitFailure(
          _rateLimitMessage,
          retryAfter: retryAfter,
        ),
      CacheException() => const CacheFailure(_cacheMessage),
      NetworkException(code: 'connection_error') =>
        const NetworkFailure(_noInternetMessage),
      NetworkException(code: 'timeout') => const NetworkFailure(
          _unableToLoadData,
          category: FailureCategory.timeout,
        ),
      NetworkException() => const NetworkFailure(_unableToLoadData),
      ServerException() => const ServerFailure(_unableToLoadData),
      _ => const UnknownFailure(_unableToLoadData),
    };
  }
}

const _unableToLoadData = 'Unable to load data. Please try again.';
const _noInternetMessage =
    'No internet connection. Showing cached data if available.';
const _notFoundMessage = 'Requested data was not found.';
const _rateLimitMessage = 'Too many requests. Please wait and try again.';
const _cacheMessage = 'Unable to load saved data. Please try again.';
const _unexpectedFailure = UnknownFailure(_unableToLoadData);
