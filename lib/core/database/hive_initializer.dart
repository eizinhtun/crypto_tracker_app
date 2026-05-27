import 'package:hive_flutter/hive_flutter.dart';

import '../../features/crypto/data/cache/crypto_cache_records.dart';
import 'hive_boxes.dart';

abstract final class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();

    await Future.wait([
      _openCacheBox<CoinsCacheRecord>(HiveBoxes.coins),
      _openCacheBox<CoinDetailCacheRecord>(HiveBoxes.coinDetails),
      _openCacheBox<TrendingCoinsCacheRecord>(HiveBoxes.trending),
      _openCacheBox<GlobalMarketCacheRecord>(HiveBoxes.globalMarket),
      _openBoolBox(HiveBoxes.favorites),
    ]);
  }

  static void _registerAdapters() {
    CryptoCacheAdapters.register();
  }

  static Future<Box<T>> _openCacheBox<T extends CryptoCacheRecord>(
    String name,
  ) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }

    final migrationBox = await Hive.openBox<dynamic>(name);
    final legacyKeys = migrationBox.keys.where((key) {
      final value = migrationBox.get(key);
      return value is! T || !value.isCurrentSchema;
    }).toList();

    if (legacyKeys.isNotEmpty) {
      await migrationBox.deleteAll(legacyKeys);
    }

    await migrationBox.close();
    return Hive.openBox<T>(name);
  }

  static Future<Box<bool>> _openBoolBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<bool>(name);
    }

    final migrationBox = await Hive.openBox<dynamic>(name);
    final invalidKeys = migrationBox.keys.where((key) {
      return migrationBox.get(key) is! bool;
    }).toList();

    if (invalidKeys.isNotEmpty) {
      await migrationBox.deleteAll(invalidKeys);
    }

    await migrationBox.close();
    return Hive.openBox<bool>(name);
  }
}
