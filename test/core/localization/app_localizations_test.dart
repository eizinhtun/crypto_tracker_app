import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    test(
        'Given Myanmar locale, when labels are requested, then native translations are returned',
        () {
      const localizations = AppLocalizations(Locale('my'));

      expect(localizations.searchHint, 'ဒင်္ဂါးများ ရှာဖွေပါ');
      expect(localizations.retry, 'ထပ်မံကြိုးစားမည်');
      expect(localizations.offline, contains('အော့ဖ်လိုင်း'));
    });

    test(
        'Given unsupported locale, when labels are requested, then English fallback is returned',
        () {
      const localizations = AppLocalizations(Locale('fr'));

      expect(localizations.searchHint, 'Search coins');
      expect(localizations.marketStats, 'MARKET STATS');
    });
  });
}
