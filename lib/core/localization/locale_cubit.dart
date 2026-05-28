import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_localizations.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit() : super(null);

  void useSystemLocale() => emit(null);

  void setLocale(Locale locale) {
    final supportedLocale = AppLocalizations.supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => AppLocalizations.fallbackLocale,
    );

    emit(supportedLocale);
  }

  void toggle(Locale currentLocale) {
    final nextLocale = currentLocale.languageCode == 'my'
        ? const Locale('en')
        : const Locale('my');
    emit(nextLocale);
  }
}
