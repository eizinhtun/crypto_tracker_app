import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../cache/crypto_cache_records.dart';
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/global_market_model.dart';
import '../models/trending_coin_model.dart';

class CachedData<T> {
  const CachedData({
    required this.data,
    required this.cachedAt,
  });

  final T data;
  final DateTime cachedAt;
}

abstract class CryptoLocalDataSource {
  Future<void> cacheCoins({
    required int page,
    required List<CoinModel> coins,
  });

  Future<CachedData<List<CoinModel>>?> getCachedCoinsWithMetadata(
    int page, {
    bool allowStale = false,
  });

  Future<List<CoinModel>> getCachedCoins(
    int page, {
    bool allowStale = false,
  });

  Future<CachedData<List<CoinModel>>?> searchCachedCoinsWithMetadata(
    String query, {
    bool allowStale = false,
  });

  Future<List<CoinModel>> searchCachedCoins(
    String query, {
    bool allowStale = false,
  });

  Future<void> cacheCoinDetail(CoinDetailModel coin);

  Future<CachedData<CoinDetailModel>?> getCachedCoinDetailWithMetadata(
    String coinId, {
    bool allowStale = false,
  });

  Future<CoinDetailModel?> getCachedCoinDetail(
    String coinId, {
    bool allowStale = false,
  });

  Future<void> cacheTrendingCoins(List<TrendingCoinModel> coins);

  Future<CachedData<List<TrendingCoinModel>>?>
      getCachedTrendingCoinsWithMetadata({
    bool allowStale = false,
  });

  Future<List<TrendingCoinModel>> getCachedTrendingCoins({
    bool allowStale = false,
  });

  Future<void> cacheGlobalMarket(GlobalMarketModel market);

  Future<CachedData<GlobalMarketModel>?> getCachedGlobalMarketWithMetadata({
    bool allowStale = false,
  });

  Future<GlobalMarketModel?> getCachedGlobalMarket({
    bool allowStale = false,
  });

  Future<bool> toggleFavorite(String coinId);

  Future<bool> isFavorite(String coinId);

  Future<Set<String>> getFavoriteIds();

  Future<void> invalidateExpiredCache();
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  // Hive stores only non-sensitive public market cache and favorite coin IDs.
  const CryptoLocalDataSourceImpl({
    required this.coinsBox,
    required this.coinDetailsBox,
    required this.trendingBox,
    required this.globalMarketBox,
    required this.favoritesBox,
    this.coinsTtl = AppConstants.coinsCacheTtl,
    this.coinDetailTtl = AppConstants.coinDetailCacheTtl,
    this.trendingTtl = AppConstants.trendingCacheTtl,
    this.globalMarketTtl = AppConstants.globalMarketCacheTtl,
    this.now,
  });

  final Box<CoinsCacheRecord> coinsBox;
  final Box<CoinDetailCacheRecord> coinDetailsBox;
  final Box<TrendingCoinsCacheRecord> trendingBox;
  final Box<GlobalMarketCacheRecord> globalMarketBox;
  final Box<bool> favoritesBox;
  final Duration coinsTtl;
  final Duration coinDetailTtl;
  final Duration trendingTtl;
  final Duration globalMarketTtl;
  final DateTime Function()? now;

  @override
  Future<void> cacheCoins({
    required int page,
    required List<CoinModel> coins,
  }) {
    return coinsBox.put(
      '${StorageKeys.coinsPagePrefix}$page',
      CoinsCacheRecord(
        coins: coins.map(CoinCacheDto.fromModel).toList(growable: false),
        cachedAt: _now,
        ttl: coinsTtl,
      ),
    );
  }

  @override
  Future<CachedData<List<CoinModel>>?> getCachedCoinsWithMetadata(
    int page, {
    bool allowStale = false,
  }) async {
    final record = await _getFreshRecord(
      coinsBox,
      '${StorageKeys.coinsPagePrefix}$page',
      allowStale: allowStale,
    );

    if (record == null) {
      return null;
    }

    return CachedData(
      data: record.coins.map((coin) => coin.toModel()).toList(growable: false),
      cachedAt: record.cachedAt,
    );
  }

  @override
  Future<List<CoinModel>> getCachedCoins(
    int page, {
    bool allowStale = false,
  }) async {
    final cachedData = await getCachedCoinsWithMetadata(
      page,
      allowStale: allowStale,
    );
    return cachedData?.data ?? const [];
  }

  @override
  Future<CachedData<List<CoinModel>>?> searchCachedCoinsWithMetadata(
    String query, {
    bool allowStale = false,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final coins = <CoinModel>[];
    DateTime? latestCachedAt;

    for (final key in coinsBox.keys.toList()) {
      final record = await _getFreshRecord(
        coinsBox,
        key,
        allowStale: allowStale,
      );
      if (record == null) {
        continue;
      }

      latestCachedAt = _latest(latestCachedAt, record.cachedAt);
      coins.addAll(record.coins.map((coin) => coin.toModel()));
    }

    if (latestCachedAt == null) {
      return null;
    }

    final byId = <String, CoinModel>{
      for (final coin in coins) coin.id: coin,
    };

    return CachedData(
      data: byId.values.where((coin) {
        return coin.name.toLowerCase().contains(normalizedQuery) ||
            coin.symbol.toLowerCase().contains(normalizedQuery);
      }).toList(growable: false),
      cachedAt: latestCachedAt,
    );
  }

  @override
  Future<List<CoinModel>> searchCachedCoins(
    String query, {
    bool allowStale = false,
  }) async {
    final cachedData = await searchCachedCoinsWithMetadata(
      query,
      allowStale: allowStale,
    );
    return cachedData?.data ?? const [];
  }

  @override
  Future<void> cacheCoinDetail(CoinDetailModel coin) {
    return coinDetailsBox.put(
      '${StorageKeys.coinDetailPrefix}${coin.id}',
      CoinDetailCacheRecord(
        detail: CoinDetailCacheDto.fromModel(coin),
        cachedAt: _now,
        ttl: coinDetailTtl,
      ),
    );
  }

  @override
  Future<CachedData<CoinDetailModel>?> getCachedCoinDetailWithMetadata(
    String coinId, {
    bool allowStale = false,
  }) async {
    final record = await _getFreshRecord(
      coinDetailsBox,
      '${StorageKeys.coinDetailPrefix}$coinId',
      allowStale: allowStale,
    );
    if (record == null) {
      return null;
    }

    return CachedData(
      data: record.detail.toModel(),
      cachedAt: record.cachedAt,
    );
  }

  @override
  Future<CoinDetailModel?> getCachedCoinDetail(
    String coinId, {
    bool allowStale = false,
  }) async {
    final cachedData = await getCachedCoinDetailWithMetadata(
      coinId,
      allowStale: allowStale,
    );
    return cachedData?.data;
  }

  @override
  Future<void> cacheTrendingCoins(List<TrendingCoinModel> coins) {
    return trendingBox.put(
      StorageKeys.trendingCoins,
      TrendingCoinsCacheRecord(
        coins:
            coins.map(TrendingCoinCacheDto.fromModel).toList(growable: false),
        cachedAt: _now,
        ttl: trendingTtl,
      ),
    );
  }

  @override
  Future<CachedData<List<TrendingCoinModel>>?>
      getCachedTrendingCoinsWithMetadata({
    bool allowStale = false,
  }) async {
    final record = await _getFreshRecord(
      trendingBox,
      StorageKeys.trendingCoins,
      allowStale: allowStale,
    );
    if (record == null) {
      return null;
    }

    return CachedData(
      data: record.coins.map((coin) => coin.toModel()).toList(growable: false),
      cachedAt: record.cachedAt,
    );
  }

  @override
  Future<List<TrendingCoinModel>> getCachedTrendingCoins({
    bool allowStale = false,
  }) async {
    final cachedData = await getCachedTrendingCoinsWithMetadata(
      allowStale: allowStale,
    );
    return cachedData?.data ?? const [];
  }

  @override
  Future<void> cacheGlobalMarket(GlobalMarketModel market) {
    return globalMarketBox.put(
      StorageKeys.globalMarket,
      GlobalMarketCacheRecord(
        market: GlobalMarketCacheDto.fromModel(market),
        cachedAt: _now,
        ttl: globalMarketTtl,
      ),
    );
  }

  @override
  Future<CachedData<GlobalMarketModel>?> getCachedGlobalMarketWithMetadata({
    bool allowStale = false,
  }) async {
    final record = await _getFreshRecord(
      globalMarketBox,
      StorageKeys.globalMarket,
      allowStale: allowStale,
    );
    if (record == null) {
      return null;
    }

    return CachedData(
      data: record.market.toModel(),
      cachedAt: record.cachedAt,
    );
  }

  @override
  Future<GlobalMarketModel?> getCachedGlobalMarket({
    bool allowStale = false,
  }) async {
    final cachedData = await getCachedGlobalMarketWithMetadata(
      allowStale: allowStale,
    );
    return cachedData?.data;
  }

  @override
  Future<bool> toggleFavorite(String coinId) async {
    if (coinId.isEmpty) {
      throw const CacheException('Coin id is required');
    }

    final nextValue = !(await isFavorite(coinId));

    if (nextValue) {
      await favoritesBox.put(coinId, true);
    } else {
      await favoritesBox.delete(coinId);
    }

    return nextValue;
  }

  @override
  Future<bool> isFavorite(String coinId) async {
    return favoritesBox.get(coinId, defaultValue: false) == true;
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    return favoritesBox.keys
        .where((key) => favoritesBox.get(key, defaultValue: false) == true)
        .map((key) => key.toString())
        .toSet();
  }

  @override
  Future<void> invalidateExpiredCache() async {
    await Future.wait([
      _deleteExpiredRecords(coinsBox),
      _deleteExpiredRecords(coinDetailsBox),
      _deleteExpiredRecords(trendingBox),
      _deleteExpiredRecords(globalMarketBox),
    ]);
  }

  Future<T?> _getFreshRecord<T extends CryptoCacheRecord>(
    Box<T> box,
    Object key, {
    bool allowStale = false,
  }) async {
    final record = box.get(key);
    if (record == null) {
      return null;
    }

    if (!record.isCurrentSchema) {
      await box.delete(key);
      return null;
    }

    if (!allowStale && record.isExpired(_now)) {
      await box.delete(key);
      return null;
    }

    return record;
  }

  Future<void> _deleteExpiredRecords<T extends CryptoCacheRecord>(
    Box<T> box,
  ) async {
    final expiredKeys = <Object>[];

    for (final key in box.keys) {
      final record = box.get(key);
      if (record == null || !record.isCurrentSchema || record.isExpired(_now)) {
        expiredKeys.add(key);
      }
    }

    if (expiredKeys.isNotEmpty) {
      await box.deleteAll(expiredKeys);
    }
  }

  DateTime get _now {
    return (now?.call() ?? DateTime.now()).toUtc();
  }

  DateTime _latest(DateTime? current, DateTime candidate) {
    if (current == null || candidate.isAfter(current)) {
      return candidate;
    }

    return current;
  }
}
