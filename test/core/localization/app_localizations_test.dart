import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/error/failures.dart';
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
      expect(
        localizations.failureMessage(FailureCategory.rateLimit),
        contains('တောင်းဆိုမှုများလွန်းနေသည်'),
      );
    });

    test(
        'Given unsupported locale, when labels are requested, then English fallback is returned',
        () {
      const localizations = AppLocalizations(Locale('fr'));

      expect(localizations.searchHint, 'Search coins');
      expect(localizations.marketStats, 'MARKET STATS');
    });

    test(
        'Given failure categories, when messages are requested, then localized safe text is returned',
        () {
      const english = AppLocalizations(Locale('en'));
      const myanmar = AppLocalizations(Locale('my'));

      expect(
        english.failureMessage(FailureCategory.server),
        'Unable to load data. Please try again.',
      );
      expect(
        english.failureMessage(FailureCategory.rateLimit),
        'Too many requests. Please wait and try again.',
      );
      expect(
        english.failureMessage(FailureCategory.network),
        isNot(contains('DioException')),
      );
      expect(
        myanmar.failureMessage(FailureCategory.cacheUnavailable),
        'သိမ်းထားသော အချက်အလက် မရှိသေးပါ။',
      );
    });
  });
}
