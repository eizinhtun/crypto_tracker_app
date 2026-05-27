import 'package:hive_flutter/hive_flutter.dart';

import 'cache_record.dart';
import 'hive_boxes.dart';

abstract final class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();

    await Future.wait([
      _openCacheBox(HiveBoxes.coins),
      _openCacheBox(HiveBoxes.coinDetails),
      _openCacheBox(HiveBoxes.trending),
      _openCacheBox(HiveBoxes.globalMarket),
      _openBoolBox(HiveBoxes.favorites),
    ]);
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(CacheRecordAdapter.adapterTypeId)) {
      Hive.registerAdapter(CacheRecordAdapter());
    }
  }

  static Future<Box<CacheRecord>> _openCacheBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<CacheRecord>(name);
    }

    final migrationBox = await Hive.openBox<dynamic>(name);
    final legacyKeys = migrationBox.keys.where((key) {
      return migrationBox.get(key) is! CacheRecord;
    }).toList();

    if (legacyKeys.isNotEmpty) {
      await migrationBox.deleteAll(legacyKeys);
    }

    await migrationBox.close();
    return Hive.openBox<CacheRecord>(name);
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
