import 'dart:io';

import 'package:crypto_tracker_app/core/constants/storage_keys.dart';
import 'package:crypto_tracker_app/core/database/hive_boxes.dart';
import 'package:crypto_tracker_app/core/localization/locale_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box<String> settingsBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('locale_cubit_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<String>(HiveBoxes.settings);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'Given selected locale is saved, when cubit starts, then locale restores',
      () async {
    await settingsBox.put(StorageKeys.selectedLocale, 'my');

    final cubit = LocaleCubit(settingsBox: settingsBox);
    addTearDown(cubit.close);

    expect(cubit.state, const Locale('my'));
  });

  test('Given locale is switched, when cubit emits, then choice is persisted',
      () async {
    final cubit = LocaleCubit(settingsBox: settingsBox);
    addTearDown(cubit.close);

    cubit.setLocale(const Locale('my'));
    await settingsBox.flush();

    expect(settingsBox.get(StorageKeys.selectedLocale), 'my');

    cubit.useSystemLocale();
    await settingsBox.flush();

    expect(settingsBox.get(StorageKeys.selectedLocale), isNull);
  });
}
