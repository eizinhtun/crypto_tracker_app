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
      } on Object catch (error) {
        return _cachedCoins(page, UnknownFailure(error.toString()));
      }
    }

    return _cachedCoins(
      page,
      const NetworkFailure('No internet connection'),
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
      } on Object catch (error) {
        return _cachedCoinDetail(coinId, UnknownFailure(error.toString()));
      }
    }

    return _cachedCoinDetail(
      coinId,
      const NetworkFailure('No internet connection'),
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
      } on Object catch (error) {
        return _cachedTrendingCoins(UnknownFailure(error.toString()));
      }
    }

    return _cachedTrendingCoins(
      const NetworkFailure('No internet connection'),
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
      } on Object catch (error) {
        return _cachedGlobalMarket(UnknownFailure(error.toString()));
      }
    }

    return _cachedGlobalMarket(
      const NetworkFailure('No internet connection'),
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
      } on Object catch (error) {
        return _cachedSearch(trimmedQuery, UnknownFailure(error.toString()));
      }
    }

    return _cachedSearch(
      trimmedQuery,
      const NetworkFailure('No internet connection'),
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
    } on Object catch (error) {
      return Result.failure(UnknownFailure(error.toString()));
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
    } on Object catch (error) {
      return Result.failure(UnknownFailure(error.toString()));
    }
  }

  Future<Result<DataResult<List<Coin>>>> _cachedCoins(
    int page,
    Failure fallbackFailure,
  ) async {
    final cachedCoins = await localDataSource.getCachedCoins(page);
    if (cachedCoins.isEmpty) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(await _toFavoriteAwareCoins(cachedCoins)),
    );
  }

  Future<Result<DataResult<CoinDetail>>> _cachedCoinDetail(
    String coinId,
    Failure fallbackFailure,
  ) async {
    final cachedDetail = await localDataSource.getCachedCoinDetail(coinId);
    if (cachedDetail == null) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(DataResult.cache(cachedDetail.toEntity()));
  }

  Future<Result<DataResult<List<TrendingCoin>>>> _cachedTrendingCoins(
    Failure fallbackFailure,
  ) async {
    final cachedCoins = await localDataSource.getCachedTrendingCoins();
    if (cachedCoins.isEmpty) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(cachedCoins.map((coin) => coin.toEntity()).toList()),
    );
  }

  Future<Result<DataResult<GlobalMarket>>> _cachedGlobalMarket(
    Failure fallbackFailure,
  ) async {
    final cachedMarket = await localDataSource.getCachedGlobalMarket();
    if (cachedMarket == null) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(DataResult.cache(cachedMarket.toEntity()));
  }

  Future<Result<DataResult<List<Coin>>>> _cachedSearch(
    String query,
    Failure fallbackFailure,
  ) async {
    final cachedCoins = await localDataSource.searchCachedCoins(query);
    if (cachedCoins.isEmpty) {
      return Result.failure(fallbackFailure);
    }

    return Result.success(
      DataResult.cache(await _toFavoriteAwareCoins(cachedCoins)),
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
      BadRequestException() => BadRequestFailure(error.message),
      UnauthorizedException() => UnauthorizedFailure(error.message),
      ForbiddenException() => ForbiddenFailure(error.message),
      NotFoundException() => NotFoundFailure(error.message),
      RateLimitException(retryAfter: final retryAfter) => RateLimitFailure(
          error.message,
          retryAfter: retryAfter,
        ),
      CacheException() => CacheFailure(error.message),
      NetworkException() => NetworkFailure(error.message),
      ServerException() => ServerFailure(error.message),
      _ => UnknownFailure(error.message),
    };
  }
}
