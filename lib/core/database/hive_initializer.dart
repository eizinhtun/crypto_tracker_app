import 'package:hive_flutter/hive_flutter.dart';

import '../../features/crypto/data/cache/crypto_cache_records.dart';
import 'hive_boxes.dart';

abstract final class HiveInitializer {
  // Previous cache experiments used typeId 42. Hive reports this as internal
  // typeId 74 at read time, so keep it ignored until old installs migrate.
  static const _retiredCacheTypeIds = [42];

  static Future<void> init({String? path}) async {
    if (path == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(path);
    }

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
    for (final typeId in _retiredCacheTypeIds) {
      if (!Hive.isAdapterRegistered(typeId)) {
        Hive.ignoreTypeId<Object>(typeId);
      }
    }
  }

  static Future<Box<T>> _openCacheBox<T extends CryptoCacheRecord>(
    String name,
  ) async {
    return _openTypedBox<T>(
      name,
      isValidValue: (value) => value is T && value.isCurrentSchema,
    );
  }

  static Future<Box<bool>> _openBoolBox(String name) async {
    return _openTypedBox<bool>(
      name,
      isValidValue: (value) => value is bool,
    );
  }

  static Future<Box<T>> _openTypedBox<T>(
    String name, {
    required bool Function(Object? value) isValidValue,
  }) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }

    try {
      await _deleteInvalidValues(name, isValidValue);
      return await Hive.openBox<T>(name);
    } on HiveError catch (error) {
      if (!_isRecoverableOpenError(error)) {
        rethrow;
      }

      await _deleteUnreadableBox(name);
      return Hive.openBox<T>(name);
    }
  }

  static Future<void> _deleteInvalidValues(
    String name,
    bool Function(Object? value) isValidValue,
  ) async {
    final migrationBox = await Hive.openBox<dynamic>(name);

    try {
      final invalidKeys = <dynamic>[];
      for (final key in migrationBox.keys.toList()) {
        final value = migrationBox.get(key);
        if (!isValidValue(value)) {
          invalidKeys.add(key);
        }
      }

      if (invalidKeys.isNotEmpty) {
        await migrationBox.deleteAll(invalidKeys);
      }
    } finally {
      await migrationBox.close();
    }
  }

  static Future<void> _deleteUnreadableBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      try {
        await Hive.box<dynamic>(name).close();
      } on HiveError {
        // The box may be open with a stricter generic type. deleteBoxFromDisk
        // can still close and delete it through Hive's internal registry.
      }
    }

    await Hive.deleteBoxFromDisk(name);
  }

  static bool _isRecoverableOpenError(HiveError error) {
    final message = error.message.toLowerCase();
    return message.contains('unknown typeid') ||
        message.contains('cannot read');
  }
}
