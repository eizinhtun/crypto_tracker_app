import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../constants/storage_keys.dart';
import '../database/hive_boxes.dart';
import 'app_localizations.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({Box<String>? settingsBox})
      : this._(settingsBox ?? _settingsBoxOrNull());

  LocaleCubit._(this._settingsBox) : super(_initialLocale(_settingsBox));

  final Box<String>? _settingsBox;

  void useSystemLocale() {
    _persistLocale(null);
    emit(null);
  }

  void setLocale(Locale locale) {
    final supportedLocale = AppLocalizations.supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => AppLocalizations.fallbackLocale,
    );

    _persistLocale(supportedLocale);
    emit(supportedLocale);
  }

  void toggle(Locale currentLocale) {
    final nextLocale = currentLocale.languageCode == 'my'
        ? const Locale('en')
        : const Locale('my');
    _persistLocale(nextLocale);
    emit(nextLocale);
  }

  void _persistLocale(Locale? locale) {
    final settingsBox = _settingsBox;
    if (settingsBox == null) {
      return;
    }

    if (locale == null) {
      unawaited(settingsBox.delete(StorageKeys.selectedLocale));
      return;
    }

    unawaited(settingsBox.put(StorageKeys.selectedLocale, locale.languageCode));
  }

  static Box<String>? _settingsBoxOrNull() {
    if (!Hive.isBoxOpen(HiveBoxes.settings)) {
      return null;
    }

    return Hive.box<String>(HiveBoxes.settings);
  }

  static Locale? _initialLocale(Box<String>? settingsBox) {
    final languageCode = settingsBox?.get(StorageKeys.selectedLocale);
    if (languageCode == null) {
      return null;
    }

    for (final supportedLocale in AppLocalizations.supportedLocales) {
      if (supportedLocale.languageCode == languageCode) {
        return supportedLocale;
      }
    }

    return null;
  }
}
