import 'package:crypto_tracker_app/core/constants/app_constants.dart';
import 'package:crypto_tracker_app/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app scaffold', () {
    test('uses the take-home app name', () {
      expect(AppConstants.appName, 'Crypto Tracker');
    });

    test('formats percentages consistently', () {
      expect(CurrencyFormatter.percentage(1.234), '1.23%');
    });
  });
}
