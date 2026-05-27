import '../../../../core/constants/app_constants.dart';
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
  Future<Result<List<Coin>>> getCoins({
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
        return Result.success(await _withFavoriteStatus(coins));
      } on AppException catch (error) {
        return _cachedCoins(page, error.message);
      } on Object catch (error) {
        return _cachedCoins(page, error.toString());
      }
    }

    return _cachedCoins(page, 'No internet connection');
  }

  @override
  Future<Result<CoinDetail>> getCoinDetail(String coinId) async {
    if (await networkInfo.isConnected) {
      try {
        final detail = await remoteDataSource.getCoinDetail(coinId);
        await localDataSource.cacheCoinDetail(detail);
        return Result.success(detail);
      } on AppException catch (error) {
        return _cachedCoinDetail(coinId, error.message);
      } on Object catch (error) {
        return _cachedCoinDetail(coinId, error.toString());
      }
    }

    return _cachedCoinDetail(coinId, 'No internet connection');
  }

  @override
  Future<Result<List<TrendingCoin>>> getTrendingCoins() async {
    if (await networkInfo.isConnected) {
      try {
        final coins = await remoteDataSource.getTrendingCoins();
        await localDataSource.cacheTrendingCoins(coins);
        return Result.success(coins);
      } on AppException catch (error) {
        return _cachedTrendingCoins(error.message);
      } on Object catch (error) {
        return _cachedTrendingCoins(error.toString());
      }
    }

    return _cachedTrendingCoins('No internet connection');
  }

  @override
  Future<Result<GlobalMarket>> getGlobalMarket() async {
    if (await networkInfo.isConnected) {
      try {
        final market = await remoteDataSource.getGlobalMarket();
        await localDataSource.cacheGlobalMarket(market);
        return Result.success(market);
      } on AppException catch (error) {
        return _cachedGlobalMarket(error.message);
      } on Object catch (error) {
        return _cachedGlobalMarket(error.toString());
      }
    }

    return _cachedGlobalMarket('No internet connection');
  }

  @override
  Future<Result<List<Coin>>> searchCoins(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const Result.success([]);
    }

    if (await networkInfo.isConnected) {
      try {
        final coins = await remoteDataSource.searchCoins(trimmedQuery);
        return Result.success(await _withFavoriteStatus(coins));
      } on AppException catch (error) {
        return _cachedSearch(trimmedQuery, error.message);
      } on Object catch (error) {
        return _cachedSearch(trimmedQuery, error.toString());
      }
    }

    return _cachedSearch(trimmedQuery, 'No internet connection');
  }

  @override
  Future<Result<bool>> toggleFavorite(String coinId) async {
    try {
      return Result.success(await localDataSource.toggleFavorite(coinId));
    } on AppException catch (error) {
      return Result.failure(CacheFailure(error.message));
    } on Object catch (error) {
      return Result.failure(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) async {
    try {
      return Result.success(await localDataSource.isFavorite(coinId));
    } on AppException catch (error) {
      return Result.failure(CacheFailure(error.message));
    } on Object catch (error) {
      return Result.failure(UnknownFailure(error.toString()));
    }
  }

  Future<Result<List<Coin>>> _cachedCoins(
    int page,
    String fallbackMessage,
  ) async {
    final cachedCoins = await localDataSource.getCachedCoins(page);
    if (cachedCoins.isEmpty && page == AppConstants.firstPage) {
      return Result.failure(CacheFailure(fallbackMessage));
    }

    return Result.success(await _withFavoriteStatus(cachedCoins));
  }

  Future<Result<CoinDetail>> _cachedCoinDetail(
    String coinId,
    String fallbackMessage,
  ) async {
    final cachedDetail = await localDataSource.getCachedCoinDetail(coinId);
    if (cachedDetail == null) {
      return Result.failure(CacheFailure(fallbackMessage));
    }

    return Result.success(cachedDetail);
  }

  Future<Result<List<TrendingCoin>>> _cachedTrendingCoins(
    String fallbackMessage,
  ) async {
    final cachedCoins = await localDataSource.getCachedTrendingCoins();
    if (cachedCoins.isEmpty) {
      return Result.failure(CacheFailure(fallbackMessage));
    }

    return Result.success(cachedCoins);
  }

  Future<Result<GlobalMarket>> _cachedGlobalMarket(
    String fallbackMessage,
  ) async {
    final cachedMarket = await localDataSource.getCachedGlobalMarket();
    if (cachedMarket == null) {
      return Result.failure(CacheFailure(fallbackMessage));
    }

    return Result.success(cachedMarket);
  }

  Future<Result<List<Coin>>> _cachedSearch(
    String query,
    String fallbackMessage,
  ) async {
    final cachedCoins = await localDataSource.searchCachedCoins(query);
    if (cachedCoins.isEmpty) {
      return Result.failure(CacheFailure(fallbackMessage));
    }

    return Result.success(await _withFavoriteStatus(cachedCoins));
  }

  Future<List<Coin>> _withFavoriteStatus(Iterable<CoinModel> coins) async {
    final favoriteIds = await localDataSource.getFavoriteIds();
    return coins.map((coin) {
      return coin.copyWith(isFavorite: favoriteIds.contains(coin.id));
    }).toList();
  }
}
