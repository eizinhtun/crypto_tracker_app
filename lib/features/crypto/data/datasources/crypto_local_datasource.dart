import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/database/cache_record.dart';
import '../../../../core/error/exceptions.dart';
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/global_market_model.dart';
import '../models/trending_coin_model.dart';

abstract class CryptoLocalDataSource {
  Future<void> cacheCoins({
    required int page,
    required List<CoinModel> coins,
  });

  Future<List<CoinModel>> getCachedCoins(int page);

  Future<List<CoinModel>> searchCachedCoins(String query);

  Future<void> cacheCoinDetail(CoinDetailModel coin);

  Future<CoinDetailModel?> getCachedCoinDetail(String coinId);

  Future<void> cacheTrendingCoins(List<TrendingCoinModel> coins);

  Future<List<TrendingCoinModel>> getCachedTrendingCoins();

  Future<void> cacheGlobalMarket(GlobalMarketModel market);

  Future<GlobalMarketModel?> getCachedGlobalMarket();

  Future<bool> toggleFavorite(String coinId);

  Future<bool> isFavorite(String coinId);

  Future<Set<String>> getFavoriteIds();

  Future<void> invalidateExpiredCache();
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
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

  final Box<CacheRecord> coinsBox;
  final Box<CacheRecord> coinDetailsBox;
  final Box<CacheRecord> trendingBox;
  final Box<CacheRecord> globalMarketBox;
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
      _record(
        payload: coins.map((coin) => coin.toJson()).toList(),
        ttl: coinsTtl,
      ),
    );
  }

  @override
  Future<List<CoinModel>> getCachedCoins(int page) async {
    final record = await _getFreshRecord(
      coinsBox,
      '${StorageKeys.coinsPagePrefix}$page',
    );

    if (record == null) {
      return const [];
    }

    return _readMapList(record.payload).map(CoinModel.fromJson).toList();
  }

  @override
  Future<List<CoinModel>> searchCachedCoins(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final coins = <CoinModel>[];

    for (final key in coinsBox.keys.toList()) {
      final record = await _getFreshRecord(coinsBox, key);
      if (record == null) {
        continue;
      }

      coins.addAll(_readMapList(record.payload).map(CoinModel.fromJson));
    }

    final byId = <String, CoinModel>{
      for (final coin in coins) coin.id: coin,
    };

    return byId.values.where((coin) {
      return coin.name.toLowerCase().contains(normalizedQuery) ||
          coin.symbol.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  Future<void> cacheCoinDetail(CoinDetailModel coin) {
    return coinDetailsBox.put(
      '${StorageKeys.coinDetailPrefix}${coin.id}',
      _record(payload: coin.toJson(), ttl: coinDetailTtl),
    );
  }

  @override
  Future<CoinDetailModel?> getCachedCoinDetail(String coinId) async {
    final record = await _getFreshRecord(
      coinDetailsBox,
      '${StorageKeys.coinDetailPrefix}$coinId',
    );
    final map = _readMap(record?.payload);

    if (map == null) {
      return null;
    }

    return CoinDetailModel.fromJson(map);
  }

  @override
  Future<void> cacheTrendingCoins(List<TrendingCoinModel> coins) {
    return trendingBox.put(
      StorageKeys.trendingCoins,
      _record(
        payload: coins.map((coin) => coin.toJson()).toList(),
        ttl: trendingTtl,
      ),
    );
  }

  @override
  Future<List<TrendingCoinModel>> getCachedTrendingCoins() async {
    final record =
        await _getFreshRecord(trendingBox, StorageKeys.trendingCoins);
    if (record == null) {
      return const [];
    }

    return _readMapList(record.payload)
        .map(TrendingCoinModel.fromJson)
        .toList();
  }

  @override
  Future<void> cacheGlobalMarket(GlobalMarketModel market) {
    return globalMarketBox.put(
      StorageKeys.globalMarket,
      _record(payload: market.toJson(), ttl: globalMarketTtl),
    );
  }

  @override
  Future<GlobalMarketModel?> getCachedGlobalMarket() async {
    final record = await _getFreshRecord(
      globalMarketBox,
      StorageKeys.globalMarket,
    );
    final map = _readMap(record?.payload);

    if (map == null) {
      return null;
    }

    return GlobalMarketModel.fromJson(map);
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

  CacheRecord _record({
    required Object payload,
    required Duration ttl,
  }) {
    return CacheRecord(
      payload: payload,
      cachedAt: _now,
      ttl: ttl,
    );
  }

  Future<CacheRecord?> _getFreshRecord(
    Box<CacheRecord> box,
    Object key,
  ) async {
    final record = box.get(key);
    if (record == null) {
      return null;
    }

    if (record.isExpired(_now)) {
      await box.delete(key);
      return null;
    }

    return record;
  }

  Future<void> _deleteExpiredRecords(Box<CacheRecord> box) async {
    final expiredKeys = <Object>[];

    for (final key in box.keys) {
      final record = box.get(key);
      if (record == null || record.isExpired(_now)) {
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

  List<Map<String, dynamic>> _readMapList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }
}
