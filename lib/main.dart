import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/hive_initializer.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveInitializer.init();
  await configureDependencies();

  runApp(const CryptoTrackerApp());
}
