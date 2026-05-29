import 'dart:io';

import 'package:crypto_tracker_app/core/database/hive_boxes.dart';
import 'package:crypto_tracker_app/core/database/hive_initializer.dart';
import 'package:crypto_tracker_app/features/crypto/data/cache/crypto_cache_records.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_initializer_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    Hive.resetAdapters();

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'Given a cache box with an unknown legacy typeId, '
    'when Hive initializes, then the box is reset and reopened',
    () async {
      Hive.registerAdapter(_LegacyCacheRecordAdapter());
      final legacyBox = await Hive.openBox<dynamic>(HiveBoxes.coins);
      await legacyBox.put('legacy', const _LegacyCacheRecord('stale-cache'));
      await legacyBox.close();
      Hive.resetAdapters();

      await HiveInitializer.init(path: tempDir.path);

      final coinsBox = Hive.box<CoinsCacheRecord>(HiveBoxes.coins);
      final settingsBox = Hive.box<String>(HiveBoxes.settings);
      expect(coinsBox.isOpen, isTrue);
      expect(coinsBox.isEmpty, isTrue);
      expect(settingsBox.isOpen, isTrue);
      expect(
        Hive.isAdapterRegistered(CryptoCacheAdapters.coinsRecordTypeId),
        isTrue,
      );
    },
  );
}

final class _LegacyCacheRecord {
  const _LegacyCacheRecord(this.value);

  final String value;
}

final class _LegacyCacheRecordAdapter extends TypeAdapter<_LegacyCacheRecord> {
  static const legacyTypeId = 42;

  @override
  int get typeId => legacyTypeId;

  @override
  _LegacyCacheRecord read(BinaryReader reader) {
    return _LegacyCacheRecord(reader.readString());
  }

  @override
  void write(BinaryWriter writer, _LegacyCacheRecord obj) {
    writer.writeString(obj.value);
  }
}
