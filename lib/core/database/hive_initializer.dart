import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

abstract final class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Future.wait([
      _openBox(HiveBoxes.coins),
      _openBox(HiveBoxes.coinDetails),
      _openBox(HiveBoxes.trending),
      _openBox(HiveBoxes.globalMarket),
      _openBox(HiveBoxes.favorites),
    ]);
  }

  static Future<Box<dynamic>> _openBox(String name) {
    if (Hive.isBoxOpen(name)) {
      return Future.value(Hive.box<dynamic>(name));
    }

    return Hive.openBox<dynamic>(name);
  }
}
