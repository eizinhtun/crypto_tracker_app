import 'package:hive/hive.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/date_formatter.dart';
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
}

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  const CryptoLocalDataSourceImpl({
    required this.coinsBox,
    required this.coinDetailsBox,
    required this.trendingBox,
    required this.globalMarketBox,
    required this.favoritesBox,
  });

  final Box<dynamic> coinsBox;
  final Box<dynamic> coinDetailsBox;
  final Box<dynamic> trendingBox;
  final Box<dynamic> globalMarketBox;
  final Box<dynamic> favoritesBox;

  @override
  Future<void> cacheCoins({
    required int page,
    required List<CoinModel> coins,
  }) {
    return coinsBox.put(
      '${StorageKeys.coinsPagePrefix}$page',
      coins.map((coin) => coin.toJson()).toList(),
    );
  }

  @override
  Future<List<CoinModel>> getCachedCoins(int page) async {
    final value = coinsBox.get('${StorageKeys.coinsPagePrefix}$page');
    return _readMapList(value).map(CoinModel.fromJson).toList();
  }

  @override
  Future<List<CoinModel>> searchCachedCoins(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final coins = <CoinModel>[];

    for (final value in coinsBox.values) {
      coins.addAll(_readMapList(value).map(CoinModel.fromJson));
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
      coin.toJson(),
    );
  }

  @override
  Future<CoinDetailModel?> getCachedCoinDetail(String coinId) async {
    final value = coinDetailsBox.get('${StorageKeys.coinDetailPrefix}$coinId');
    final map = _readMap(value);

    if (map == null) {
      return null;
    }

    return CoinDetailModel.fromJson(map);
  }

  @override
  Future<void> cacheTrendingCoins(List<TrendingCoinModel> coins) {
    return trendingBox.put(
      StorageKeys.trendingCoins,
      coins.map((coin) => coin.toJson()).toList(),
    );
  }

  @override
  Future<List<TrendingCoinModel>> getCachedTrendingCoins() async {
    final value = trendingBox.get(StorageKeys.trendingCoins);
    return _readMapList(value).map(TrendingCoinModel.fromJson).toList();
  }

  @override
  Future<void> cacheGlobalMarket(GlobalMarketModel market) {
    return globalMarketBox.put(
      StorageKeys.globalMarket,
      market.toJson()..['cached_at'] = DateFormatter.readable(DateTime.now()),
    );
  }

  @override
  Future<GlobalMarketModel?> getCachedGlobalMarket() async {
    final value = globalMarketBox.get(StorageKeys.globalMarket);
    final map = _readMap(value);

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
        .where((key) => favoritesBox.get(key) == true)
        .map((key) => key.toString())
        .toSet();
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
