import 'package:crypto_tracker_app/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats market prices without compacting detail values', () {
      expect(CurrencyFormatter.marketPrice(2095.85), r'$2,095.85');
      expect(CurrencyFormatter.marketPrice(0.43), r'$0.4300');
      expect(CurrencyFormatter.marketPrice(0.000000601), r'$0.00000060');
    });
  });
}
